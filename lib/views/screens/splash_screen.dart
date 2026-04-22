import 'package:flutter/material.dart';

import '../widgets/splash/splash_background.dart';
import '../widgets/splash/splash_logo_block.dart';

/// 콜드 스타트 직후 부트스트랩이 끝나기 전까지 노출되는 스플래시 화면.
///
/// 인증·네트워크 판정은 `BootstrapController` 가 담당하므로 이 위젯은
/// 브랜드 연출만 담당하는 정적 화면이다.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashBackground(child: Center(child: SplashLogoBlock()));
  }
}
