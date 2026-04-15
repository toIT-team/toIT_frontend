import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/calendar_controller.dart';
import '../../controllers/event_form_controller.dart';
import '../../core/constants/alarm_constants.dart';
import '../../core/constants/event_color_tokens.dart';
import '../../core/constants/setting_layout_tokens.dart';
import '../../models/schedule/schedule_response.dart';
import '../../services/schedule_api_client.dart' show scheduleApiClientProvider;
import '../widgets/common/app_divider.dart';
import '../widgets/common/schedule_folder_search_sheet.dart';
import '../widgets/common/bottom_bar_button.dart';
import '../widgets/event/alarm_picker_sheet.dart';
import '../widgets/common/confirm_dialog.dart';
import '../widgets/event/event_alarm_section.dart';
import '../widgets/event/event_folder_section.dart';
import '../widgets/event/event_memo_section.dart';
import '../widgets/event/event_section.dart';
import '../widgets/event/event_time_section.dart';
import 'folder_detail_screen.dart';

/// 알림 분 단위를 표시 텍스트로 변환
String _alarmOffsetToText(int minutes) {
  if (minutes == 0) return '일정 시작';
  if (minutes < 60) return '$minutes분 전';
  if (minutes < 1440) return '${minutes ~/ 60}시간 전';
  return '${minutes ~/ 1440}일 전';
}

/// 일정 상세 화면
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.schedulesId,
  });

  final int schedulesId;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isEditMode = false;
  late TextEditingController _titleController;
  late TextEditingController _memoController;
  final FocusNode _titleFocusNode = FocusNode();

  ScheduleDetailResponse? _detail;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _memoController = TextEditingController();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final apiClient = ref.read(scheduleApiClientProvider);
      final detail = await apiClient.getScheduleDetail(
        schedulesId: widget.schedulesId,
      );

      if (!mounted) return;

      setState(() {
        _detail = detail;
        _titleController.text = detail.title;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    final detail = _detail;
    if (detail == null) return;

    ref.read(eventFormProvider.notifier).initWithScheduleDetail(detail);
    _memoController.text = detail.memo.isEmpty ? '' : detail.memo;

    setState(() {
      _isEditMode = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  void _exitEditMode() {
    _titleController.text = _detail?.title ?? '';
    _memoController.text = _detail?.memo ?? '';
    setState(() {
      _isEditMode = false;
    });
  }

  Future<void> _saveChanges() async {
    print('>>> [일정 수정] EventDetailScreen _saveChanges 호출됨');
    final controller = ref.read(eventFormProvider.notifier);
    final formState = ref.read(eventFormProvider);
    final calendarController = ref.read(calendarProvider.notifier);

    if (!formState.isValid) {
      controller.setError('필수 항목을 입력해주세요.');
      return;
    }

    final schedulesId = int.tryParse(formState.id ?? '');
    if (schedulesId == null) {
      controller.setError('일정 ID를 찾을 수 없습니다.');
      return;
    }

    controller.setSaving(true);

    try {
      final appColor = formState.appColorToken != null
          ? EventColorTokens.toToken(formState.appColorToken!)
          : EventColorTokens.toToken(EventColorToken.blue300);

      final apiClient = ref.read(scheduleApiClientProvider);
      final updatedEvent = await apiClient.updateSchedule(
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
      );

      calendarController.updateEvent(updatedEvent);

      setState(() {
        _isEditMode = false;
      });

      if (mounted) {
        Navigator.of(context).pop(updatedEvent);
      }
    } catch (e, stack) {
      print('[일정 수정] EventDetailScreen _saveChanges Error: $e');
      print('[일정 수정] Stack: $stack');
      controller.setError('저장에 실패했습니다.');
    } finally {
      controller.setSaving(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(eventFormProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(formState),
        bottomNavigationBar: _isEditMode || _isLoading || _loadError != null
            ? null
            : _buildViewModeBottomBar(),
      ),
    );
  }

  Widget _buildBody(EventFormState formState) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '일정을 불러오지 못했습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadDetail,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;

    if (_isEditMode) {
      return _EventEditLayout(
        titleController: _titleController,
        titleFocusNode: _titleFocusNode,
        memoController: _memoController,
        formState: formState,
        onTitleChanged: _handleTitleChanged,
        onStartDateTap: () => _showDatePicker(isStart: true),
        onEndDateTap: () => _showDatePicker(isStart: false),
        onStartTimeTap: () => _showTimePicker(isStart: true),
        onEndTimeTap: () => _showTimePicker(isStart: false),
        onTimeSettingChanged: _handleTimeSettingChanged,
        onFolderTap: _handleFolderTap,
        onAlarmTap: _handleAlarmTap,
        onAlarmToggleOff: _handleAlarmToggleOff,
        onMemoChanged: _handleMemoChanged,
      );
    }

    return _EventDetailLayout(
      title: detail.title,
      sections: _buildSections(detail),
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

  /// 연결된 보관함이 있을 때만 탭으로 [FolderDetailScreen] 이동.
  VoidCallback? _folderNavigateTap(ScheduleDetailResponse detail) {
    if (detail.foldersId <= 0 || detail.foldersTitle.isEmpty) {
      return null;
    }
    return () {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FolderDetailScreen(
            foldersId: detail.foldersId,
            folderName: detail.foldersTitle,
          ),
        ),
      );
    };
  }

  List<EventSectionItem> _buildSections(ScheduleDetailResponse detail) {
    final alarmText = detail.alarmState
        ? _alarmOffsetToText(detail.alarmOffsetMinutes)
        : null;

    return [
      EventSectionItem(
        icon: Icons.folder_outlined,
        iconColor: SettingLayout1Tokens.sectionIconColor,
        child: EventFolderSection(
          folderName: detail.foldersTitle.isEmpty ? null : detail.foldersTitle,
          isEditable: false,
          onTap: _folderNavigateTap(detail),
        ),
      ),
      EventSectionItem(
        icon: Icons.access_time_outlined,
        iconColor: SettingLayout1Tokens.sectionIconColor,
        child: EventTimeSection(
          startDate: DateTime.parse(detail.startDate),
          endDate: DateTime.parse(detail.endDate),
          startTime: detail.timeSetting ? _toHhMm(detail.startTime) : null,
          endTime: detail.timeSetting ? _toHhMm(detail.endTime) : null,
          isEditable: false,
        ),
      ),
      EventSectionItem(
        icon: Icons.notifications_outlined,
        iconColor: SettingLayout1Tokens.sectionIconColor,
        child: EventAlarmSection(
          alarmText: alarmText,
          alarmEnabled: detail.alarmState,
          isEditable: false,
        ),
      ),
      EventSectionItem(
        icon: Icons.description_outlined,
        iconColor: SettingLayout1Tokens.sectionIconColor,
        child: EventMemoSection(
          memo: detail.memo.isEmpty ? null : detail.memo,
          memoDate: null,
          isEditable: false,
        ),
      ),
    ];
  }

  String? _toHhMm(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return null;
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
                onTap: _showDeleteConfirmDialog,
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

  void _handleTimeSettingChanged(bool value) {
    final controller = ref.read(eventFormProvider.notifier);
    if (value && ref.read(eventFormProvider).startTime == null) {
      // 시간 설정을 켤 때 기본 시간 설정
      controller.updateStartTime('09:00');
      controller.updateEndTime('10:00');
    }
    controller.toggleTimeSetting(value);
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

  Future<void> _handleFolderTap() async {
    await showScheduleFolderSearchSheet(
      context,
      ref,
      onSelected: (folder) {
        ref.read(eventFormProvider.notifier).selectFolder(
              foldersId: folder.foldersId,
              folderName: folder.title,
            );
      },
    );
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

  void _handleMemoChanged(String value) {
    ref.read(eventFormProvider.notifier).updateMemo(
          value.isEmpty ? null : value,
        );
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

  Future<void> _showDeleteConfirmDialog() async {
    final confirmed = await showConfirmDialog(
      context: context,
      message: '이 일정을 삭제하시겠습니까?',
    );
    if (confirmed == true) {
      await _handleDelete();
    }
  }

  Future<void> _handleDelete() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final apiClient = ref.read(scheduleApiClientProvider);
      await apiClient.deleteSchedule(
        schedulesId: widget.schedulesId,
      );

      if (!mounted) return;

      ref.read(calendarProvider.notifier).removeEvent(
            widget.schedulesId.toString(),
          );
      navigator.pop();
    } catch (e) {
      // TODO: 에러 상세 표시. 후에 삭제 요망
      String message;
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data?.toString();
        message = '$statusCode ${responseData ?? e.message ?? ''}';
      } else {
        message = e.toString();
      }
      messenger.showSnackBar(
        SnackBar(content: Text('삭제 실패: $message')),
      );
    }
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
    required this.memoController,
    required this.formState,
    required this.onTitleChanged,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
    required this.onTimeSettingChanged,
    required this.onFolderTap,
    required this.onAlarmTap,
    required this.onAlarmToggleOff,
    required this.onMemoChanged,
  });

  final TextEditingController titleController;
  final FocusNode titleFocusNode;
  final TextEditingController memoController;
  final EventFormState formState;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;
  final ValueChanged<bool> onTimeSettingChanged;
  final VoidCallback onFolderTap;
  final VoidCallback onAlarmTap;
  final VoidCallback onAlarmToggleOff;
  final ValueChanged<String> onMemoChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
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
                startDate:
                    formState.startDate ?? DateTime.now(),
                endDate:
                    formState.endDate ?? DateTime.now(),
                startTime:
                    formState.timeSetting
                        ? formState.startTime
                        : null,
                endTime:
                    formState.timeSetting
                        ? formState.endTime
                        : null,
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
            // 메모 섹션 (터치 시 포커스되어 바로 입력 가능)
            EventSection(
              icon: Icons.description_outlined,
              iconColor: SettingLayout1Tokens.sectionIconColor,
              child: EventMemoSection(
                memo: formState.memo,
                memoController: memoController,
                isEditable: true,
                onChanged: onMemoChanged,
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
      ),
    );
  }
}
