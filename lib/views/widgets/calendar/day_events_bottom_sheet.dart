import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/calendar_controller.dart';
import '../../../models/calendar/calendar_event.dart';
import '../../../services/schedule_api_client.dart';
import '../../screens/event_form_screen.dart';
import '../common/add_action_button.dart';
import '../common/add_context_menu.dart';
import '../common/confirm_dialog.dart';
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
class DayEventsBottomSheet extends ConsumerStatefulWidget {
  const DayEventsBottomSheet({
    super.key,
    required this.date,
    required this.events,
  });

  final DateTime date;
  final List<CalendarEvent> events;

  @override
  ConsumerState<DayEventsBottomSheet> createState() =>
      _DayEventsBottomSheetState();
}

class _DayEventsBottomSheetState extends ConsumerState<DayEventsBottomSheet> {
  /// + 버튼 위치 계산용 GlobalKey
  final _fabKey = GlobalKey();

  /// FAB 버튼 + SafeArea 하단 여백
  static const _fabBottomPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: widget.events.isEmpty
                        ? _buildEmptyState()
                        : _buildEventsList(scrollController),
                  ),
                ],
              ),
            ),
            // 오른쪽 하단 버튼 positon 고정.
            Positioned(
              right: 20,
              bottom: bottomPadding + _fabBottomPadding,
              child: AddActionButton(key: _fabKey, onTap: _handleFabTap),
            ),
          ],
        );
      },
    );
  }

  void _handleFabTap() {
    showAddContextMenu(
      context: context,
      anchorKey: _fabKey,
      items: [
        ContextMenuItem(
          icon: Icons.calendar_today_outlined,
          label: '일정 추가',
          onTap: _navigateToEventForm,
        ),
      ],
    );
  }

  void _navigateToEventForm() {
    // 바텀시트 닫고 일정 추가 화면으로 이동 (선택한 날짜 전달)
    final selectedDate = widget.date;
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventFormScreen(initialDate: selectedDate),
      ),
    );
  }

  /// 드래그 핸들 + 날짜 헤더 (통합)
  Widget _buildHeader() {
    final weekday = _getWeekdayText(widget.date.weekday);
    final lunarDate = _getLunarDateText(widget.date);

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
                '${widget.date.day}($weekday)',
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

  /// 일정 목록 (+ 버튼 56px + 여백 고려)
  static const _listBottomPadding = 72.0;

  Widget _buildEventsList(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: _listBottomPadding),
      itemCount: widget.events.length,
      itemBuilder: (context, index) {
        final event = widget.events[index];
        return DayEventCard(
          event: event,
          onEdit: () => _handleEdit(event),
          onDelete: () => _handleDelete(event),
        );
      },
    );
  }

  void _handleEdit(CalendarEvent event) {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EventFormScreen(event: event)));
  }

  Future<void> _handleDelete(CalendarEvent event) async {
    final confirmed = await showConfirmDialog(
      context: context,
      message: '이 일정을 삭제하시겠습니까?',
    );
    if (confirmed != true || !mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final schedulesId = int.tryParse(event.id);
      if (schedulesId == null) return;

      final apiClient = ScheduleApiClient();
      await apiClient.deleteSchedule(schedulesId: schedulesId);

      if (!mounted) return;

      ref.read(calendarProvider.notifier).removeEvent(event.id);
      navigator.pop();
    } catch (e) {
      String message;
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data?.toString();
        message = '$statusCode ${responseData ?? e.message ?? ''}';
      } else {
        message = e.toString();
      }
      messenger.showSnackBar(SnackBar(content: Text('삭제 실패: $message')));
    }
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
