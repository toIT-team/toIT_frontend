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

  /// 검색 결과 부제: 유형 태그 + (선택) 보관함명 · 요일/메타 · 날짜
  static String composeSearchSubtitle({
    required String typeTag,
    String? foldersName,
    String? dayOfWeek,
    String? isoTimestamp,
    String? calendarDate,
  }) {
    final meta = <String>[];
    if (foldersName != null && foldersName.isNotEmpty) {
      meta.add(foldersName);
    }
    if (dayOfWeek != null && dayOfWeek.isNotEmpty) {
      meta.add(dayOfWeek);
    }
    if (isoTimestamp != null && isoTimestamp.isNotEmpty) {
      final d = formatDateFromIso(isoTimestamp);
      if (d.isNotEmpty) meta.add(d);
    } else if (calendarDate != null && calendarDate.isNotEmpty) {
      final d = formatDateSubtitle(calendarDate);
      if (d.isNotEmpty) meta.add(d);
    }
    if (meta.isEmpty) return typeTag;
    return '$typeTag | ${meta.join(' · ')}';
  }
}
