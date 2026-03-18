import 'package:flutter/material.dart';

/// 설정 레이아웃 1 토큰
///
/// 보관함 추가, 위치, 알림, 메모 등 아이콘-타이틀-아이콘 구조의
/// 설정 행에 공통 적용되는 크기/간격 상수.
/// 동일한 틀을 사용하여 컴포넌트 크기 일관성 유지.
class SettingLayout1Tokens {
  SettingLayout1Tokens._();

  /// 행 최소 높이 (아이콘-타이틀-아이콘 전체)
  static const double rowMinHeight = 24.0;

  /// 선행 아이콘 크기
  static const double leadingIconSize = 24.0;

  /// 후행 아이콘 크기
  static const double trailingIconSize = 22.0;

  /// 선행 아이콘과 타이틀 사이 간격
  static const double iconTitleGap = 16.0;

  /// 행 상하 패딩
  static const double verticalPadding = 16.0;

  /// 행 좌우 패딩
  static const double horizontalPadding = 20.0;

  /// 타이틀/내용 폰트 크기
  static const double fontSize = 16.0;

  /// 설정 섹션 아이콘 색상 (보관함, 위치, 알림, 메모 통일)
  static const Color sectionIconColor = Color(0xFF379BFB);
}
