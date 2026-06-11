import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/calendar_utils.dart';
import 'calendar_constants.dart';

/// 개별 날짜 셀 위젯
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.focusedMonth,
    this.isSelected = false,
    this.onTap,
    this.overflowCount = 0,
  });

  final DateTime date;
  final DateTime focusedMonth;
  final bool isSelected;
  final VoidCallback? onTap;
  final int overflowCount;

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = CalendarUtils.isSameMonth(date, focusedMonth);
    final isToday = CalendarUtils.isToday(date);
    final isSunday = CalendarUtils.isSunday(date);
    final isSaturday = CalendarUtils.isSaturday(date);

    Color textColor = isCurrentMonth
        ? AppColors.gray900
        : AppColors.gray400;

    if (isSunday && isCurrentMonth) {
      textColor = AppTheme.sundayColor;
    } else if (isSaturday && isCurrentMonth) {
      textColor = AppTheme.saturdayColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: kCalendarCellVerticalMargin),
        padding: const EdgeInsets.only(bottom: kCalendarCellBottomPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Colors.grey.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: kCalendarDateHeaderHeight,
              child: Padding(
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
                          color: isToday ? AppColors.surface : textColor,
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: kCalendarEventAreaHeight),
            SizedBox(
              height: kCalendarOverflowAreaHeight,
              child: overflowCount > 0
                  ? Padding(
                      padding: const EdgeInsets.only(left: 4, top: 1),
                      child: Text(
                        '+$overflowCount',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.gray600,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
