import 'dart:async';
import 'dart:developer' show log;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/auth_controller.dart';
import 'core/deep_link/toit_deep_link.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/fcm_registration_service.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/navigation_shell.dart'
    show NavigationShell, pendingDeepLinkUrlProvider;
import 'views/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  _initFcm();

  runApp(const ProviderScope(child: MyApp()));
}

/// FCM 초기화(비동기). OS 알림 권한 요청은 로그인 후
/// [FcmRegistrationService.syncServerRegistration]에서 수행한다.
Future<void> _initFcm() async {
  // TODO(FCM-콘솔정리): 릴리스 전 삭제 — 선조회 로그·catch의 debugPrint/log·필요 시 import
  try {
    final token = await FirebaseMessaging.instance.getToken();
    logFcmTokenSnapshot('main 선조회(getToken)', token);
  } catch (e, st) {
    final text = '[FCM] main 선조회 실패(무시 가능): $e';
    debugPrint('$text\n$st');
    log(text, name: 'FCM', error: e, stackTrace: st);
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  /// 스플래시가 최소한 이 시간만큼은 노출되도록 보장한다.
  /// 부트스트랩이 너무 빨라 화면이 깜빡이는 인상을 주지 않기 위함.
  static const _minSplashDuration = Duration(milliseconds: 1500);

  StreamSubscription<String>? _fcmTokenRefreshSub;

  /// 스플래시 최소 노출 시간이 지난 뒤에만 true.
  /// `authState`가 먼저 확정되더라도 이 값이 false인 동안에는 스플래시를 유지한다.
  bool _isSplashFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAuth();
    _bindFcmDeepLinks();
    _bindFcmTokenRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fcmTokenRefreshSub?.cancel();
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
    final url = ToitDeepLink.extractUrlFromFcmData(message.data);
    if (url == null) return;
    ref.read(pendingDeepLinkUrlProvider.notifier).state = url;
  }

  Future<void> _initAuth() async {
    // ApiClient에 인증 인터셉터 연결
    final apiClient = ref.read(apiClientProvider);
    final authService = ref.read(authServiceProvider);

    apiClient.enableAuth(
      authService: authService,
      onForceLogout: () {
        ref.read(authProvider.notifier).forceLogout();
      },
    );

    // 저장된 토큰 확인 → 인증 상태 복원.
    // 스플래시 최소 노출 시간과 병렬 대기하여 빠른 부팅 시의 깜빡임을 방지한다.
    // `checkAuthStatus`는 내부에서 state를 바로 바꾸기 때문에 지연만으로는
    // 화면 전환을 막을 수 없어, 완료 플래그(_isSplashFinished)를 함께 운용한다.
    await Future.wait<void>([
      ref.read(authProvider.notifier).checkAuthStatus(),
      Future<void>.delayed(_minSplashDuration),
    ]);
    if (!mounted) return;
    setState(() => _isSplashFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'toIT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AuthState authState) {
    if (!_isSplashFinished || authState.status == AuthStatus.unknown) {
      return const SplashScreen();
    }
    switch (authState.status) {
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        return const NavigationShell();
      case AuthStatus.unknown:
        return const SplashScreen();
    }
  }
}
