import 'package:flutter/material.dart';

/// 앱 전반에서 사용하는 색상 팔레트 (스케일 기반 디자인 토큰)
class AppColors {
  AppColors._();

  //Gray scale
  static const Color gray900 = Color(0xFF222222);
  static const Color gray600 = Color(0xFF80839C);
  static const Color gray400 = Color(0xFF999999);

  //Blue scale
  static const Color blue300 = Color(0xFFA2CAFF); // 재윤
  static const Color blue400 = Color(0xFF99EDF7); // 재윤
  static const Color blue500 = Color(0xFF379BFB); // 원철

  //Pink scale
  static const Color pink100 = Color(0xFFFFB9DD);
  static const Color pink200 = Color(0xFFFFA2A4);

  //Orange scale
  static const Color orange200 = Color(0xFFFFC6A2);

  //Yellow scale
  static const Color yellow200 = Color(0xFFFEEC88);

  //Green scale
  static const Color green200 = Color(0xFFB6F394);

  //Neutral scale
  static const Color neutral50 = Color(0xFFEEEEEE);
  static const Color neutral100 = Color(0xFFDDDDDD);
  static const Color neutral200 = Color(0xFF2E9EFA);
  static const Color neutral300 = Color(0xFFF4F6F8);

  //Red scale
  static const Color red500 = Color(0xFFFB373E);

  //Purple scale
  static const Color purple500 = Color(0xFFC4A2FF);

  //Gray scale
  static const Color gray200 = Color(0xFFC2B7AD);
  static const Color gray100 = Color(0xFFDADADA);

  // ─── 비토큰 시맨틱 색상 (토큰 정의 전까지 유지) ───
  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF2F6FED);
  static const Color secondary = Color(0xFF7BA7FF);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color chipBg = Color(0xFFEFF2F7);
  static const Color badge = Color(0xFFE63E46);
  static const Color borderLight = Color(0xFFD9D9D9);
  static const Color overlayWhite90 = Color(0xE6FFFFFF);

  //보관함 색상 목록
  static const List<Color> folderColors = [
    pink200, // #FFA2A4
    orange200, // #FFC6A2
    yellow200, // #FEEC88
    green200, // #B6F394
    pink100, // #FFB9DD
    blue300, // #A2CAFF
    blue400, // #99EDF7
    purple500, // #C4A2FF
    gray200, // #C2B7AD
    gray100, // #DADADA
  ];
}
