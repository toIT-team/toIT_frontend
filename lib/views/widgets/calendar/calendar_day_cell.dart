import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/calendar_utils.dart';

/// 개별 날짜 셀 위젯
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.focusedMonth,
    this.isSelected = false,
    this.onTap,
    this.eventWidgets = const [],
    this.overflowCount = 0,
  });

  final DateTime date;
  final DateTime focusedMonth;
  final bool isSelected;
  final VoidCallback? onTap;
  final List<Widget> eventWidgets;
  final int overflowCount;

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = CalendarUtils.isSameMonth(date, focusedMonth);
    final isToday = CalendarUtils.isToday(date);
    final isSunday = CalendarUtils.isSunday(date);
    final isSaturday = CalendarUtils.isSaturday(date);

    Color textColor = isCurrentMonth
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);

    if (isSunday && isCurrentMonth) {
      textColor = AppTheme.sundayColor;
    } else if (isSaturday && isCurrentMonth) {
      textColor = AppTheme.saturdayColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Colors.grey.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 날짜 숫자
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday ? AppTheme.todayColor : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isToday ? Colors.white : textColor,
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 일정 표시 영역 (오버플로우 클리핑)
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...eventWidgets,
                    if (overflowCount > 0)
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 4, top: 1),
                        child: Text(
                          '+$overflowCount',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
