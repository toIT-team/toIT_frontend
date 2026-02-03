import 'package:flutter/material.dart';

import '../../../models/calendar/calendar_event.dart';
import '../../screens/event_detail_screen.dart';

/// 일정 카드 위젯 (바텀시트 내 사용)
class DayEventCard extends StatelessWidget {
  const DayEventCard({
    super.key,
    required this.event,
  });

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 바텀시트 닫고 상세 화면으로 이동
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 왼쪽 색상 바
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: event.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            // 일정 내용
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 일정 제목
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 시간 정보
                    Text(
                      _getTimeText(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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

  /// 시간 텍스트 생성
  String _getTimeText() {
    if (!event.timeSetting) {
      return '하루 종일';
    }

    final startTime = _formatTime(event.startTime);
    final endTime = _formatTime(event.endTime);

    if (startTime != null && endTime != null) {
      return '$startTime - $endTime';
    } else if (startTime != null) {
      return startTime;
    }

    return '하루 종일';
  }

  /// 시간 포맷 (24시간 -> 오전/오후)
  String? _formatTime(String? time) {
    if (time == null) return null;

    final parts = time.split(':');
    if (parts.length != 2) return time;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$period $displayHour:$minute';
  }
}
