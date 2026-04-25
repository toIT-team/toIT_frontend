import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 시간 행 위젯 (날짜 + 시간 표시)
class EventTimeRow extends StatelessWidget {
  const EventTimeRow({
    super.key,
    required this.label,
    required this.date,
    this.time,
    this.showTimeChip = true,
    this.isEditable = false,
    this.onDateTap,
    this.onTimeTap,
    this.isDateActive = false,
    this.isTimeActive = false,
  });

  final String label;
  final DateTime date;
  final String? time;

  /// 시간 칩 표시 여부 (시간 설정 off 시 false)
  final bool showTimeChip;
  final bool isEditable;
  final VoidCallback? onDateTap;
  final VoidCallback? onTimeTap;
  final bool isDateActive;
  final bool isTimeActive;

  @override
  Widget build(BuildContext context) {
    final weekday = _getWeekdayText(date.weekday);
    final dateText =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')} ($weekday)';
    final timeText = time != null ? _formatTime(time!) : '시간 없음';

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
        ),
        Expanded(
          child: _buildChip(
            text: dateText,
            onTap: isEditable ? onDateTap : null,
            isActive: isDateActive,
          ),
        ),
        if (showTimeChip) ...[
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 110),
            child: _buildChip(
              text: timeText,
              onTap: isEditable ? onTimeTap : null,
              isActive: isTimeActive,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChip({
    required String text,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isActive ? AppColors.blue500 : AppColors.gray900,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: chip,
      );
    }

    return chip;
  }

  String _getWeekdayText(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return time;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$period $displayHour:$minute';
  }
}
