import 'package:flutter/material.dart';

/// 일반 UI용 색상 토큰 (CSS 토큰 스타일)
/// 일정 색상 제외, UI 전반에 쓰이는 색상
/// 수정 시 이 파일만 변경하면 됨
class AppColorTokens {
  AppColorTokens._();

  // grey scale
  static const Color grey900 = Color(0xFF222222);
  static const Color grey600 = Color(0xFF80839C);
  static const Color grey400 = Color(0xFF999999);
  static const Color grey200 = Color(0xFFC2B7AD);
  static const Color grey100 = Color(0xFFDADADA);
  static const Color grey50 = Color(0xFFF4F6F8);

  // neutral
  static const Color neutral50 = Color(0xFFEEEEEE);
  static const Color neutral100 = Color(0xFFDDDDDD);
  static const Color neutral200 = Color(0xFF2E9EFA);

  // blue (primary 등)
  static const Color blue500 = Color(0xFF379BFB);
  static const Color red500 = Color(0xFFFB373E);
}
