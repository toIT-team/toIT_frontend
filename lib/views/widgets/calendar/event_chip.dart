import 'package:flutter/material.dart';

import '../../../models/calendar/calendar_event.dart';

/// 일정 표시용 칩 위젯
class EventChip extends StatelessWidget {
  const EventChip({
    super.key,
    required this.event,
    this.isStart = true,
    this.isEnd = true,
    this.showTitle = true,
  });

  final CalendarEvent event;
  final bool isStart;
  final bool isEnd;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      margin: EdgeInsets.only(
        left: isStart ? 2 : 0,
        right: isEnd ? 2 : 0,
      ),
      decoration: BoxDecoration(
        color: event.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.horizontal(
          left: isStart ? const Radius.circular(4) : Radius.zero,
          right: isEnd ? const Radius.circular(4) : Radius.zero,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: showTitle
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            )
          : null,
    );
  }
}
