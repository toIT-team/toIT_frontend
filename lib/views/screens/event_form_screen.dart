import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/event_form_controller.dart';
import '../../core/constants/alarm_constants.dart';
import '../../core/constants/event_color_tokens.dart';
import '../../core/constants/setting_layout_tokens.dart';
import '../../models/calendar/calendar_event.dart';
import '../../services/schedule_api_client.dart';
import '../widgets/common/app_divider.dart';
import '../widgets/event/alarm_picker_sheet.dart';
import '../widgets/event/color_context_menu.dart';
import '../widgets/event/event_alarm_section.dart';
import '../widgets/event/event_folder_section.dart';
import '../widgets/event/event_memo_section.dart';
import '../widgets/event/event_section.dart';
import '../widgets/event/event_time_section.dart';

/// 이벤트 폼 화면 (생성/수정 공용)
class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({
    super.key,
    this.event,
    this.initialDate,
  });

  /// 수정할 이벤트 (null이면 생성 모드)
  final CalendarEvent? event;

  /// 생성 모드 시 초기 날짜 (바텀시트에서 선택한 날짜 등)
  final DateTime? initialDate;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _memoController;
  late final FocusNode _titleFocusNode;
  final _colorButtonKey = GlobalKey();

  bool get isCreateMode => widget.event == null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _memoController = TextEditingController();
    _titleFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(eventFormProvider.notifier);
      if (widget.event != null) {
        controller.initWithEvent(widget.event!);
        _titleController.text = widget.event!.title;
      } else {
        controller.reset(initialDate: widget.initialDate);
        _titleFocusNode.requestFocus();
      }
      _memoController.text = ref.read(eventFormProvider).memo ?? '';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _titleFocusNode.dispose();
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
        titleFocusNode: _titleFocusNode,
        memoController: _memoController,
        colorButtonKey: _colorButtonKey,
        formState: formState,
        onTitleChanged: _handleTitleChanged,
        onColorTap: _handleColorTap,
        onTimeSettingChanged: _handleTimeSettingChanged,
        onStartDateTap: () => _showDatePicker(isStart: true),
        onEndDateTap: () => _showDatePicker(isStart: false),
        onStartTimeTap: () => _showTimePicker(isStart: true),
        onEndTimeTap: () => _showTimePicker(isStart: false),
        onFolderTap: _handleFolderTap,
        onAlarmTap: _handleAlarmTap,
        onAlarmToggleOff: _handleAlarmToggleOff,
        onMemoChanged: _handleMemoChanged,
      ),
    );
  }

  void _handleTitleChanged(String value) {
    ref.read(eventFormProvider.notifier).updateTitle(value);
  }

  void _handleTimeSettingChanged(bool value) {
    final controller = ref.read(eventFormProvider.notifier);
    if (value && ref.read(eventFormProvider).startTime == null) {
      controller.updateStartTime('09:00');
      controller.updateEndTime('10:00');
    }
    controller.toggleTimeSetting(value);
  }

  void _handleColorTap() {
    final state = ref.read(eventFormProvider);
    showColorContextMenu(
      context: context,
      anchorKey: _colorButtonKey,
      selectedToken: state.appColorToken ?? EventColorToken.blue300,
      onSelected: (EventColorToken token) {
        ref.read(eventFormProvider.notifier).updateAppColorToken(token);
      },
    );
  }

  void _handleMemoChanged(String value) {
    ref.read(eventFormProvider.notifier).updateMemo(
          value.isEmpty ? null : value,
        );
  }

  void _handleSave() async {
    print('>>> [일정 저장] _handleSave 호출됨');
    final controller = ref.read(eventFormProvider.notifier);
    final formState = ref.read(eventFormProvider);

    if (!formState.isValid) {
      print('>>> [일정 저장] 유효성 검사 실패 - 저장 중단');
      controller.setSaving(false);
      return;
    }

    print('>>> [일정 저장] isCreateMode=$isCreateMode, event.id=${widget.event?.id}');
    controller.setSaving(true);
    controller.setError(null);

    try {
      if (isCreateMode) {
        print('>>> [일정 저장] 생성 모드 - createSchedule 호출');
        final appColor = formState.appColorToken != null
            ? EventColorTokens.toToken(formState.appColorToken!)
            : EventColorTokens.toToken(EventColorToken.blue300);

        final userId = ref.read(currentUserIdProvider);
        final apiClient = ScheduleApiClient();
        final event = await apiClient.createSchedule(
          title: formState.title,
          appColor: appColor,
          timeSetting: formState.timeSetting,
          startDate: formState.startDate!,
          endDate: formState.endDate!,
          startTime: formState.startTime,
          endTime: formState.endTime,
          memo: formState.memo,
          alarmState: formState.alarmMinutes != null,
          alarmOffsetMinutes: formState.alarmMinutes ?? 0,
          foldersId: formState.foldersId,
          userId: userId,
        );

        ref.read(calendarProvider.notifier).addEvent(event);
        if (mounted) {
          Navigator.of(context).pop((event: event, isCreate: true));
        }
      } else {
        print('[일정 수정] 수정 모드 - API 호출 시작');
        final formState = ref.read(eventFormProvider);
        final schedulesId = int.tryParse(formState.id ?? '');
        print('[일정 수정] schedulesId: $schedulesId, formState.id: ${formState.id}');
        if (schedulesId == null) {
          controller.setError('일정 ID를 찾을 수 없습니다.');
          return;
        }

        final appColor = formState.appColorToken != null
            ? EventColorTokens.toToken(formState.appColorToken!)
            : EventColorTokens.toToken(EventColorToken.blue300);

        final userId = ref.read(currentUserIdProvider);
        final apiClient = ScheduleApiClient();
        final event = await apiClient.updateSchedule(
          schedulesId: schedulesId,
          title: formState.title,
          appColor: appColor,
          timeSetting: formState.timeSetting,
          startDate: formState.startDate!,
          endDate: formState.endDate!,
          startTime: formState.startTime,
          endTime: formState.endTime,
          memo: formState.memo,
          alarmState: formState.alarmMinutes != null,
          alarmOffsetMinutes: formState.alarmMinutes ?? 0,
          foldersId: formState.foldersId,
          userId: userId,
        );

        ref.read(calendarProvider.notifier).updateEvent(event);
        if (mounted) {
          Navigator.of(context).pop((event: event, isCreate: false));
        }
      }
    } catch (e, stack) {
      print('[일정 저장] Error: $e');
      print('[일정 저장] Stack: $stack');
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

  void _handleAlarmTap() {
    // 알림 추가 시 기본값으로 '일정 시작'(0분) 설정
    if (ref.read(eventFormProvider).alarmMinutes == null) {
      ref.read(eventFormProvider.notifier).updateAlarm(0);
    }
    _showAlarmPicker();
  }

  void _handleAlarmToggleOff() {
    ref.read(eventFormProvider.notifier).updateAlarm(null);
  }

  void _showAlarmPicker() {
    BottomSheetStyle.show<void>(
      context,
      showDragHandle: true,
      child: Builder(
        builder: (context) {
          final currentMinutes = ref.watch(eventFormProvider).alarmMinutes;
          return AlarmPickerSheet(
            currentMinutes: currentMinutes,
            onOptionSelected: (minutes) {
              ref.read(eventFormProvider.notifier).updateAlarm(minutes);
            },
            onCustomSettingTap: _showAlarmCustomPicker,
          );
        },
      ),
    );
  }

  void _showAlarmCustomPicker() {
    final currentMinutes = ref.read(eventFormProvider).alarmMinutes;
    final (initialValue, initialUnit) =
        AlarmUtils.fromMinutes(currentMinutes ?? 60); // 기본 1시간

    BottomSheetStyle.show<void>(
      context,
      showDragHandle: true,
      child: AlarmCustomPickerSheet(
        initialValue: initialValue,
        initialUnit: initialUnit,
        onConfirm: (minutes) {
          ref.read(eventFormProvider.notifier).updateAlarm(minutes);
        },
      ),
    );
  }
}

/// 이벤트 폼 레이아웃
class _EventFormLayout extends StatelessWidget {
  const _EventFormLayout({
    required this.titleController,
    required this.titleFocusNode,
    required this.memoController,
    required this.colorButtonKey,
    required this.formState,
    required this.onTitleChanged,
    required this.onColorTap,
    this.onTimeSettingChanged,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
    required this.onFolderTap,
    required this.onAlarmTap,
    required this.onAlarmToggleOff,
    required this.onMemoChanged,
  });

  final TextEditingController titleController;
  final FocusNode titleFocusNode;
  final TextEditingController memoController;
  final GlobalKey colorButtonKey;
  final EventFormState formState;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onColorTap;
  final ValueChanged<bool>? onTimeSettingChanged;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;
  final VoidCallback onFolderTap;
  final VoidCallback onAlarmTap;
  final VoidCallback onAlarmToggleOff;
  final ValueChanged<String> onMemoChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 입력 + 색상 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
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
                GestureDetector(
                  key: colorButtonKey,
                  onTap: onColorTap,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: formState.appColorToken != null
                          ? EventColorTokens.of(formState.appColorToken!)
                          : EventColorTokens.defaultColor,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
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
                    iconColor: SettingLayout1Tokens.sectionIconColor,
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
                    iconColor: SettingLayout1Tokens.sectionIconColor,
                    child: EventTimeSection(
                      startDate: formState.startDate ?? DateTime.now(),
                      endDate: formState.endDate ?? DateTime.now(),
                      startTime:
                          formState.timeSetting ? formState.startTime : null,
                      endTime: formState.timeSetting ? formState.endTime : null,
                      isEditable: true,
                      timeSetting: formState.timeSetting,
                      onTimeSettingChanged: onTimeSettingChanged,
                      onStartDateTap: onStartDateTap,
                      onStartTimeTap: onStartTimeTap,
                      onEndDateTap: onEndDateTap,
                      onEndTimeTap: onEndTimeTap,
                    ),
                  ),
                  const AppDivider(),
                  // 알림 섹션
                  EventSection(
                    icon: Icons.notifications_outlined,
                    iconColor: SettingLayout1Tokens.sectionIconColor,
                    child: EventAlarmSection(
                      alarmText: formState.alarmText,
                      alarmEnabled: formState.alarmMinutes != null,
                      isEditable: true,
                      onAddTap: onAlarmTap,
                      onToggleChanged: (v) {
                        if (v) {
                          onAlarmTap();
                        } else {
                          onAlarmToggleOff();
                        }
                      },
                    ),
                  ),
                  const AppDivider(),
                  // 메모 섹션
                  EventSection(
                    icon: Icons.description_outlined,
                    iconColor: SettingLayout1Tokens.sectionIconColor,
                    child: EventMemoSection(
                      memoController: memoController,
                      isEditable: true,
                      onChanged: onMemoChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
