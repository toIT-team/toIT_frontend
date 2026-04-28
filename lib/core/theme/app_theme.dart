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

  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    width: 335,
    elevation: 0,
    backgroundColor: Color(0x99222222),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    insetPadding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
    contentTextStyle: TextStyle(
      fontFamily: 'Pretendard Variable',
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.4,
      letterSpacing: -0.45,
      color: Colors.white,
    ),
  );

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
      // deepPurple 시드의 primary가 커서·선택 UI에 쓰이지 않도록 고정
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.blue500,
        selectionHandleColor: AppColors.blue500,
        selectionColor: AppColors.blue500.withValues(alpha: 0.22),
      ),
      dialogTheme: const DialogThemeData(
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.loadingIndicator,
      ),
      snackBarTheme: _snackBarTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.blue500,
        selectionHandleColor: AppColors.blue500,
        selectionColor: AppColors.blue500.withValues(alpha: 0.35),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.loadingIndicator,
      ),
      snackBarTheme: _snackBarTheme,
    );
  }
}
