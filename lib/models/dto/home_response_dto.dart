import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_response_dto.freezed.dart';
part 'home_response_dto.g.dart';

/// 홈 API 응답 DTO
@freezed
class HomeResponseDto with _$HomeResponseDto {
  const factory HomeResponseDto({
    required int userId,
    @Default([]) List<FolderDto> folders,
    @Default([]) List<FolderViewDto> foldersViews,
    @Default([]) List<ScheduleDto> schedules,
  }) = _HomeResponseDto;

  factory HomeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$HomeResponseDtoFromJson(json);
}

/// 폴더 DTO
@freezed
class FolderDto with _$FolderDto {
  const factory FolderDto({
    required int foldersId,
    required int usersId,
    @Default('') String name,
    @Default('') String memo,
    @Default(false) bool isDefault,
    @Default('') String color,
    String? createdAt,
    @Default(false) bool isFavorite,
    @Default(0) int iconIdx,
  }) = _FolderDto;

  factory FolderDto.fromJson(Map<String, dynamic> json) =>
      _$FolderDtoFromJson(json);
}

/// 폴더 최근 조회 DTO
@freezed
class FolderViewDto with _$FolderViewDto {
  const factory FolderViewDto({
    required int folderId,
    @Default('') String name,
    String? lastViewedAt,
  }) = _FolderViewDto;

  factory FolderViewDto.fromJson(Map<String, dynamic> json) =>
      _$FolderViewDtoFromJson(json);
}

/// 일정 DTO
@freezed
class ScheduleDto with _$ScheduleDto {
  const factory ScheduleDto({
    required int schedulesId,
    @Default('') String title,
    String? startTime,
    String? endTime,
    @Default('') String appColor,
  }) = _ScheduleDto;

  factory ScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleDtoFromJson(json);
}
