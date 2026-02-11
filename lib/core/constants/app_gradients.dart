import 'package:flutter/material.dart';

/// 앱에서 사용하는 그라데이션 정의
class AppGradients {
  AppGradients._();

  // 메인 화면 배경용 래디얼 그라데이션
  static const RadialGradient homeBackground = RadialGradient(
    colors: [Color(0xFFE6F1FF), Color(0xFFF4F6F9)],
    stops: [0.0, 0.2786],
    center: Alignment(0.816, -1.0),
    radius: 2.0,
  );
}
