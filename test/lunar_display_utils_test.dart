import 'package:flutter_test/flutter_test.dart';
import 'package:toit/core/utils/lunar_display_utils.dart';

void main() {
  group('LunarDisplayUtils.formatLunarCaption', () {
    test('패키지 예시와 동일한 양→음 표기', () {
      expect(
        LunarDisplayUtils.formatLunarCaption(DateTime(2019, 8, 14)),
        '음력 7.14',
      );
      expect(
        LunarDisplayUtils.formatLunarCaption(DateTime(2020, 5, 3)),
        '음력 4.11',
      );
      expect(
        LunarDisplayUtils.formatLunarCaption(DateTime(2023, 8, 9)),
        '음력 6.23',
      );
    });

    test('음력 연도가 양력 연도와 다르면 음력 연도 포함', () {
      expect(
        LunarDisplayUtils.formatLunarCaption(DateTime(2026, 1, 1)),
        '음력 2025.11.13',
      );
    });

    test('지원 범위 밖은 안내 문구', () {
      expect(
        LunarDisplayUtils.formatLunarCaption(DateTime(1899, 12, 31)),
        '음력 (1900~2049만 표시)',
      );
      expect(
        LunarDisplayUtils.formatLunarCaption(DateTime(2050, 2, 1)),
        '음력 (1900~2049만 표시)',
      );
    });
  });
}
