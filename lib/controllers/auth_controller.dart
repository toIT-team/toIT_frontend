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

/// 인증 상태 + 부가 정보
class AuthState {
  final AuthStatus status;
  final bool isLoading;
  final String? errorMessage;

  /// JWT에서 추출한 실제 사용자 ID
  final int? userId;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.isLoading = false,
    this.errorMessage,
    this.userId,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? errorMessage,
    int? userId,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
    );
  }
}

/// 인증 상태를 관리하는 Notifier
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthService get _authService => ref.read(authServiceProvider);

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

  /// 카카오 로그인 시작
  Future<void> loginWithKakao() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final callbackData = await _authService.loginWithKakao();

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
    debugPrint('[AuthController] 로그아웃 완료');
  }

  /// 토큰 만료 시 강제 로그아웃 (401 인터셉터에서 호출)
  Future<void> forceLogout() async {
    await _authService.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
    debugPrint('[AuthController] 토큰 만료 → 강제 로그아웃');
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
