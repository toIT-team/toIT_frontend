import 'package:flutter/material.dart';

/// 앱 전반에서 사용하는 색상 팔레트 (스케일 기반 디자인 토큰)
class AppColors {
  AppColors._();

  //Gray scale
  static const Color gray900 = Color(0xFF222222);
  static const Color gray600 = Color(0xFF80839C);
  static const Color gray400 = Color(0xFF999999);

  //Blue scale
  static const Color blue300 = Color(0xFFA2CAFF);
  static const Color blue400 = Color(0xFF99EDF7);
  static const Color blue500 = Color(0xFF379BFB);

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

  /// 그림자용 (카드 등)
  static const Color shadowCard = Color(0x14000000);
  static const Color shadowAccent = Color(0x0F132145);

  /// 바텀시트 등 모달 그림자
  static const Color shadowSheet = Color(0x29636363);

  /// 카드 그림자 (연한)
  static const Color shadowCardLight = Color(0x12000000);

  /// 바텀시트/모달 딤 배경
  static const Color overlayScrim = Color(0x293F3F3F);

  /// 다이얼로그 그림자
  static const Color overlayDialog = Color(0x0F000D43);

  /// 네비/팝업 그림자용 블루
  static const Color shadowNavBlue = Color(0xFF007CC9);
  static const Color shadowPopup = Color(0xFF000D43);

  /// 구분선 기본
  static const Color dividerDefault = Color(0xFFECECEC);

  /// 시트 등 연한 배경
  static const Color surfaceLight = Color(0xFFF5F5F5);

  /// 그라데이션용 연한 블루
  static const Color gradientLightBlue = Color(0xFFE6F1FF);

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

  /// 서버 전송용 토큰명 (folderColors와 동일 순서, snake_case)
  static const List<String> folderColorTokens = [
    'pink_200',
    'orange_200',
    'yellow_200',
    'green_200',
    'pink_100',
    'blue_300',
    'blue_400',
    'purple_500',
    'gray_200',
    'gray_100',
  ];

  /// 서버 color 문자열 → Color 변환 (토큰명 snake_case 또는 hex)
  static Color fromColorString(String value) {
    if (value.isEmpty) return folderColors[5];
    // hex 직접 파싱 (#FFA2A4 또는 FFA2A4 → Color)
    final hex = value.replaceFirst('#', '');
    final parsed = int.tryParse('FF$hex', radix: 16);
    if (parsed != null) return Color(parsed);
    // 토큰명으로 조회 (예: pink_200)
    final tokenIdx = folderColorTokens.indexOf(value);
    if (tokenIdx != -1) return folderColors[tokenIdx];
    return folderColors[5];
  }
}
