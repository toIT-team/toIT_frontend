import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/calendar/calendar_event.dart';
import 'day_event_card.dart';

/// 일정 바텀시트 표시
void showDayEventsBottomSheet(
  BuildContext context,
  DateTime date,
  List<CalendarEvent> events,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DayEventsBottomSheet(date: date, events: events),
  );
}

/// 일정 바텀시트 위젯
class DayEventsBottomSheet extends StatelessWidget {
  const DayEventsBottomSheet({
    super.key,
    required this.date,
    required this.events,
  });

  final DateTime date;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // 드래그 핸들 + 날짜 헤더
              _buildHeader(),
              // 일정 목록
              Expanded(
                child: events.isEmpty
                    ? _buildEmptyState()
                    : _buildEventsList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 드래그 핸들 + 날짜 헤더 (통합)
  Widget _buildHeader() {
    final weekday = _getWeekdayText(date.weekday);
    final lunarDate = _getLunarDateText(date);

    return Column(
      children: [
        // 작은 드래그 핸들
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.grey[350],
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
        // 날짜 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
            children: [
              Text(
                '${date.day}($weekday)',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                lunarDate,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 일정 목록
  Widget _buildEventsList(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return DayEventCard(event: events[index]);
      },
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '일정이 없습니다',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// 요일 텍스트
  String _getWeekdayText(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  /// 음력 날짜 텍스트 (간단한 더미 - 실제로는 음력 변환 라이브러리 필요)
  String _getLunarDateText(DateTime date) {
    // 실제 음력 변환은 별도 라이브러리 필요
    // 여기서는 더미 데이터로 표시
    final lunarMonth = ((date.month + date.day) % 12) + 1;
    final lunarDay = (date.day % 30) + 1;
    return '음력 $lunarMonth.$lunarDay';
  }
}
