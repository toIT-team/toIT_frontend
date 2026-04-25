import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/event_color_tokens.dart';

/// 앱 테마 설정
class AppTheme {
  AppTheme._();

  // 캘린더 색상
  static const Color sundayColor = Color(0xFFE53935);
  static const Color saturdayColor = Color(0xFF1E88E5);
  static const Color todayColor = Color(0xFF4285F4);
  static const Color selectedDayColor = Color(0xFF4285F4);

  /// 일정 색상 토큰 목록 (색상 선택 UI용)
  /// EventColorTokens.pickerEntries 사용 권장
  static List<({EventColorToken token, Color color})> get eventColors =>
      EventColorTokens.pickerEntries;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
    ).copyWith(
      surface: AppColors.surface,
      surfaceTint: Colors.transparent,
    );
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: colorScheme,
      dialogTheme: const DialogThemeData(
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.loadingIndicator,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.loadingIndicator,
      ),
    );
  }
}
