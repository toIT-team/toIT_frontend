import 'package:flutter/material.dart';

/// 앱 테마 설정
class AppTheme {
  AppTheme._();

  // 캘린더 색상
  static const Color sundayColor = Color(0xFFE53935);
  static const Color saturdayColor = Color(0xFF1E88E5);
  static const Color todayColor = Color(0xFF4285F4);
  static const Color selectedDayColor = Color(0xFF4285F4);

  // 일정 기본 색상
  static const List<Color> eventColors = [
    Color(0xFF4285F4), // 파랑
    Color(0xFFFBBC04), // 노랑
    Color(0xFFB9EF9B), // 초록
    Color(0xFFEA4335), // 빨강
    Color(0xFF9C27B0), // 보라
    Color(0xFFFF9800), // 주황
    Color(0xFF00BCD4), // 청록
    Color(0xFF795548), // 갈색
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
    );
  }
}
