import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/bootstrap_controller.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/splash/splash_background.dart';
import '../widgets/splash/splash_logo_block.dart';

/// 부트스트랩이 타임아웃/네트워크 오류로 실패했을 때 노출되는 재시도 화면.
///
/// 스플래시와 동일한 배경/로고 톤을 유지해 "아직 로그인 이전 단계" 라는
/// 인상을 해치지 않으면서, 하단 버튼으로 즉시 재시도만 제공한다.
class SplashRetryScreen extends ConsumerWidget {
  const SplashRetryScreen({super.key});

  static const _title = '네트워크 연결이 불안정해요';
  static const _body = '연결 상태를 확인하고 다시 시도해 주세요.';
  static const _buttonLabel = '다시 시도';

  static const _contentHorizontalPadding = 32.0;
  static const _messageTopGap = 28.0;
  static const _buttonBottomPadding = 40.0;
  static const _buttonHeight = 52.0;
  static const _buttonRadius = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = ref.watch(
      bootstrapProvider.select(
        (state) => state.status == BootstrapStatus.running,
      ),
    );

    return SplashBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _contentHorizontalPadding,
          ),
          child: Column(
            children: [
              const Spacer(),
              const SplashLogoBlock(),
              const SizedBox(height: _messageTopGap),
              const Text(
                _title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                _body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.neutral50,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              _RetryButton(
                onPressed: isRunning
                    ? null
                    : () {
                        debugPrint('[BOOT] retry_tapped source=splash_retry');
                        ref.read(bootstrapProvider.notifier).retry();
                      },
                isRunning: isRunning,
              ),
              const SizedBox(height: _buttonBottomPadding),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed, required this.isRunning});

  final VoidCallback? onPressed;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: SplashRetryScreen._buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.blue500,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.7),
          disabledForegroundColor: AppColors.blue500.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SplashRetryScreen._buttonRadius,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        child: isRunning
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue500),
                ),
              )
            : const Text(SplashRetryScreen._buttonLabel),
      ),
    );
  }
}
