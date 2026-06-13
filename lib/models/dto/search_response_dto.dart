import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_response_dto.freezed.dart';
part 'search_response_dto.g.dart';

/// JSON의 null/숫자/문자열을 bool로 안전 변환 (API 타입 불일치 대비)
bool _boolFromJson(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

/// JSON에서 int 파싱 (null, num, String 지원)
int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// JSON에서 double 파싱 (null, num, String 지원)
double _doubleFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

/// 통합 검색 API 응답 (GET /page/search)
@freezed
class SearchResponseDto with _$SearchResponseDto {
  const factory SearchResponseDto({
    @Default([]) List<SearchFolderItemDto> folders,
    @Default([]) List<SearchScheduleItemDto> schedules,
    @Default([]) List<SearchLinkItemDto> links,
    @Default([]) List<SearchTextItemDto> texts,
    @Default([]) List<SearchFileItemDto> files,
  }) = _SearchResponseDto;

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseDtoFromJson(json);
}

/// 검색 결과 - 폴더
@freezed
class SearchFolderItemDto with _$SearchFolderItemDto {
  const factory SearchFolderItemDto({
    @JsonKey(fromJson: _intFromJson) @Default(0) int foldersId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int usersId,
    @Default('') String name,
    @Default('') String memo,
    @JsonKey(fromJson: _boolFromJson) @Default(false) bool isDefault,
    @Default('') String color,
    String? createdAt,
    @JsonKey(fromJson: _boolFromJson) @Default(false) bool isFavorite,
    @Default(0) int iconIdx,
  }) = _SearchFolderItemDto;

  factory SearchFolderItemDto.fromJson(Map<String, dynamic> json) =>
      _$SearchFolderItemDtoFromJson(json);
}

/// 검색 결과 - 일정
@freezed
class SearchScheduleItemDto with _$SearchScheduleItemDto {
  const factory SearchScheduleItemDto({
    @JsonKey(fromJson: _intFromJson) @Default(0) int usersId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int schedulesId,
    @Default('') String title,
    @Default(0) int foldersId,
    @Default('') String foldersTitle,
    @Default(false) bool timeSetting,
    @Default('') String startDate,
    @Default('') String endDate,
    String? startTime,
    String? endTime,
    // TODO(알림-비활성화): 테스트 중 임시 주석 — 백엔드 미지원
    // @Default(false) bool alarmState,
    // @Default(0) int alarmOffsetMinutes,
    @Default('') String memo,
  }) = _SearchScheduleItemDto;

  factory SearchScheduleItemDto.fromJson(Map<String, dynamic> json) =>
      _$SearchScheduleItemDtoFromJson(json);
}

/// 검색 결과 - 링크
@freezed
class SearchLinkItemDto with _$SearchLinkItemDto {
  const factory SearchLinkItemDto({
    @JsonKey(fromJson: _intFromJson) @Default(0) int linksId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int foldersId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int usersId,
    @Default('') String linksName,
    @Default('') String linksUrl,
    @Default('') String linksThumbnail,
    @Default('') String textContent,
    String? createdAt,
    @Default('') String foldersName,
    @Default('') String dayOfWeek,
  }) = _SearchLinkItemDto;

  factory SearchLinkItemDto.fromJson(Map<String, dynamic> json) =>
      _$SearchLinkItemDtoFromJson(json);
}

/// 검색 결과 - 노트(텍스트)
@freezed
class SearchTextItemDto with _$SearchTextItemDto {
  const factory SearchTextItemDto({
    @JsonKey(fromJson: _intFromJson) @Default(0) int textsId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int usersId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int foldersId,
    @Default('') String textContent,
    String? createdAt,
    @Default('') String foldersName,
    @Default('') String dayOfWeek,
  }) = _SearchTextItemDto;

  factory SearchTextItemDto.fromJson(Map<String, dynamic> json) =>
      _$SearchTextItemDtoFromJson(json);
}

/// 검색 결과 - 파일
@freezed
class SearchFileItemDto with _$SearchFileItemDto {
  const factory SearchFileItemDto({
    @JsonKey(fromJson: _intFromJson) @Default(0) int attachmentsId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int usersId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int foldersId,
    @Default('') String attachmentsType,
    @Default('') String objectKey,
    @Default('') String presignedUrl,
    @Default('') String attachmentsExtension,
    @JsonKey(fromJson: _doubleFromJson) @Default(0.0) double attachmentsSize,
    @Default('') String fileName,
    String? createdAt,
    @Default('') String foldersName,
    @Default('') String dayOfWeek,
  }) = _SearchFileItemDto;

  factory SearchFileItemDto.fromJson(Map<String, dynamic> json) =>
      _$SearchFileItemDtoFromJson(json);
}
