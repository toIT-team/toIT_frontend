import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      final previousToken = prev?.pendingRestoreToken;
      final nextToken = next.pendingRestoreToken;
      if (nextToken != null && nextToken != previousToken) {
        _showRestoreDialog(context: context, ref: ref, restoreToken: nextToken);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 배경 블러 그라데이션 (하단)
          Positioned(
            left: -37,
            bottom: -100,
            child: Container(
              width: 449,
              height: 449,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(0.26, 0.5),
                  radius: 1.53,
                  colors: [
                    const Color(0xFF379BFB).withValues(alpha: 0.07),
                    const Color(0xFF379BFB).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // 배경 블러 그라데이션 (상단)
          Positioned(
            left: -37,
            top: -341,
            child: Container(
              width: 449,
              height: 449,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(0.26, 0.5),
                  radius: 1.53,
                  colors: [
                    const Color(0xFF379BFB).withValues(alpha: 0),
                    const Color(0xFF379BFB).withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                _buildLogoSection(),
                const Spacer(flex: 4),
                _buildKakaoButton(ref: ref, isLoading: authState.isLoading),
                const SizedBox(height: 12),
                _buildAppleButton(ref: ref, isLoading: authState.isLoading),
                const SizedBox(height: 24),
                _buildSupportRow(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/icons/ToitLogoIcon.png', width: 84, height: 84),
        const SizedBox(height: 13),
        SvgPicture.asset(
          'assets/icons/ToitLogoText.svg',
          width: 64,
          height: 24,
        ),
        const SizedBox(height: 20),
        const Text(
          '모든 자료들을 한 번에 저장,\n자료를 던지면 계획으로 실행하세요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: -0.4,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }

  Widget _buildKakaoButton({required WidgetRef ref, required bool isLoading}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: GestureDetector(
          onTap: isLoading
              ? null
              : () => ref.read(authProvider.notifier).loginWithKakao(),
          child: isLoading
              ? Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE500),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF23222D),
                      ),
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/kakaoLoginLargeWide.png',
                    fit: BoxFit.contain,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAppleButton({required WidgetRef ref, required bool isLoading}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: Material(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: isLoading
                ? null
                : () => ref.read(authProvider.notifier).loginWithApple(),
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.apple, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Apple로 계속하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportRow() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '문제가 있으신가요?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: -0.4,
            color: AppColors.gray600,
          ),
        ),
        SizedBox(width: 8),
        Text(
          '고객 지원',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: -0.4,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }

  Future<void> _showRestoreDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String restoreToken,
  }) async {
    final shouldRestore = await showGeneralDialog<bool>(
      context: context,
      barrierLabel: 'restore',
      barrierDismissible: true,
      barrierColor: const Color(0x33222222),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, _, __) {
        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 335,
                  height: 165,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral50, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000D43),
                        offset: Offset(0, 2),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Text(
                          '탈퇴한 계정입니다',
                          style: TextStyle(
                            color: AppColors.gray900,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.45,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                        child: Text(
                          '복구하시겠습니까?',
                          style: TextStyle(
                            color: AppColors.gray600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.4,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(false);
                              },
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                shape: const RoundedRectangleBorder(),
                              ),
                              child: const Text(
                                '취소',
                                style: TextStyle(
                                  color: AppColors.blue500,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.45,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(true);
                              },
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                shape: const RoundedRectangleBorder(),
                              ),
                              child: const Text(
                                '복구',
                                style: TextStyle(
                                  color: AppColors.blue500,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.45,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!context.mounted) return;
    if (shouldRestore == true) {
      await ref
          .read(authProvider.notifier)
          .restoreDeletedAccount(restoreToken: restoreToken);
      return;
    }
    ref.read(authProvider.notifier).clearPendingRestoreToken();
  }
}
