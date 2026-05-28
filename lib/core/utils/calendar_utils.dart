import '../../models/calendar/calendar_event.dart';

/// 캘린더 유틸리티 함수 모음
class CalendarUtils {
  CalendarUtils._();

  /// 해당 월의 모든 날짜 리스트 반환 (이전/다음 달 날짜 포함)
  /// 캘린더 그리드에 표시할 주 단위 날짜를 반환
  static List<DateTime> getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // 첫 번째 날의 요일 (일요일 = 0)
    final firstWeekday = firstDayOfMonth.weekday % 7;

    // 캘린더 시작일 (이전 달 포함)
    final startDate = firstDayOfMonth.subtract(Duration(days: firstWeekday));

    // 필요한 주 수 계산 (최소 5주, 최대 6주)
    final daysInMonth = lastDayOfMonth.day;
    final totalCells = firstWeekday + daysInMonth;
    final weeks = (totalCells / 7).ceil().clamp(5, 6);
    final totalDays = weeks * 7;

    return List.generate(
      totalDays,
      (index) => startDate.add(Duration(days: index)),
    );
  }

  /// 해당 월의 주(week) 수 계산
  static int getWeeksInMonth(DateTime month) {
    final days = getDaysInMonth(month);
    return (days.length / 7).ceil();
  }

  /// 특정 날짜가 해당 월에 속하는지 확인
  static bool isSameMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  /// 두 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// 일요일인지 확인
  static bool isSunday(DateTime date) {
    return date.weekday == DateTime.sunday;
  }

  /// 토요일인지 확인
  static bool isSaturday(DateTime date) {
    return date.weekday == DateTime.saturday;
  }

  /// 특정 날짜에 해당하는 일정 목록 반환
  static List<CalendarEvent> getEventsForDay(
    DateTime day,
    List<CalendarEvent> events,
  ) {
    return events.where((event) => event.occursOnDay(day)).toList();
  }

  /// 특정 주에 해당하는 일정 목록 반환
  static List<CalendarEvent> getEventsForWeek(
    DateTime weekStart,
    List<CalendarEvent> events,
  ) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return events.where((event) {
      final eventStart = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      final eventEnd = DateTime(
        event.endDate.year,
        event.endDate.month,
        event.endDate.day,
      );

      return eventStart.isBefore(weekEnd.add(const Duration(days: 1))) &&
          eventEnd.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).toList();
  }

  /// 이전 달 계산
  static DateTime getPreviousMonth(DateTime month) {
    return DateTime(month.year, month.month - 1, 1);
  }

  /// 다음 달 계산
  static DateTime getNextMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 1);
  }

  /// 월 포맷 (예: 2025.12)
  static String formatMonth(DateTime month) {
    return '${month.year}.${month.month.toString().padLeft(2, '0')}';
  }

  /// 요일 헤더 (일~토)
  static const List<String> weekdayHeaders = [
    '일',
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
  ];
}
