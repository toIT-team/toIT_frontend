import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/calendar_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/calendar_utils.dart';
import '../../../models/calendar/calendar_event.dart';
import 'calendar_constants.dart';
import 'calendar_day_cell.dart';
import 'event_chip.dart';

/// 캘린더 그리드 위젯 (날짜 + 일정 표시)
class CalendarGrid extends ConsumerWidget {
  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    this.onDayTap,
  });

  final DateTime focusedMonth;
  final void Function(DateTime)? onDayTap;

  /// 표시할 최대 일정 수
  static const int maxVisibleEvents = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 해당 월의 이벤트 인덱스만 watch (월별 캐시됨)
    final monthKey = getMonthKey(focusedMonth);
    final eventIndex = ref.watch(eventIndexFamilyProvider(monthKey));
    final days = CalendarUtils.getDaysInMonth(focusedMonth);

    return Column(
      children: [
        // 요일 헤더
        _buildWeekdayHeader(),
        // 날짜 그리드
        Expanded(
          child: _buildDaysGrid(context, days, eventIndex),
        ),
      ],
    );
  }

  /// 요일 헤더 위젯
  Widget _buildWeekdayHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(7, (index) {
          Color textColor = AppColors.gray600;
          if (index == 0) {
            textColor = AppTheme.sundayColor;
          } else if (index == 6) {
            textColor = AppTheme.saturdayColor;
          }

          return Expanded(
            child: Center(
              child: Text(
                CalendarUtils.weekdayHeaders[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 날짜 그리드 위젯
  Widget _buildDaysGrid(
    BuildContext context,
    List<DateTime> days,
    CalendarEventIndex eventIndex,
  ) {
    final bottomPad = calendarScrollBottomPadding(context);
    final weeks = <List<DateTime>>[];
    for (var i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: weeks
              .map((week) => _buildWeekRow(week, eventIndex))
              .toList(),
        ),
      ),
    );
  }

  /// 주 단위 행 높이 (날짜 + 이벤트 3개 + overflow 표시에 필요한 최소 높이 보장)
  static const double weekRowHeight = 104.0;

  /// 주 단위 행 위젯
  Widget _buildWeekRow(
    List<DateTime> week,
    CalendarEventIndex eventIndex,
  ) {
    return SizedBox(
      height: weekRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: week.asMap().entries.map((entry) {
          final dayIndex = entry.key;
          final date = entry.value;

          return Expanded(
            child: _OptimizedDayCell(
              date: date,
              dayIndex: dayIndex,
              week: week,
              focusedMonth: focusedMonth,
              eventIndex: eventIndex,
              onTap: () => onDayTap?.call(date),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 최적화된 날짜 셀 (selectedDate만 watch)
class _OptimizedDayCell extends ConsumerWidget {
  const _OptimizedDayCell({
    required this.date,
    required this.dayIndex,
    required this.week,
    required this.focusedMonth,
    required this.eventIndex,
    this.onTap,
  });

  final DateTime date;
  final int dayIndex;
  final List<DateTime> week;
  final DateTime focusedMonth;
  final CalendarEventIndex eventIndex;
  final VoidCallback? onTap;

  static const int maxVisibleEvents = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // selectedDate만 watch → 선택 변경 시 이 셀만 리빌드
    final selectedDate = ref.watch(selectedDateProvider);
    final isSelected =
        selectedDate != null && CalendarUtils.isSameDay(date, selectedDate);

    // O(1) 조회
    final dayEvents = eventIndex.getEventsForDay(date);
    final overflowCount = eventIndex.getOverflowCount(date);

    // 일정 위젯 생성
    final eventWidgets = _buildDayEventWidgets(dayEvents);

    return CalendarDayCell(
      date: date,
      focusedMonth: focusedMonth,
      isSelected: isSelected,
      onTap: onTap,
      eventWidgets: eventWidgets,
      overflowCount: overflowCount,
    );
  }

  /// 특정 날짜의 일정 위젯들 생성
  List<Widget> _buildDayEventWidgets(List<CalendarEvent> dayEvents) {
    if (dayEvents.isEmpty) return [];

    final widgets = <Widget>[];
    var lastSlot = -1;

    for (var i = 0; i < dayEvents.length && i < maxVisibleEvents; i++) {
      final event = dayEvents[i];
      final slot = eventIndex.getSlot(event.id);

      // 빈 슬롯 채우기
      for (var s = lastSlot + 1;
          s < slot && widgets.length < maxVisibleEvents;
          s++) {
        widgets.add(const SizedBox(height: 18));
      }

      if (widgets.length >= maxVisibleEvents) break;

      lastSlot = slot;

      // 일정의 시작/끝 여부 확인
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
      final currentDay = DateTime(date.year, date.month, date.day);
      final weekStartDay = DateTime(
        week.first.year,
        week.first.month,
        week.first.day,
      );
      final weekEndDay = DateTime(
        week.last.year,
        week.last.month,
        week.last.day,
      );

      final isStart = CalendarUtils.isSameDay(eventStart, currentDay) ||
          (CalendarUtils.isSameDay(weekStartDay, currentDay) &&
              eventStart.isBefore(weekStartDay));
      final isEnd = CalendarUtils.isSameDay(eventEnd, currentDay) ||
          (CalendarUtils.isSameDay(weekEndDay, currentDay) &&
              eventEnd.isAfter(weekEndDay));

      // 시작일에만 제목 표시
      final showTitle = CalendarUtils.isSameDay(eventStart, currentDay) ||
          (dayIndex == 0 && eventStart.isBefore(weekStartDay));

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: EventChip(
            event: event,
            isStart: isStart,
            isEnd: isEnd,
            showTitle: showTitle,
          ),
        ),
      );
    }

    return widgets;
  }
}
