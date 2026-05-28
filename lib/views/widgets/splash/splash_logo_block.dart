import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 로고 이미지 + 서브 카피를 세로로 쌓은 중앙 블록.
///
/// 스플래시와 재시도 화면에서 동일한 브랜드 블록을 유지하기 위해 분리했다.
/// 피그마 기준 가운데 정렬 위치에서 세로로 -12px, 가로로 +0.5px 만큼 살짝
/// 보정된다.
class SplashLogoBlock extends StatelessWidget {
  const SplashLogoBlock({super.key});

  static const _logoAsset = 'assets/icons/ToitLogoTextIcon.png';
  static const _logoWidth = 114.0;
  static const _logoHeight = 42.15;
  static const _subtitleGap = 10.0;
  static const _verticalOffset = -12.0;
  static const _horizontalOffset = 0.5;
  static const _subtitle = '저장부터 일정까지';
  static const _subtitleSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(_horizontalOffset, _verticalOffset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            child: Image.asset(
              _logoAsset,
              width: _logoWidth,
              height: _logoHeight,
            ),
          ),
          const SizedBox(height: _subtitleGap),
          const Text(
            _subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _subtitleSize,
              fontWeight: FontWeight.w600,
              height: 1.5,
              letterSpacing: -0.4,
              color: AppColors.neutral50,
            ),
          ),
        ],
      ),
    );
  }
}
