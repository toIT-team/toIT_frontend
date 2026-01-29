import 'package:flutter/material.dart';

import '../../../core/utils/calendar_utils.dart';

/// 캘린더 헤더 위젯 (월/년 표시 및 네비게이션)
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.focusedMonth,
    this.onMonthTap,
  });

  final DateTime focusedMonth;
  final VoidCallback? onMonthTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
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
