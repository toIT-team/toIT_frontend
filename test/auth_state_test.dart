import 'package:flutter_test/flutter_test.dart';
import 'package:toit/controllers/auth_controller.dart';

void main() {
  test('AuthState 기본값에서 activeSocialLogin은 null', () {
    expect(const AuthState().activeSocialLogin, isNull);
    expect(const AuthState().isLoading, isFalse);
  });

  test('copyWith로 activeSocialLogin 설정·해제', () {
    const base = AuthState(status: AuthStatus.unauthenticated);
    final withKakao = base.copyWith(
      isLoading: true,
      activeSocialLogin: SocialLoginKind.kakao,
    );
    expect(withKakao.activeSocialLogin, SocialLoginKind.kakao);
    expect(withKakao.isLoading, isTrue);

    final cleared = withKakao.copyWith(isLoading: false, errorMessage: null);
    expect(cleared.activeSocialLogin, isNull);
    expect(cleared.isLoading, isFalse);
  });
}
