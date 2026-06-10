import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'controllers/auth_controller.dart';
import 'controllers/bootstrap_controller.dart';
import 'controllers/notifications_page_controller.dart';
import 'controllers/notifications_unread_count_controller.dart';
import 'core/constants/api_constants.dart';
import 'core/deep_link/toit_deep_link.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/fcm_registration_service.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/navigation_shell.dart'
    show NavigationShell, pendingDeepLinkUrlProvider;
import 'views/screens/splash_retry_screen.dart';
import 'views/screens/splash_screen.dart';
import 'views/widgets/common/app_alert_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Android는 google-services 플러그인이 네이티브에서 [DEFAULT] 앱을 자동 초기화하므로
  // Flutter에서 또 초기화하면 duplicate-app 예외가 발생한다. 이미 초기화된 경우 무시한다.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  static const _launchInfoChannel = MethodChannel(
    'com.toit/launch_info',
  );
  final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// 스플래시가 최소한 이 시간만큼은 노출되도록 보장한다.
  /// 부트스트랩이 너무 빨라 화면이 깜빡이는 인상을 주지 않기 위함.
  static const _minSplashDuration = Duration(milliseconds: 1500);

  StreamSubscription<String>? _fcmTokenRefreshSub;
  StreamSubscription<RemoteMessage>? _fcmOnMessageSub;

  /// 스플래시 최소 노출 시간이 지난 뒤에만 true.
  /// `authState`가 먼저 확정되더라도 이 값이 false인 동안에는 스플래시를 유지한다.
  bool _isSplashFinished = false;
  bool _showSessionExpiredNotice = false;
  bool _isSessionExpiredDialogShowing = false;
  int? _pendingReadNotificationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ProviderScope 첫 빌드가 안정화된 뒤 부트스트랩을 시작한다.
    // initState 즉시 provider state를 변경하면 프레임워크 assert와 충돌할 수 있다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_initAuth());
    });
    _bindFcmDeepLinks();
    _bindFcmTokenRefresh();
    _bindFcmForegroundIncoming();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fcmTokenRefreshSub?.cancel();
    _fcmOnMessageSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return;
    unawaited(
      ref
          .read(fcmRegistrationServiceProvider)
          .syncServerRegistration(promptForPermission: false),
    );
    // 백그라운드/종료 상태에서 도착한 알림은 포그라운드 핸들러를 거치지 못하므로
    // resume 시점에 카운트는 즉시 갱신하고, 리스트는 dirty만 찍어 다음 진입 시
    // 자동 동기화되도록 한다.
    _refreshUnreadCountIfAuthenticated();
    _markNotificationsPageDirtyIfAuthenticated();
  }

  /// 로그인 중일 때만 FCM 토큰 갱신을 서버에 반영
  void _bindFcmTokenRefresh() {
    _fcmTokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      String newToken,
    ) {
      final auth = ref.read(authProvider);
      if (auth.status != AuthStatus.authenticated) return;
      unawaited(
        ref
            .read(fcmRegistrationServiceProvider)
            .syncServerRegistration(
              promptForPermission: false,
              fcmToken: newToken,
            ),
      );
    });
  }

  void _bindFcmDeepLinks() {
    FirebaseMessaging.onMessageOpenedApp.listen(_onFcmMessageOpened);
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) _onFcmMessageOpened(message);
    });
  }

  void _onFcmMessageOpened(RemoteMessage message) {
    final didScheduleRead = _markNotificationAsReadFromFcm(message);
    if (!didScheduleRead) {
      _refreshUnreadCountIfAuthenticated();
    }
    final url = ToitDeepLink.extractUrlFromFcmData(message.data);
    if (url == null) return;
    ref.read(pendingDeepLinkUrlProvider.notifier).state = url;
  }

  bool _markNotificationAsReadFromFcm(RemoteMessage message) {
    final notificationId = ToitDeepLink.extractNotificationIdFromFcmData(
      message.data,
    );
    if (notificationId == null) return false;
    final authState = ref.read(authProvider);
    if (authState.status != AuthStatus.authenticated) {
      // cold start에서 인증 복구보다 push open 콜백이 먼저 들어오면
      // 읽음 PATCH를 놓치지 않도록 인증 완료 시점까지 보관한다.
      _pendingReadNotificationId = notificationId;
      return false;
    }
    unawaited(_patchNotificationRead(notificationId));
    return true;
  }

  Future<void> _patchNotificationRead(int notificationId) async {
    try {
      await ref
          .read(apiClientProvider)
          .patch<void>(ApiConstants.notificationReadPath(notificationId));
    } catch (_) {
      return;
    }
    _refreshUnreadCountIfAuthenticated();
  }

  /// 포그라운드 알림 수신 시 배지(count)는 즉시 갱신하고,
  /// 리스트 캐시는 dirty 표시만 남겨 진입 시점에 동기화되도록 한다.
  void _bindFcmForegroundIncoming() {
    _fcmOnMessageSub = FirebaseMessaging.onMessage.listen((_) {
      _refreshUnreadCountIfAuthenticated();
      _markNotificationsPageDirtyIfAuthenticated();
    });
  }

  void _refreshUnreadCountIfAuthenticated() {
    final cacheKey = _resolveAuthenticatedCacheKey();
    if (cacheKey == null) return;
    unawaited(
      ref.read(notificationsUnreadCountProvider(cacheKey).notifier).refresh(),
    );
  }

  void _markNotificationsPageDirtyIfAuthenticated() {
    final cacheKey = _resolveAuthenticatedCacheKey();
    if (cacheKey == null) return;
    ref.read(notificationsPageDirtyProvider(cacheKey).notifier).state = true;
  }

  /// 인증된 사용자에 대한 (userId, refreshTick) 캐시 키를 반환.
  /// 미인증이면 null을 돌려 호출자가 조용히 빠져나오게 한다.
  (int, int)? _resolveAuthenticatedCacheKey() {
    final authState = ref.read(authProvider);
    final userId = authState.userId;
    if (authState.status != AuthStatus.authenticated || userId == null) {
      return null;
    }
    return (userId, ref.read(authSessionRefreshTickProvider));
  }

  Future<void> _initAuth() async {
    if (!mounted) return;

    // ApiClient에 인증 인터셉터 연결
    final apiClient = ref.read(apiClientProvider);
    final authService = ref.read(authServiceProvider);

    apiClient.enableAuth(
      authService: authService,
      onForceLogout: () {
        _showSessionExpiredNotice = true;
        ref.read(authProvider.notifier).forceLogout();
      },
    );

    final skipMinSplashDelay = await _shouldSkipMinSplashDelay();

    // 부트스트랩(토큰 확인 + 선제 재발급 + 세션 복원)과 스플래시 최소
    // 노출 시간을 병렬 대기한다. `BootstrapController` 가 실패/재시도 경로를
    // 관리하므로 여기서는 "끝났는가" 여부만 플래그로 남긴다.
    // debugPrint(
      // '[BOOT] splash_start minDurationMs='
      // '${skipMinSplashDelay ? 0 : _minSplashDuration.inMilliseconds}',
    // );
    final splashStopwatch = Stopwatch()..start();
    await Future.wait<void>([
      ref.read(bootstrapProvider.notifier).run(),
      if (!skipMinSplashDelay) Future<void>.delayed(_minSplashDuration),
    ]);
    splashStopwatch.stop();
    if (!mounted) {
      // debugPrint('[BOOT] splash_end aborted=unmounted');
      return;
    }
    // debugPrint(
      // '[BOOT] splash_end elapsedMs=${splashStopwatch.elapsedMilliseconds}',
    // );
    setState(() => _isSplashFinished = true);
  }

  /// Android 외부 공유 진입에서는 스플래시 최소 노출을 건너뛰어
  /// iOS 공유 시트와 유사한 즉시 진입 체감을 맞춘다.
  Future<bool> _shouldSkipMinSplashDelay() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final result = await _launchInfoChannel.invokeMethod<bool>(
        'isShareLaunch',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthStatus>(
      authProvider.select((state) => state.status),
      _handleAuthStatusChanged,
    );

    final bootstrapStatus = ref.watch(
      bootstrapProvider.select((state) => state.status),
    );
    final authStatus = ref.watch(authProvider.select((state) => state.status));

    return MaterialApp(
      title: 'toIT',
      debugShowCheckedModeBanner: false,
      navigatorKey: _rootNavigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _buildHome(bootstrapStatus, authStatus),
    );
  }

  Widget _buildHome(BootstrapStatus status, AuthStatus authStatus) {
    // 최소 노출 시간 또는 아직 부트스트랩 결과가 확정되지 않은 동안은
    // 항상 스플래시를 유지해 화면 깜빡임을 방지한다.
    if (!_isSplashFinished ||
        status == BootstrapStatus.idle ||
        status == BootstrapStatus.running) {
      return const SplashScreen();
    }
    final route = _routeForStatus(
      bootstrapStatus: status,
      authStatus: authStatus,
    );
    _logRouteIfChanged(route);
    return route;
  }

  /// 상태를 라우트로 매핑. `_buildHome` 의 분기와 로깅을 분리해
  /// 재빌드마다 불필요한 로그가 쌓이지 않도록 한다.
  Widget _routeForStatus({
    required BootstrapStatus bootstrapStatus,
    required AuthStatus authStatus,
  }) {
    // 재시도 필요 상태는 auth 상태보다 항상 우선한다.
    // 부트스트랩 도중 `checkAuthStatus` 등이 `authStatus` 를 먼저 authenticated 로
    // 바꾼 뒤 전체 타임아웃이 터지는 레이스가 있어서, 이 분기를 먼저 두지 않으면
    // `SplashRetryScreen` 대신 `NavigationShell` 로 잘못 들어갈 수 있다.
    if (bootstrapStatus == BootstrapStatus.retryable) {
      return const SplashRetryScreen();
    }

    // 앱 진입 이후의 로그인/로그아웃 전환은 auth 상태를 우선한다.
    switch (authStatus) {
      case AuthStatus.authenticated:
        return const NavigationShell();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.unknown:
        break;
    }

    // authStatus 가 아직 확정되지 않았다면(= 부트스트랩이 checkAuthStatus 전에
    // 종결됐거나, 디버그 훅으로 authStatus 갱신이 스킵된 경우) bootstrapStatus
    // 로 라우팅을 마무리한다.
    switch (bootstrapStatus) {
      case BootstrapStatus.authenticated:
        return const NavigationShell();
      case BootstrapStatus.unauthenticated:
        return const LoginScreen();
      case BootstrapStatus.retryable:
      case BootstrapStatus.idle:
      case BootstrapStatus.running:
        return const SplashScreen();
    }
  }

  /// 동일 라우트 재빌드는 무시하고, 전환이 일어났을 때만 로그를 남긴다.
  String? _lastRouteLog;
  void _logRouteIfChanged(Widget route) {
    final name = route.runtimeType.toString();
    if (_lastRouteLog == name) return;
    _lastRouteLog = name;
    // debugPrint('[BOOT] route_decided home=$name');
  }

  void _handleAuthStatusChanged(AuthStatus? previous, AuthStatus next) {
    if (next == AuthStatus.authenticated) {
      _showSessionExpiredNotice = false;
      _consumePendingNotificationRead();
      return;
    }
    if (next != AuthStatus.unauthenticated || !_showSessionExpiredNotice) {
      return;
    }

    if (_isSessionExpiredDialogShowing) return;
    _showSessionExpiredNotice = false;
    _isSessionExpiredDialogShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _isSessionExpiredDialogShowing = false;
        return;
      }

      final navigator = _rootNavigatorKey.currentState;
      final dialogContext = _rootNavigatorKey.currentContext;
      if (navigator == null || dialogContext == null) {
        _isSessionExpiredDialogShowing = false;
        return;
      }

      await showAppAlertDialog(
        dialogContext,
        message: '세션이 만료되어 다시 로그인해 주세요.',
        confirmLabel: '확인',
      );

      if (mounted) {
        navigator.popUntil((route) => route.isFirst);
      }
      _isSessionExpiredDialogShowing = false;
    });
  }

  void _consumePendingNotificationRead() {
    final notificationId = _pendingReadNotificationId;
    if (notificationId == null) return;
    _pendingReadNotificationId = null;
    unawaited(_patchNotificationRead(notificationId));
  }
}
