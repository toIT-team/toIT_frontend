import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';

/// 콜드 스타트 직후 `AuthStatus.unknown` 구간 동안 노출되는 스플래시 화면.
///
/// 부트스트랩(로컬 토큰 확인 등)이 끝나기 전까지 브랜드 연출만 담당하는 정적
/// 화면이다. 인증 판정은 `AuthController.checkAuthStatus()`에서 수행되므로
/// 이 위젯은 네트워크 호출이나 상태 변경을 직접 하지 않는다.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
            children: const [
              _TopLeftBlurEllipse(),
              Center(child: _LogoBlock()),
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

/// 로고 이미지와 서브 카피를 세로로 쌓은 중앙 블록.
///
/// 피그마 기준 가운데 정렬 위치에서 세로로 -12px, 가로로 +0.5px 만큼 살짝
/// 보정된다.
class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

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
