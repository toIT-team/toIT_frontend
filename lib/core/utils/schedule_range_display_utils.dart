import '../../models/calendar/calendar_event.dart';

/// 일정 기간·시간을 바텀시트 등에서 한 줄로 표시할 때 사용한다.
class ScheduleRangeDisplayUtils {
  ScheduleRangeDisplayUtils._();

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  /// [event]의 시작·종료를 한국어 한 줄로 반환한다.
  ///
  /// 시간 설정: `12월 24일(목) 오전 9:00~ 12월 25일(금) 오전 9:00` 형태.
  /// 같은 날이면 날짜를 숨기고 시간만 표시한다.
  /// 종일·단일일: `하루 종일`, 종일·복수일: `M월 d일(E) ~ M월 d일(E)`.
  static String formatEventRangeLine(CalendarEvent event) {
    final hasStartDate = _hasDateValue(event.startAt);
    final hasEndDate = _hasDateValue(event.endAt);
    final parsedStartDate = DateTime.tryParse(event.startAt);
    final parsedEndDate = DateTime.tryParse(event.endAt);
    final startDay = parsedStartDate != null
        ? DateTime(
            parsedStartDate.year,
            parsedStartDate.month,
            parsedStartDate.day,
          )
        : null;
    final endDay = parsedEndDate != null
        ? DateTime(
            parsedEndDate.year,
            parsedEndDate.month,
            parsedEndDate.day,
          )
        : null;
    final sameCalendarDay =
        startDay != null && endDay != null && startDay == endDay;

    if (!event.timeSetting) {
      if (sameCalendarDay) return '하루 종일';
      if (startDay == null || endDay == null) return '하루 종일';
      return '${_dateWithWeekday(startDay)} ~ ${_dateWithWeekday(endDay)}';
    }

    final startTimeStr = formatKoreanClock(event.startTime);
    final endTimeStr = formatKoreanClock(event.endTime);
    if (hasStartDate && !hasEndDate) {
      if (startTimeStr != null && endTimeStr != null) {
        return '$startTimeStr~ $endTimeStr';
      }
      return '하루 종일';
    }
    if (startTimeStr == null || endTimeStr == null) {
      if (sameCalendarDay) return '하루 종일';
      if (startDay == null || endDay == null) return '하루 종일';
      return '${_dateWithWeekday(startDay)} ~ ${_dateWithWeekday(endDay)}';
    }

    if (sameCalendarDay) {
      return '$startTimeStr~ $endTimeStr';
    }
    if (startDay == null || endDay == null) {
      return '$startTimeStr~ $endTimeStr';
    }

    final left = '${_dateWithWeekday(startDay)} $startTimeStr';
    final right = '${_dateWithWeekday(endDay)} $endTimeStr';
    return '$left~ $right';
  }

  /// `HH:mm` 또는 `HH:mm:ss` → `오전 9:00` / `오후 2:30`
  static String? formatKoreanClock(String? time) {
    if (time == null || time.isEmpty) return null;

    final parts = time.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1].padLeft(2, '0');

    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0
        ? 12
        : (hour > 12 ? hour - 12 : hour);

    return '$period $displayHour:$minute';
  }

  static String _dateWithWeekday(DateTime date) {
    final w = _weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일($w)';
  }

  static bool _hasDateValue(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty && normalized != 'null';
  }
}
