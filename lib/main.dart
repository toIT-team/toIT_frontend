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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  _initFcm();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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

class _MyAppState extends ConsumerState<MyApp>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _fcmTokenRefreshSub;

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
      ref.read(fcmRegistrationServiceProvider).syncServerRegistration(
            promptForPermission: false,
          ),
    );
  }

  /// 로그인 중일 때만 FCM 토큰 갱신을 서버에 반영
  void _bindFcmTokenRefresh() {
    _fcmTokenRefreshSub =
        FirebaseMessaging.instance.onTokenRefresh.listen(
      (String newToken) {
        final auth = ref.read(authProvider);
        if (auth.status != AuthStatus.authenticated) return;
        unawaited(
          ref.read(fcmRegistrationServiceProvider).syncServerRegistration(
                promptForPermission: false,
                fcmToken: newToken,
              ),
        );
      },
    );
  }

  void _bindFcmDeepLinks() {
    FirebaseMessaging.onMessageOpenedApp.listen(_onFcmMessageOpened);
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
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

    // 저장된 토큰 확인 → 인증 상태 복원
    await ref.read(authProvider.notifier).checkAuthStatus();
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
    switch (authState.status) {
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        return const NavigationShell();
    }
  }
}
