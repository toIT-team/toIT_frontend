import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/calendar_controller.dart';
import '../../models/calendar/calendar_event.dart';
import '../widgets/common/app_divider.dart';
import '../widgets/common/bottom_bar_button.dart';
import '../widgets/event/event_alarm_section.dart';
import '../widgets/event/event_folder_section.dart';
import '../widgets/event/event_location_section.dart';
import '../widgets/event/event_memo_section.dart';
import '../widgets/event/event_section.dart';
import '../widgets/event/event_time_section.dart';
import 'event_form_screen.dart';

/// 일정 상세 화면
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
  });

  final CalendarEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _EventDetailLayout(
        title: event.title,
        sections: _buildSections(),
      ),
      bottomNavigationBar: _buildBottomBar(context, ref),
    );
  }

  List<EventSectionItem> _buildSections() {
    // 더미 데이터 - 실제로는 event 모델에서 가져와야 함
    const dummyLocation = '부산광역시 벡스코 1층';
    const dummyAlarm = '10분 전';
    const dummyMemo = '노트북 챙겨 가기';
    const dummyMemoDate = '2일 전';

    return [
      EventSectionItem(
        icon: Icons.folder_outlined,
        iconColor: Colors.blue,
        child: EventFolderSection(
          folderName: event.title,
          isEditable: false,
          onTap: () {
            // TODO: 보관함으로 이동
          },
        ),
      ),
      EventSectionItem(
        icon: Icons.access_time_outlined,
        iconColor: Colors.blue,
        child: EventTimeSection(
          startDate: event.startDate,
          endDate: event.endDate,
          startTime: event.timeSetting ? event.startTime : null,
          endTime: event.timeSetting ? event.endTime : null,
          isEditable: false,
        ),
      ),
      EventSectionItem(
        icon: Icons.location_on_outlined,
        iconColor: Colors.blue,
        child: EventLocationSection(
          location: dummyLocation,
          isEditable: false,
          onTap: () {
            // TODO: 지도 앱 열기
          },
        ),
      ),
      EventSectionItem(
        icon: Icons.notifications_outlined,
        iconColor: Colors.amber[700]!,
        child: const EventAlarmSection(
          alarmText: dummyAlarm,
          isEditable: false,
        ),
      ),
      EventSectionItem(
        icon: Icons.description_outlined,
        iconColor: Colors.blue,
        child: const EventMemoSection(
          memo: dummyMemo,
          memoDate: dummyMemoDate,
          isEditable: false,
        ),
      ),
    ];
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BottomBarButton(
                icon: Icons.ios_share_outlined,
                label: '공유',
                onTap: () {
                  // TODO: 공유 시트 열기
                },
              ),
              BottomBarButton(
                icon: Icons.edit_outlined,
                label: '수정',
                onTap: () => _navigateToEditScreen(context),
              ),
              BottomBarButton(
                icon: Icons.delete_outline,
                label: '삭제',
                onTap: () => _showDeleteDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventFormScreen(event: event),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: const Text(
            '이 일정을 삭제하시겠습니까?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(calendarProvider.notifier).removeEvent(event.id);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                '삭제',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 일정 상세 레이아웃
class _EventDetailLayout extends StatelessWidget {
  const _EventDetailLayout({
    required this.title,
    required this.sections,
  });

  final String title;
  final List<EventSectionItem> sections;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const AppDivider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < sections.length; i++) ...[
                    EventSection(
                      icon: sections[i].icon,
                      iconColor: sections[i].iconColor,
                      child: sections[i].child,
                    ),
                    if (i != sections.length - 1) const AppDivider(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
