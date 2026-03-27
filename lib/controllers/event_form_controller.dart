import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_controller.dart';
import '../core/constants/event_color_tokens.dart';
import '../models/calendar/calendar_event.dart';
import '../models/schedule/schedule_response.dart';

part 'event_form_controller.freezed.dart';

/// 이벤트 폼 상태
@freezed
class EventFormState with _$EventFormState {
  const factory EventFormState({
    /// 이벤트 ID (null이면 생성 모드, 있으면 수정 모드)
    String? id,

    /// 제목
    @Default('') String title,

    /// 시작 날짜
    DateTime? startDate,

    /// 종료 날짜
    DateTime? endDate,

    /// 시작 시간 (HH:mm)
    String? startTime,

    /// 종료 시간 (HH:mm)
    String? endTime,

    /// 시간 설정 여부
    @Default(false) bool timeSetting,

    /// 메모
    String? memo,

    /// 알림 설정 (분 단위, 예: 10 = 10분 전, 0 = 일정 시작 시)
    int? alarmMinutes,

    /// 폴더/보관함 이름
    String? folderName,

    /// 폴더 ID (null이면 미선택)
    int? foldersId,

    /// 일정 색상 토큰 (캘린더 UI 표시용)
    EventColorToken? appColorToken,

    /// 저장 중 여부
    @Default(false) bool isSaving,

    /// 유효성 검사 오류 메시지
    String? errorMessage,
  }) = _EventFormState;

  const EventFormState._();

  /// 생성 모드 여부
  bool get isCreateMode => id == null;

  /// 수정 모드 여부
  bool get isEditMode => id != null;

  /// 유효성 검사
  bool get isValid => title.isNotEmpty && startDate != null && endDate != null;

  /// 알림 텍스트 변환
  String? get alarmText {
    if (alarmMinutes == null) return null;
    if (alarmMinutes == 0) return '일정 시작';
    if (alarmMinutes! < 60) return '$alarmMinutes분 전';
    if (alarmMinutes! < 1440) return '${alarmMinutes! ~/ 60}시간 전';
    return '${alarmMinutes! ~/ 1440}일 전';
  }
}

/// 이벤트 폼 컨트롤러
class EventFormController extends Notifier<EventFormState> {
  @override
  EventFormState build() {
    final now = DateTime.now();
    return EventFormState(
      startDate: now,
      endDate: now,
    );
  }

  /// 기존 이벤트로 폼 초기화 (수정 모드)
  void initWithEvent(CalendarEvent event) {
    final token = EventColorTokens.tryParseFromColor(event.color);
    state = EventFormState(
      id: event.id,
      title: event.title,
      startDate: event.startDate,
      endDate: event.endDate,
      startTime: event.startTime,
      endTime: event.endTime,
      timeSetting: event.timeSetting,
      folderName: event.folderName,
      appColorToken: token ?? EventColorToken.blue300,
    );
  }

  /// 일정 상세 API 응답으로 폼 초기화 (수정 모드)
  void initWithScheduleDetail(ScheduleDetailResponse detail) {
    final startTime = _toHhMm(detail.startTime);
    final endTime = _toHhMm(detail.endTime);
    state = EventFormState(
      id: detail.schedulesId.toString(),
      title: detail.title,
      startDate: DateTime.parse(detail.startDate),
      endDate: DateTime.parse(detail.endDate),
      startTime: startTime,
      endTime: endTime,
      timeSetting: detail.timeSetting,
      memo: detail.memo.isEmpty ? null : detail.memo,
      alarmMinutes: detail.alarmState ? detail.alarmOffsetMinutes : null,
      folderName: detail.foldersTitle.isEmpty ? null : detail.foldersTitle,
      foldersId: detail.foldersId > 0 ? detail.foldersId : null,
      appColorToken: EventColorToken.blue300,
    );
  }

  /// HH:mm:ss → HH:mm 변환
  String? _toHhMm(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return null;
  }

  /// 폼 초기화 (생성 모드)
  void reset({DateTime? initialDate}) {
    final date = initialDate ?? DateTime.now();
    state = EventFormState(
      startDate: date,
      endDate: date,
      appColorToken: EventColorToken.blue300,
    );
  }

  /// 제목 업데이트
  void updateTitle(String value) {
    state = state.copyWith(title: value, errorMessage: null);
  }

  /// 시작 날짜 업데이트
  void updateStartDate(DateTime value) {
    var endDate = state.endDate;
    // 시작일이 종료일보다 늦으면 종료일도 같이 변경
    if (endDate != null && value.isAfter(endDate)) {
      endDate = value;
    }
    state = state.copyWith(startDate: value, endDate: endDate);
  }

  /// 종료 날짜 업데이트
  void updateEndDate(DateTime value) {
    var startDate = state.startDate;
    // 종료일이 시작일보다 이르면 시작일도 같이 변경
    if (startDate != null && value.isBefore(startDate)) {
      startDate = value;
    }
    state = state.copyWith(startDate: startDate, endDate: value);
  }

  /// 시작 시간 업데이트
  void updateStartTime(String? value) {
    state = state.copyWith(startTime: value);
  }

  /// 종료 시간 업데이트
  void updateEndTime(String? value) {
    state = state.copyWith(endTime: value);
  }

  /// 시간 설정 토글
  void toggleTimeSetting(bool value) {
    state = state.copyWith(
      timeSetting: value,
      startTime: value ? state.startTime : null,
      endTime: value ? state.endTime : null,
    );
  }

  /// 메모 업데이트
  void updateMemo(String? value) {
    state = state.copyWith(memo: value);
  }

  /// 알림 설정 업데이트
  void updateAlarm(int? minutes) {
    state = state.copyWith(alarmMinutes: minutes);
  }

  /// 폴더 업데이트
  void updateFolder(String? value) {
    state = state.copyWith(folderName: value);
  }

  /// 폴더 ID 업데이트 (null이면 미선택)
  void updateFoldersId(int? value) {
    state = state.copyWith(foldersId: value);
  }

  /// 일정 색상 토큰 업데이트
  void updateAppColorToken(EventColorToken? token) {
    state = state.copyWith(appColorToken: token);
  }

  /// 폼 데이터를 CalendarEvent로 변환
  CalendarEvent? toEvent() {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: '필수 항목을 입력해주세요.');
      return null;
    }

    final now = DateTime.now();
    final startDate = state.startDate!;
    final endDate = state.endDate!;

    String formatDate(DateTime date) =>
        '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final color = state.appColorToken != null
        ? EventColorTokens.of(state.appColorToken!)
        : EventColorTokens.defaultColor;

    return CalendarEvent(
      id: state.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      usersId: ref.read(currentUserIdProvider),
      title: state.title,
      startAt: formatDate(startDate),
      endAt: formatDate(endDate),
      startTime: state.startTime,
      endTime: state.endTime,
      timeSetting: state.timeSetting,
      folderName: state.folderName,
      createdAt: now,
      color: color,
    );
  }

  /// 저장 시작
  void setSaving(bool value) {
    state = state.copyWith(isSaving: value);
  }

  /// 오류 메시지 설정
  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }
}

/// 이벤트 폼 Provider
final eventFormProvider =
    NotifierProvider<EventFormController, EventFormState>(
  EventFormController.new,
);
