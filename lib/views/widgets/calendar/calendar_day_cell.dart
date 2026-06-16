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
    required this.eventAreaHeight,
    this.isSelected = false,
    this.onTap,
    // '+N' 표시용 (현재 비활성화).
    // this.overflowCount = 0,
  });

  final DateTime date;
  final DateTime focusedMonth;

  /// 이 주의 칩 줄 수에 맞춰 계산된 이벤트 영역 높이
  final double eventAreaHeight;
  final bool isSelected;
  final VoidCallback? onTap;

  /// 셀에 숨겨진(표시되지 않은) 이벤트 수 — '+N' 표시용, 현재 비활성화.
  // final int overflowCount;

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
            SizedBox(height: eventAreaHeight),
            // ── '+N' 오버플로우 표시 영역 (현재 무제한 표시로 비활성화) ──
            // 다시 살리려면 kCalendarOverflowAreaHeight 상수와 overflowCount
            // 전달 경로(grid)를 함께 복구한다.
            // SizedBox(
            //   height: kCalendarOverflowAreaHeight,
            //   child: overflowCount > 0
            //       ? Padding(
            //           padding: const EdgeInsets.only(left: 4, top: 1),
            //           child: Text(
            //             '+$overflowCount',
            //             style: TextStyle(
            //               fontSize: 10,
            //               color: AppColors.gray600,
            //             ),
            //           ),
            //         )
            //       : null,
            // ),
          ],
        ),
      ),
    );
  }
}
