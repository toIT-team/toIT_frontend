import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/lunar_display_utils.dart';
import '../../../core/utils/system_ui_insets.dart';
import '../../../controllers/calendar_controller.dart';
import '../../../models/calendar/calendar_event.dart';
import '../../../services/schedule_api_client.dart'
    show scheduleApiClientProvider;
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
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
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
    final bottomPadding = systemBottomBarPadding(context);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox.expand(),
          ),
        ),
        DraggableScrollableSheet(
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
        ),
      ],
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
    final lunarDate = LunarDisplayUtils.formatLunarCaption(widget.date);

    return Column(
      children: [
        // 작은 드래그 핸들
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
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
                  color: AppColors.gray900,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                lunarDate,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
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
          // TODO(share-ui): 공유 기능 구현 전까지 메뉴 노출 비활성화.
          // 필요 시 아래 라인 주석 해제.
          // onShare: () => _handleShare(event),
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

  // TODO(share-ui): 공유 기능 구현 후 다시 활성화.
  // void _handleShare(CalendarEvent _) {
  //   // TODO: 공유 시트 열기 (일정 상세 하단 바와 동일 플로우)
  // }

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

      final apiClient = ref.read(scheduleApiClientProvider);
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
          Icon(
            Icons.event_note_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            '일정이 없습니다',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.gray600,
            ),
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

}
