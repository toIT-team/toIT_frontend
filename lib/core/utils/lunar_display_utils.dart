import 'package:korean_lunar_utils/korean_lunar_utils.dart';

/// 캘린더 등에서 쓰는 음력 표기 문자열
class LunarDisplayUtils {
  LunarDisplayUtils._();

  /// 양력 [date]에 대응하는 음력 캡션 (1900-01-31 ~ 2049-12-31).
  ///
  /// `korean_lunar_utils` 범위 밖이면 범위 안내 문구를 반환한다.
  /// 윤달 접두어는 공개 API에서 윤 여부를 받지 못해 생략한다.
  static String formatLunarCaption(DateTime date) {
    final solar = DateTime(date.year, date.month, date.day);
    try {
      final lunar = LunarSolarConverter.convertSolarToLunar(solar);
      final y = lunar.year;
      final m = lunar.month;
      final d = lunar.day;
      if (y != date.year) {
        return '음력 $y.$m.$d';
      }
      return '음력 $m.$d';
    } on RangeError {
      return '음력 (1900~2049만 표시)';
    }
  }
}
