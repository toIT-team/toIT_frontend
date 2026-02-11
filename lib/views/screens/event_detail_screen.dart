import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/calendar_controller.dart';
import '../../controllers/event_form_controller.dart';
import '../../models/calendar/calendar_event.dart';
import '../widgets/common/app_divider.dart';
import '../widgets/common/bottom_bar_button.dart';
import '../widgets/event/event_alarm_section.dart';
import '../widgets/event/event_folder_section.dart';
import '../widgets/event/event_location_section.dart';
import '../widgets/event/event_memo_section.dart';
import '../widgets/event/event_section.dart';
import '../widgets/event/event_time_section.dart';

/// 일정 상세 화면
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
  });

  final CalendarEvent event;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isEditMode = false;
  late TextEditingController _titleController;
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    // 폼 컨트롤러 초기화
    ref.read(eventFormProvider.notifier).initWithEvent(widget.event);

    setState(() {
      _isEditMode = true;
    });

    // 다음 프레임에서 타이틀에 포커스 요청 (키보드 올라옴)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  void _exitEditMode() {
    // 원래 값으로 복원
    _titleController.text = widget.event.title;
    setState(() {
      _isEditMode = false;
    });
  }

  Future<void> _saveChanges() async {
    final controller = ref.read(eventFormProvider.notifier);
    final calendarController = ref.read(calendarProvider.notifier);

    controller.setSaving(true);

    try {
      final updatedEvent = controller.toEvent();
      if (updatedEvent == null) {
        controller.setSaving(false);
        return;
      }

      calendarController.updateEvent(updatedEvent);

      setState(() {
        _isEditMode = false;
      });

      if (mounted) {
        // 업데이트된 이벤트로 화면 새로고침을 위해 pop 후 다시 push
        Navigator.of(context).pop(updatedEvent);
      }
    } finally {
      controller.setSaving(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(eventFormProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isEditMode
          ? _EventEditLayout(
              titleController: _titleController,
              titleFocusNode: _titleFocusNode,
              formState: formState,
              onTitleChanged: _handleTitleChanged,
              onStartDateTap: () => _showDatePicker(isStart: true),
              onEndDateTap: () => _showDatePicker(isStart: false),
              onStartTimeTap: () => _showTimePicker(isStart: true),
              onEndTimeTap: () => _showTimePicker(isStart: false),
              onFolderTap: _handleFolderTap,
              onLocationTap: _handleLocationTap,
              onAlarmTap: _handleAlarmTap,
              onMemoTap: _handleMemoTap,
            )
          : _EventDetailLayout(
              title: widget.event.title,
              sections: _buildSections(),
            ),
      bottomNavigationBar: _isEditMode
          ? _buildEditModeBottomBar()
          : _buildViewModeBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isEditMode) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: _exitEditMode,
        ),
        title: const Text(
          '일정 수정',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              '저장',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
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
          folderName: widget.event.title,
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
          startDate: widget.event.startDate,
          endDate: widget.event.endDate,
          startTime: widget.event.timeSetting ? widget.event.startTime : null,
          endTime: widget.event.timeSetting ? widget.event.endTime : null,
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

  Widget _buildViewModeBottomBar() {
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
                onTap: _enterEditMode,
              ),
              BottomBarButton(
                icon: Icons.delete_outline,
                label: '삭제',
                onTap: _showDeleteDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditModeBottomBar() {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _exitEditMode,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTitleChanged(String value) {
    ref.read(eventFormProvider.notifier).updateTitle(value);
  }

  Future<void> _showDatePicker({required bool isStart}) async {
    final formState = ref.read(eventFormProvider);
    final initialDate =
        (isStart ? formState.startDate : formState.endDate) ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final controller = ref.read(eventFormProvider.notifier);
      if (isStart) {
        controller.updateStartDate(picked);
      } else {
        controller.updateEndDate(picked);
      }
    }
  }

  Future<void> _showTimePicker({required bool isStart}) async {
    final formState = ref.read(eventFormProvider);
    final timeStr = isStart ? formState.startTime : formState.endTime;
    var initialTime = const TimeOfDay(hour: 9, minute: 0);

    if (timeStr != null) {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final controller = ref.read(eventFormProvider.notifier);
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';

      if (!formState.timeSetting) {
        controller.toggleTimeSetting(true);
      }

      if (isStart) {
        controller.updateStartTime(timeString);
      } else {
        controller.updateEndTime(timeString);
      }
    }
  }

  void _handleFolderTap() {
    // TODO: 폴더 선택 화면으로 이동
  }

  void _handleLocationTap() {
    // TODO: 위치 검색 화면으로 이동
  }

  void _handleAlarmTap() {
    _showAlarmPicker();
  }

  void _handleMemoTap() {
    // TODO: 메모 입력 다이얼로그 또는 화면
  }

  void _showAlarmPicker() {
    final alarmOptions = [
      (null, '없음'),
      (0, '정시'),
      (5, '5분 전'),
      (10, '10분 전'),
      (15, '15분 전'),
      (30, '30분 전'),
      (60, '1시간 전'),
      (1440, '1일 전'),
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '알림 설정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const AppDivider(indent: 0, endIndent: 0),
              ...alarmOptions.map((option) {
                return ListTile(
                  title: Text(option.$2),
                  onTap: () {
                    ref.read(eventFormProvider.notifier).updateAlarm(option.$1);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog() {
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
                ref
                    .read(calendarProvider.notifier)
                    .removeEvent(widget.event.id);
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

/// 일정 상세 레이아웃 (읽기 전용)
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

/// 일정 편집 레이아웃 (인라인 편집 모드)
class _EventEditLayout extends StatelessWidget {
  const _EventEditLayout({
    required this.titleController,
    required this.titleFocusNode,
    required this.formState,
    required this.onTitleChanged,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
    required this.onFolderTap,
    required this.onLocationTap,
    required this.onAlarmTap,
    required this.onMemoTap,
  });

  final TextEditingController titleController;
  final FocusNode titleFocusNode;
  final EventFormState formState;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;
  final VoidCallback onFolderTap;
  final VoidCallback onLocationTap;
  final VoidCallback onAlarmTap;
  final VoidCallback onMemoTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 입력 (편집 가능)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: TextField(
              controller: titleController,
              focusNode: titleFocusNode,
              onChanged: onTitleChanged,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '제목을 입력하세요',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const AppDivider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 보관함 섹션
                  EventSection(
                    icon: Icons.folder_outlined,
                    iconColor: Colors.blue,
                    child: EventFolderSection(
                      folderName: formState.folderName ?? '보관함 선택',
                      isEditable: true,
                      onTap: onFolderTap,
                    ),
                  ),
                  const AppDivider(),
                  // 시간 설정 섹션
                  EventSection(
                    icon: Icons.access_time_outlined,
                    iconColor: Colors.blue,
                    child: EventTimeSection(
                      startDate: formState.startDate ?? DateTime.now(),
                      endDate: formState.endDate ?? DateTime.now(),
                      startTime:
                          formState.timeSetting ? formState.startTime : null,
                      endTime: formState.timeSetting ? formState.endTime : null,
                      isEditable: true,
                      onStartDateTap: onStartDateTap,
                      onStartTimeTap: onStartTimeTap,
                      onEndDateTap: onEndDateTap,
                      onEndTimeTap: onEndTimeTap,
                    ),
                  ),
                  const AppDivider(),
                  // 위치 섹션
                  EventSection(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.blue,
                    child: EventLocationSection(
                      location: formState.location,
                      isEditable: true,
                      onTap: onLocationTap,
                    ),
                  ),
                  const AppDivider(),
                  // 알림 섹션
                  EventSection(
                    icon: Icons.notifications_outlined,
                    iconColor: Colors.amber[700]!,
                    child: EventAlarmSection(
                      alarmText: formState.alarmText,
                      isEditable: true,
                      onTap: onAlarmTap,
                    ),
                  ),
                  const AppDivider(),
                  // 메모 섹션
                  EventSection(
                    icon: Icons.description_outlined,
                    iconColor: Colors.blue,
                    child: EventMemoSection(
                      memo: formState.memo,
                      isEditable: true,
                      onTap: onMemoTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 오류 메시지
          if (formState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                formState.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
