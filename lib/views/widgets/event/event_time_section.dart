import 'package:flutter/material.dart';

import '../common/custom_toggle.dart';
import 'event_time_row.dart';

/// 시간 설정 섹션 (시작/종료 시간)
///
/// [isEditable] false: 일정 상세 모드 (읽기 전용)
/// [isEditable] true: 수정 모드 (토글 + 날짜/시간 편집)
class EventTimeSection extends StatelessWidget {
  const EventTimeSection({
    super.key,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    this.isEditable = false,
    this.timeSetting = false,
    this.onTimeSettingChanged,
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
  final bool timeSetting;
  final ValueChanged<bool>? onTimeSettingChanged;
  final VoidCallback? onStartDateTap;
  final VoidCallback? onStartTimeTap;
  final VoidCallback? onEndDateTap;
  final VoidCallback? onEndTimeTap;

  /// 시간이 표시되어야 하는지 여부
  bool get _showTime => isEditable ? timeSetting : startTime != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더: 라벨 + (수정 모드일 때) 토글 스위치
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '시간 설정',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isEditable)
              CustomToggle(
                value: timeSetting,
                onChanged: onTimeSettingChanged,
              ),
          ],
        ),
        const SizedBox(height: 16),
        EventTimeRow(
          label: '시작',
          date: startDate,
          time: _showTime ? startTime : null,
          showTimeChip: _showTime,
          isEditable: isEditable,
          onDateTap: onStartDateTap,
          onTimeTap: onStartTimeTap,
        ),
        const SizedBox(height: 12),
        EventTimeRow(
          label: '종료',
          date: endDate,
          time: _showTime ? endTime : null,
          showTimeChip: _showTime,
          isEditable: isEditable,
          onDateTap: onEndDateTap,
          onTimeTap: onEndTimeTap,
        ),
      ],
    );
  }
}
