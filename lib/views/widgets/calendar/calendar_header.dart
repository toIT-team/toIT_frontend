import 'package:flutter/material.dart';

import '../../../core/utils/calendar_utils.dart';

/// 캘린더 헤더 위젯 (월/년 표시 및 네비게이션)
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.focusedMonth,
    this.onMonthTap,
    this.monthSelectorKey,
  });

  final DateTime focusedMonth;
  final VoidCallback? onMonthTap;

  /// 년월 피커를 이 위젯 바로 아래에 붙이기 위한 앵커
  final GlobalKey? monthSelectorKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            key: monthSelectorKey,
            onTap: onMonthTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CalendarUtils.formatMonth(focusedMonth),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
