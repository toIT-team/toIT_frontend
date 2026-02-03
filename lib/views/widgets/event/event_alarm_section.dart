import 'package:flutter/material.dart';

/// 알림 섹션
class EventAlarmSection extends StatelessWidget {
  const EventAlarmSection({
    super.key,
    this.alarmText,
    this.isEditable = false,
    this.onTap,
  });

  final String? alarmText;
  final bool isEditable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasAlarm = alarmText != null && alarmText!.isNotEmpty;
    final displayText = hasAlarm ? alarmText! : '알림 추가';

    final content = Row(
      children: [
        Expanded(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 16,
              color: hasAlarm ? Colors.black : Colors.grey,
            ),
          ),
        ),
        if (isEditable)
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
      ],
    );

    if (isEditable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
