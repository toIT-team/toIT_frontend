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

/// 이벤트 폼 화면 (생성/수정 공용)
class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({
    super.key,
    this.event,
  });

  /// 수정할 이벤트 (null이면 생성 모드)
  final CalendarEvent? event;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  late final TextEditingController _titleController;

  bool get isCreateMode => widget.event == null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();

    // 위젯 빌드 후 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(eventFormProvider.notifier);
      if (widget.event != null) {
        controller.initWithEvent(widget.event!);
        _titleController.text = widget.event!.title;
      } else {
        controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(eventFormProvider);
    final screenTitle = isCreateMode ? '일정 추가' : '일정 수정';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          screenTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: formState.isSaving ? null : _handleSave,
            child: Text(
              '저장',
              style: TextStyle(
                color: formState.isValid ? Colors.blue : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _EventFormLayout(
        titleController: _titleController,
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
      ),
    );
  }

  void _handleTitleChanged(String value) {
    ref.read(eventFormProvider.notifier).updateTitle(value);
  }

  void _handleSave() async {
    final controller = ref.read(eventFormProvider.notifier);
    final calendarController = ref.read(calendarProvider.notifier);

    controller.setSaving(true);

    try {
      final event = controller.toEvent();
      if (event == null) {
        controller.setSaving(false);
        return;
      }

      if (isCreateMode) {
        calendarController.addEvent(event);
      } else {
        calendarController.updateEvent(event);
      }

      if (mounted) {
        Navigator.of(context).pop(event);
      }
    } finally {
      controller.setSaving(false);
    }
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
}

/// 이벤트 폼 레이아웃
class _EventFormLayout extends StatelessWidget {
  const _EventFormLayout({
    required this.titleController,
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
          // 제목 입력
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: TextField(
              controller: titleController,
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
                      folderName: formState.folderName,
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
