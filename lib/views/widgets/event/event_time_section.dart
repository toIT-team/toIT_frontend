import 'package:flutter/material.dart';

import 'event_time_row.dart';

/// 시간 설정 섹션 (시작/종료 시간)
class EventTimeSection extends StatelessWidget {
  const EventTimeSection({
    super.key,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    this.isEditable = false,
    this.onStartDateTap,
    this.onStartTimeTap,
    this.onEndDateTap,
    this.onEndTimeTap,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String? startTime;
  final String? endTime;
  final bool isEditable;
  final VoidCallback? onStartDateTap;
  final VoidCallback? onStartTimeTap;
  final VoidCallback? onEndDateTap;
  final VoidCallback? onEndTimeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '시간 설정',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        EventTimeRow(
          label: '시작',
          date: startDate,
          time: startTime,
          isEditable: isEditable,
          onDateTap: onStartDateTap,
          onTimeTap: onStartTimeTap,
        ),
        const SizedBox(height: 12),
        EventTimeRow(
          label: '종료',
          date: endDate,
          time: endTime,
          isEditable: isEditable,
          onDateTap: onEndDateTap,
          onTimeTap: onEndTimeTap,
        ),
      ],
    );
  }
}
