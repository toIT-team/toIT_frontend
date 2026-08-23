import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../services/auth_service.dart';
import '../services/fcm_registration_service.dart';

/// 소셜 로그인 진행 중인 공급자. [AuthState.activeSocialLogin]에 사용한다.
enum SocialLoginKind { kakao, apple }

/// 인증 상태
enum AuthStatus {
  /// 아직 토큰 확인 전
  unknown,

  /// 로그인 완료 (토큰 보유)
  authenticated,

  /// 로그인 후 닉네임 입력 필요
  needsNickname,

  /// 미로그인 (토큰 없음)
  unauthenticated,
}

/// 인증 세션 변경(로그인/로그아웃/토큰 갱신) 시 캐시 갱신 트리거
final authSessionRefreshTickProvider = StateProvider<int>((ref) => 0);

/// 인증 상태 + 부가 정보
class AuthState {
  final AuthStatus status;
  final bool isLoading;
  final String? errorMessage;

  /// 카카오/애플 중 실제로 진행 중인 로그인. 그 외 busy는 null.
  final SocialLoginKind? activeSocialLogin;

  /// JWT에서 추출한 실제 사용자 ID
  final int? userId;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.isLoading = false,
    this.errorMessage,
    this.activeSocialLogin,
    this.userId,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? errorMessage,
    SocialLoginKind? activeSocialLogin,
    int? userId,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeSocialLogin: activeSocialLogin,
      userId: userId ?? this.userId,
    );
  }
}

/// 인증 상태를 관리하는 Notifier
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthService get _authService => ref.read(authServiceProvider);

  ApiClient get _apiClient => ref.read(apiClientProvider);

  void _bumpSessionRefreshTick() {
    final notifier = ref.read(authSessionRefreshTickProvider.notifier);
    notifier.state = notifier.state + 1;
  }

  /// 앱 시작 시 저장된 토큰이 있으면 인증 상태 복원
  Future<void> checkAuthStatus() async {
    final hasTokens = await _authService.hasTokens();
    if (hasTokens) {
      final me = await _fetchAuthMe();
      state = AuthState(
        status: me.needsNickname
            ? AuthStatus.needsNickname
            : AuthStatus.authenticated,
        userId: me.userId,
      );
      await _authService.ensurePlatformTokenStoreReady();
      if (!me.needsNickname) {
        unawaited(_authService.fetchAndSaveCloudFrontCookies());
      }
      unawaited(
        ref.read(fcmRegistrationServiceProvider).syncServerRegistration(
              promptForPermission: true,
            ),
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
    // debugPrint(
    // '[AuthController] 인증 상태: ${state.status}'
    // ', userId: ${state.userId}',
    // );
  }

  /// 카카오 로그인 (백엔드 OAuth → 동일 콜백 규약)
  Future<void> loginWithKakao() async {
    await _runSocialLogin(SocialLoginKind.kakao, _authService.loginWithKakao);
  }

  /// 애플 로그인 (백엔드 OAuth → 동일 콜백 규약)
  Future<void> loginWithApple() async {
    await _runSocialLogin(SocialLoginKind.apple, _authService.loginWithApple);
  }

  Future<void> _runSocialLogin(
    SocialLoginKind kind,
    Future<AuthCallbackData> Function() login,
  ) async {
    state = state.copyWith(
      isLoading: true,
      activeSocialLogin: kind,
      errorMessage: null,
    );

    try {
      final callbackData = await login();

      switch (callbackData.result) {
        case AuthCallbackResult.success:
          if (callbackData.accessToken != null &&
              callbackData.refreshToken != null) {
            await _authService.saveTokens(
              accessToken: callbackData.accessToken!,
              refreshToken: callbackData.refreshToken!,
            );
            await _authService.printStoredUserInfo();
            final me = await _fetchAuthMe();
            state = AuthState(
              status: me.needsNickname
                  ? AuthStatus.needsNickname
                  : AuthStatus.authenticated,
              userId: me.userId,
            );
            if (me.needsNickname) {
              return;
            }
            _markAuthenticatedSideEffects();
            unawaited(
              ref.read(fcmRegistrationServiceProvider).syncServerRegistration(
                    promptForPermission: true,
                  ),
            );
            debugPrint('[AuthController] 로그인 성공, userId: ${me.userId}');
          } else {
            state = state.copyWith(
              isLoading: false,
              errorMessage: '토큰을 받지 못했습니다.',
            );
          }

        case AuthCallbackResult.cancelled:
          state = state.copyWith(isLoading: false, errorMessage: null);
        // debugPrint('[AuthController] 로그인 취소');

        case AuthCallbackResult.needsSignup:
          state = state.copyWith(
            isLoading: false,
            errorMessage: '추가 회원가입이 필요합니다.',
          );
        // debugPrint('[AuthController] 추가 회원가입 필요');

        case AuthCallbackResult.failed:
          final code = callbackData.errorCode ?? 'unknown';
          state = state.copyWith(
            isLoading: false,
            errorMessage: '로그인에 실패했습니다. ($code)',
          );
        // debugPrint('[AuthController] 로그인 실패: $code');

        case AuthCallbackResult.deletedUser:
          state = state.copyWith(
            isLoading: false,
            errorMessage: '탈퇴한 계정은 로그인할 수 없습니다.',
          );
      }
    } catch (e) {
      // debugPrint('[AuthController] 로그인 예외: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인 중 오류가 발생했습니다.',
      );
    }
  }

  Future<void> completeNicknameSetup(String nickname) async {
    final trimmed = nickname.trim();
    await _apiClient.patch<void>(
      ApiConstants.usersNameEndpoint,
      data: {'name': trimmed},
    );
    state = AuthState(status: AuthStatus.authenticated, userId: state.userId);
    _markAuthenticatedSideEffects();
  }

  Future<({int? userId, bool needsNickname})> _fetchAuthMe() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.authMeEndpoint,
    );
    final data = response.data ?? const <String, dynamic>{};
    final rawUserId = data['userId'];
    final userId = rawUserId is int
        ? rawUserId
        : int.tryParse(rawUserId?.toString() ?? '');
    return (userId: userId, needsNickname: data['needsNickname'] == true);
  }

  void _markAuthenticatedSideEffects() {
    _bumpSessionRefreshTick();
    unawaited(_authService.fetchAndSaveCloudFrontCookies());
  }

  /// 로그아웃
  Future<void> logout() async {
    await Future.wait([
      _authService.clearTokens(),
      _authService.clearCloudFrontCookies(),
    ]);
    state = const AuthState(status: AuthStatus.unauthenticated);
    _bumpSessionRefreshTick();
    // debugPrint('[AuthController] 로그아웃 완료');
  }

  /// 토큰 만료 시 강제 로그아웃 (401 인터셉터에서 호출)
  Future<void> forceLogout() async {
    await Future.wait([
      _authService.clearTokens(),
      _authService.clearCloudFrontCookies(),
    ]);
    state = const AuthState(status: AuthStatus.unauthenticated);
    _bumpSessionRefreshTick();
    // debugPrint('[AuthController] 토큰 만료 → 강제 로그아웃');
  }
}

/// 인증 컨트롤러 Provider
final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// 현재 로그인된 사용자 ID (미로그인 시 예외)
final currentUserIdProvider = Provider<int>((ref) {
  final userId = ref.watch(authProvider.select((s) => s.userId));
  if (userId == null) {
    throw StateError('로그인되지 않은 상태에서 userId 접근');
  }
  return userId;
});
