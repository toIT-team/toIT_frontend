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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
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
                _buildKakaoButton(
                  ref: ref,
                  isLoading: authState.isLoading,
                ),
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
        Image.asset(
          'assets/icons/ToitLogoIcon.png',
          width: 84,
          height: 84,
        ),
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

  Widget _buildKakaoButton({
    required WidgetRef ref,
    required bool isLoading,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: GestureDetector(
          onTap: isLoading
              ? null
              : () => ref
                  .read(authProvider.notifier)
                  .loginWithKakao(),
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
                    'assets/icons/KakaoLoginMedium.png',
                    fit: BoxFit.contain,
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
}
