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
    required int foldersId,
    required int usersId,
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
    required int usersId,
    required int schedulesId,
    @Default('') String title,
    @Default(0) int foldersId,
    @Default('') String foldersTitle,
    @Default(false) bool timeSetting,
    @Default('') String startDate,
    @Default('') String endDate,
    String? startTime,
    String? endTime,
    @Default(false) bool alarmState,
    @Default(0) int alarmOffsetMinutes,
    @Default('') String memo,
  }) = _SearchScheduleItemDto;

  factory SearchScheduleItemDto.fromJson(Map<String, dynamic> json) =>
      _$SearchScheduleItemDtoFromJson(json);
}

/// 검색 결과 - 링크
@freezed
class SearchLinkItemDto with _$SearchLinkItemDto {
  const factory SearchLinkItemDto({
    required int linksId,
    required int foldersId,
    required int usersId,
    @Default('') String linksName,
    @Default('') String linksUrl,
    @Default('') String linksThumbnail,
    @Default('') String textContent,
    String? createdAt,
  }) = _SearchLinkItemDto;

  factory SearchLinkItemDto.fromJson(Map<String, dynamic> json) =>
      _$SearchLinkItemDtoFromJson(json);
}

/// 검색 결과 - 노트(텍스트)
@freezed
class SearchTextItemDto with _$SearchTextItemDto {
  const factory SearchTextItemDto({
    required int textsId,
    required int usersId,
    required int foldersId,
    @Default('') String textContent,
    String? createdAt,
  }) = _SearchTextItemDto;

  factory SearchTextItemDto.fromJson(Map<String, dynamic> json) =>
      _$SearchTextItemDtoFromJson(json);
}

/// 검색 결과 - 파일
@freezed
class SearchFileItemDto with _$SearchFileItemDto {
  const factory SearchFileItemDto({
    required int attachmentsId,
    required int usersId,
    required int foldersId,
    @Default('') String attachmentsType,
    @Default('') String objectKey,
    @Default('') String presignedUrl,
    @Default('') String attachmentsExtension,
    @Default(0.0) double attachmentsSize,
    @Default('') String fileName,
    String? createdAt,
  }) = _SearchFileItemDto;

  factory SearchFileItemDto.fromJson(Map<String, dynamic> json) =>
      _$SearchFileItemDtoFromJson(json);
}
