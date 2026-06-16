import 'dart:math' as math;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthKey = getMonthKey(focusedMonth);
    final eventIndex = ref.watch(eventIndexFamilyProvider(monthKey));
    final days = CalendarUtils.getDaysInMonth(focusedMonth);

    return Column(
      children: [
        _buildWeekdayHeader(),
        Expanded(
          child: _buildDaysGrid(context, days, eventIndex),
        ),
      ],
    );
  }

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
              .map(
                (week) => _CalendarWeekRow(
                  week: week,
                  focusedMonth: focusedMonth,
                  eventIndex: eventIndex,
                  onDayTap: onDayTap,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// 주 단위 행 (날짜 셀 + 연속 이벤트 바 오버레이)
class _CalendarWeekRow extends ConsumerWidget {
  const _CalendarWeekRow({
    required this.week,
    required this.focusedMonth,
    required this.eventIndex,
    this.onDayTap,
  });

  final List<DateTime> week;
  final DateTime focusedMonth;
  final CalendarEventIndex eventIndex;
  final void Function(DateTime)? onDayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 이 주에 실제로 쌓인 칩 줄 수만큼 행 높이를 동적으로 확보한다.
    final eventRows = math.max(
      kCalendarMinEventRows,
      eventIndex.getEventRowCountForWeek(week.first),
    );
    final eventAreaHeight = calendarEventAreaHeight(eventRows);

    return SizedBox(
      height: calendarWeekRowHeight(eventRows),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: week
                .map(
                  (date) => Expanded(
                    child: _WeekDayCell(
                      date: date,
                      focusedMonth: focusedMonth,
                      eventAreaHeight: eventAreaHeight,
                      onTap: () => onDayTap?.call(date),
                    ),
                  ),
                )
                .toList(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: kCalendarWeekEventLayerTop,
            height: eventAreaHeight,
            // 이벤트 레이어는 표시 전용이므로 터치를 아래 날짜 셀로 통과시킨다.
            child: IgnorePointer(
              child: _WeekEventLayer(
                week: week,
                eventIndex: eventIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 날짜 셀 (selectedDate만 watch)
class _WeekDayCell extends ConsumerWidget {
  const _WeekDayCell({
    required this.date,
    required this.focusedMonth,
    required this.eventAreaHeight,
    this.onTap,
  });

  final DateTime date;
  final DateTime focusedMonth;
  final double eventAreaHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final isSelected =
        selectedDate != null && CalendarUtils.isSameDay(date, selectedDate);
    // '+N' 표시용 오버플로우 카운트 (현재 비활성화).
    // 복구하려면 이 위젯에 eventIndex 를 다시 주입하고 CalendarDayCell 로 전달
    // final overflowCount = eventIndex.getOverflowCount(date);

    return CalendarDayCell(
      date: date,
      focusedMonth: focusedMonth,
      eventAreaHeight: eventAreaHeight,
      isSelected: isSelected,
      onTap: onTap,
      // overflowCount: overflowCount,
    );
  }
}

/// 주 단위 연속 이벤트 바 레이어
class _WeekEventLayer extends StatelessWidget {
  const _WeekEventLayer({
    required this.week,
    required this.eventIndex,
  });

  final List<DateTime> week;
  final CalendarEventIndex eventIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7;
        final bars = _buildWeekEventBars(cellWidth);

        return Stack(
          clipBehavior: Clip.none,
          children: bars,
        );
      },
    );
  }

  List<Widget> _buildWeekEventBars(double cellWidth) {
    final weekStart = week.first;
    final segments = eventIndex.getSegmentsForWeek(weekStart)
      ..sort((a, b) => a.slot.compareTo(b.slot));

    // 이벤트별로 이 주에서 처음 보이는(가장 왼쪽) 구간에만 제목을 표시한다.
    final titleStartColByEvent = <String, int>{};
    for (final segment in segments) {
      // 표시 개수 제한 (현재 무제한 표시로 비활성화).
      // if (segment.slot >= kCalendarMaxVisibleEvents) continue;
      final current = titleStartColByEvent[segment.event.id];
      if (current == null || segment.startCol < current) {
        titleStartColByEvent[segment.event.id] = segment.startCol;
      }
    }

    final bars = <Widget>[];

    for (final segment in segments) {
      // 표시 개수 제한 (현재 무제한 표시로 비활성화).
      // if (segment.slot >= kCalendarMaxVisibleEvents) continue;
      final barInfo = _weekEventBarInfo(
        event: segment.event,
        week: week,
        startCol: segment.startCol,
        endCol: segment.endCol,
      );
      final showTitle =
          titleStartColByEvent[segment.event.id] == segment.startCol;

      final left = segment.startCol * cellWidth;
      final width = (segment.endCol - segment.startCol + 1) * cellWidth;
      final top = kCalendarEventChipTopPadding +
          segment.slot * kCalendarEventSlotHeight;

      bars.add(
        Positioned(
          left: left,
          top: top,
          width: width,
          height: kCalendarEventChipHeight,
          child: EventChip(
            event: segment.event,
            isStart: barInfo.isStart,
            isEnd: barInfo.isEnd,
            showTitle: showTitle,
          ),
        ),
      );
    }

    return bars;
  }
}

class _WeekEventBarInfo {
  const _WeekEventBarInfo({
    required this.isStart,
    required this.isEnd,
  });

  final bool isStart;
  final bool isEnd;
}

_WeekEventBarInfo _weekEventBarInfo({
  required CalendarEvent event,
  required List<DateTime> week,
  required int startCol,
  required int endCol,
}) {
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
  final segmentStartDay = DateTime(
    week[startCol].year,
    week[startCol].month,
    week[startCol].day,
  );
  final segmentEndDay = DateTime(
    week[endCol].year,
    week[endCol].month,
    week[endCol].day,
  );

  final isStart = !eventStart.isAfter(segmentStartDay);
  final isEnd = !eventEnd.isBefore(segmentEndDay);

  return _WeekEventBarInfo(
    isStart: isStart,
    isEnd: isEnd,
  );
}
