/// 검색 관련 유틸리티
class SearchUtils {
  SearchUtils._();

  static const List<String> _weekdayKo = [
    '일', '월', '화', '수', '목', '금', '토',
  ];

  /// "2025-12-25" → "2025.12.25 (목)"
  static String formatDateSubtitle(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final weekday = date.weekday % 7;
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')} (${_weekdayKo[weekday]})';
  }

  /// "2025-12-25T12:00:00Z" → "2025.12.25 (목)"
  static String formatDateFromIso(String? isoStr) {
    if (isoStr == null || isoStr.isEmpty) return '';
    final date = DateTime.tryParse(isoStr);
    if (date == null) return isoStr;
    final weekday = date.weekday % 7;
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')} (${_weekdayKo[weekday]})';
  }
}
