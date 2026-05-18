import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_response.freezed.dart';
part 'schedule_response.g.dart';

/// JSON에서 int 파싱 (null, num, String 지원)
int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// JSON에서 String 파싱 (null 시 빈 문자열)
String _stringFromJson(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

/// 일정 전체 조회 API 응답
@freezed
class ScheduleSearchResponse with _$ScheduleSearchResponse {
  const factory ScheduleSearchResponse({
    @JsonKey(fromJson: _intFromJson) @Default(0) int userId,
    @Default([]) List<ScheduleItemResponse> schedulesResponses,
  }) = _ScheduleSearchResponse;

  factory ScheduleSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSearchResponseFromJson(json);
}

/// 일정 항목 응답
@freezed
class ScheduleItemResponse with _$ScheduleItemResponse {
  const factory ScheduleItemResponse({
    @JsonKey(fromJson: _intFromJson) required int schedulesId,
    @JsonKey(fromJson: _stringFromJson) required String title,
    @JsonKey(fromJson: _stringFromJson) required String startDate,
    @JsonKey(fromJson: _stringFromJson) required String endDate,
    String? appColor,
  }) = _ScheduleItemResponse;

  factory ScheduleItemResponse.fromJson(Map<String, dynamic> json) =>
      _$ScheduleItemResponseFromJson(json);
}

/// 선택된 날짜 일정 조회 API 응답
@freezed
class SelectedSchedulesResponse with _$SelectedSchedulesResponse {
  const factory SelectedSchedulesResponse({
    @JsonKey(fromJson: _intFromJson) @Default(0) int userId,
    @Default([]) List<SelectedScheduleItemResponse> schedulesResponses,
  }) = _SelectedSchedulesResponse;

  factory SelectedSchedulesResponse.fromJson(Map<String, dynamic> json) =>
      _$SelectedSchedulesResponseFromJson(json);
}

/// 선택된 날짜 일정 항목 (`GET /page/schedules/selected`)
@freezed
class SelectedScheduleItemResponse with _$SelectedScheduleItemResponse {
  const factory SelectedScheduleItemResponse({
    @JsonKey(fromJson: _intFromJson) required int schedulesId,
    @JsonKey(fromJson: _stringFromJson) required String title,
    @JsonKey(fromJson: _stringFromJson) required String startDate,
    @JsonKey(fromJson: _stringFromJson) required String endDate,
    String? startTime,
    String? endTime,
    String? appColor,
  }) = _SelectedScheduleItemResponse;

  factory SelectedScheduleItemResponse.fromJson(Map<String, dynamic> json) =>
      _$SelectedScheduleItemResponseFromJson(json);
}

/// 일정 상세 조회 API 응답
@freezed
class ScheduleDetailResponse with _$ScheduleDetailResponse {
  const factory ScheduleDetailResponse({
    @Default(0) int userId,
    @JsonKey(fromJson: _intFromJson) required int schedulesId,
    @JsonKey(fromJson: _stringFromJson) required String title,
    @JsonKey(fromJson: _intFromJson) @Default(0) int foldersId,
    @JsonKey(fromJson: _stringFromJson) @Default('') String foldersTitle,
    @Default(false) bool timeSetting,
    @JsonKey(fromJson: _stringFromJson) required String startDate,
    @JsonKey(fromJson: _stringFromJson) required String endDate,
    String? startTime,
    String? endTime,
    @Default(false) bool alarmState,
    @Default(0) int alarmOffsetMinutes,
    @JsonKey(fromJson: _stringFromJson) @Default('') String memo,
  }) = _ScheduleDetailResponse;

  factory ScheduleDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ScheduleDetailResponseFromJson(json);
}
