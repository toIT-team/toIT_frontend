import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';

/// 스플래시/재시도 화면이 공유하는 배경 레이어.
///
/// 그라디언트 + 좌상단 블러 ellipse + 라이트 오버레이 상태바까지 담당하며,
/// 컨텐츠(로고, 버튼 등)는 [child] 로 주입받는다.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child});

  final Widget child;

  static const _backgroundTop = Color(0xFF3198FC);
  static const _backgroundBottom = Color(0xFF158AFF);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.45, 1.0],
              colors: [_backgroundTop, _backgroundBottom],
            ),
          ),
          child: Stack(
            children: [
              const _TopLeftBlurEllipse(),
              Positioned.fill(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// 좌상단에 깔리는 연한 블루 블러 장식 (피그마: Ellipse 25).
class _TopLeftBlurEllipse extends StatelessWidget {
  const _TopLeftBlurEllipse();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: -37,
      top: -341,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            width: 449,
            height: 449,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(0.26, 0.5),
                radius: 1.53,
                colors: [
                  AppColors.blue500.withValues(alpha: 0),
                  AppColors.blue500.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
