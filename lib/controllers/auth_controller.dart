import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// 인증 상태
enum AuthStatus {
  /// 아직 토큰 확인 전
  unknown,

  /// 로그인 완료 (토큰 보유)
  authenticated,

  /// 미로그인 (토큰 없음)
  unauthenticated,
}

/// 인증 세션 변경(로그인/로그아웃/복구) 시 캐시 갱신 트리거
final authSessionRefreshTickProvider =
    StateProvider<int>((ref) => 0);

/// 인증 상태 + 부가 정보
class AuthState {
  final AuthStatus status;
  final bool isLoading;
  final String? errorMessage;
  final String? pendingRestoreToken;

  /// JWT에서 추출한 실제 사용자 ID
  final int? userId;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.isLoading = false,
    this.errorMessage,
    this.pendingRestoreToken,
    this.userId,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? errorMessage,
    String? pendingRestoreToken,
    int? userId,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      pendingRestoreToken: pendingRestoreToken,
      userId: userId ?? this.userId,
    );
  }
}

/// 인증 상태를 관리하는 Notifier
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthService get _authService => ref.read(authServiceProvider);

  void _bumpSessionRefreshTick() {
    final notifier = ref.read(
      authSessionRefreshTickProvider.notifier,
    );
    notifier.state = notifier.state + 1;
  }

  /// 앱 시작 시 저장된 토큰이 있으면 인증 상태 복원
  Future<void> checkAuthStatus() async {
    final hasTokens = await _authService.hasTokens();
    if (hasTokens) {
      final userId = await _authService.getUserIdFromToken();
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: userId,
      );
    } else {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
      );
    }
    debugPrint(
      '[AuthController] 인증 상태: ${state.status}'
      ', userId: ${state.userId}',
    );
  }

  /// 카카오 로그인 (백엔드 OAuth → 동일 콜백 규약)
  Future<void> loginWithKakao() async {
    await _runSocialLogin(_authService.loginWithKakao);
  }

  /// 애플 로그인 (백엔드 OAuth → 동일 콜백 규약)
  Future<void> loginWithApple() async {
    await _runSocialLogin(_authService.loginWithApple);
  }

  Future<void> _runSocialLogin(
    Future<AuthCallbackData> Function() login,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

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
            final userId =
                await _authService.getUserIdFromToken();
            state = AuthState(
              status: AuthStatus.authenticated,
              userId: userId,
            );
            _bumpSessionRefreshTick();
            debugPrint(
              '[AuthController] 로그인 성공, userId: $userId',
            );
          } else {
            state = state.copyWith(
              isLoading: false,
              errorMessage: '토큰을 받지 못했습니다.',
            );
          }

        case AuthCallbackResult.cancelled:
          state = state.copyWith(isLoading: false, errorMessage: null);
          debugPrint('[AuthController] 로그인 취소');

        case AuthCallbackResult.needsSignup:
          state = state.copyWith(
            isLoading: false,
            errorMessage: '추가 회원가입이 필요합니다.',
          );
          debugPrint('[AuthController] 추가 회원가입 필요');

        case AuthCallbackResult.failed:
          final code = callbackData.errorCode ?? 'unknown';
          state = state.copyWith(
            isLoading: false,
            errorMessage: '로그인에 실패했습니다. ($code)',
          );
          debugPrint('[AuthController] 로그인 실패: $code');

        case AuthCallbackResult.deletedUser:
          final restoreToken = callbackData.restoreToken;
          if (restoreToken == null || restoreToken.isEmpty) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: '복구 토큰이 없어 로그인할 수 없습니다.',
            );
            return;
          }
          state = AuthState(
            status: AuthStatus.unauthenticated,
            isLoading: false,
            pendingRestoreToken: restoreToken,
          );
      }
    } catch (e) {
      debugPrint('[AuthController] 로그인 예외: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인 중 오류가 발생했습니다.',
      );
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    await _authService.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
    _bumpSessionRefreshTick();
    debugPrint('[AuthController] 로그아웃 완료');
  }

  /// 토큰 만료 시 강제 로그아웃 (401 인터셉터에서 호출)
  Future<void> forceLogout() async {
    await _authService.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
    _bumpSessionRefreshTick();
    debugPrint('[AuthController] 토큰 만료 → 강제 로그아웃');
  }

  void clearPendingRestoreToken() {
    state = AuthState(
      status: state.status,
      isLoading: state.isLoading,
      errorMessage: state.errorMessage,
      userId: state.userId,
      pendingRestoreToken: null,
    );
  }

  Future<void> restoreDeletedAccount({
    required String restoreToken,
  }) async {
    state = AuthState(
      status: AuthStatus.unauthenticated,
      isLoading: true,
      errorMessage: null,
      pendingRestoreToken: restoreToken,
    );
    final restored = await _authService.restoreDeletedAccount(
      restoreToken: restoreToken,
    );
    if (restored == null ||
        restored.accessToken == null ||
        restored.refreshToken == null) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: '계정 복구에 실패했습니다.',
      );
      return;
    }

    await _authService.saveTokens(
      accessToken: restored.accessToken!,
      refreshToken: restored.refreshToken!,
    );
    final userId = await _authService.getUserIdFromToken();
    state = AuthState(
      status: AuthStatus.authenticated,
      isLoading: false,
      userId: userId,
    );
    _bumpSessionRefreshTick();
    debugPrint('[AuthController] 계정 복구 및 로그인 성공, userId: $userId');
  }
}

/// 인증 컨트롤러 Provider
final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// 현재 로그인된 사용자 ID (미로그인 시 예외)
final currentUserIdProvider = Provider<int>((ref) {
  final userId = ref.watch(
    authProvider.select((s) => s.userId),
  );
  if (userId == null) {
    throw StateError('로그인되지 않은 상태에서 userId 접근');
  }
  return userId;
});
