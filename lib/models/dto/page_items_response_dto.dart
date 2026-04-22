import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_items_response_dto.freezed.dart';
part 'page_items_response_dto.g.dart';

/// JSON에서 int 파싱 (null, num, String 지원)
int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// GET /page/items 응답 DTO (보관함 내부 - 링크/노트/파일/이미지)
@freezed
class PageItemsResponseDto with _$PageItemsResponseDto {
  const factory PageItemsResponseDto({
    @JsonKey(fromJson: _intFromJson) @Default(0) int usersId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int foldersId,
    @Default([]) List<LinkDto> links,
    @Default([]) List<TextDto> texts,
    @Default([]) List<AttachmentFileDto> files,
    @Default([]) List<AttachmentImageDto> images,
  }) = _PageItemsResponseDto;

  factory PageItemsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PageItemsResponseDtoFromJson(json);
}

/// 노트(텍스트) 항목 (스웨거 texts[] 요소 - 객체 배열)
@freezed
class TextDto with _$TextDto {
  const factory TextDto({
    @JsonKey(fromJson: _intFromJson) @Default(0) int textsId,
    @Default('') String textContent,
    String? createdAt,
  }) = _TextDto;

  factory TextDto.fromJson(Map<String, dynamic> json) =>
      _$TextDtoFromJson(json);
}

/// 링크 항목 (스웨거 links[] 요소)
@freezed
class LinkDto with _$LinkDto {
  const factory LinkDto({
    @JsonKey(fromJson: _intFromJson) @Default(0) int linksId,
    @Default('') String linksName,
    @Default('') String linksUrl,
    @Default('') String linksThumbnail,
    @Default('') String textContent,
    String? createdAt,
  }) = _LinkDto;

  factory LinkDto.fromJson(Map<String, dynamic> json) =>
      _$LinkDtoFromJson(json);
}

/// 파일 첨부 항목 (스웨거 files[] 요소)
@freezed
class AttachmentFileDto with _$AttachmentFileDto {
  const factory AttachmentFileDto({
    @JsonKey(fromJson: _intFromJson) @Default(0) int attachmentsId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int usersId,
    @Default('') String attachmentsType,
    @Default('') String textContent,
    @Default('') String objectKey,
    @Default('') String presignedUrl,
    @Default('') String attachmentsExtension,
    @Default(0.0) double attachmentsSize,
    @Default('') String fileName,
    String? createdAt,
  }) = _AttachmentFileDto;

  factory AttachmentFileDto.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFileDtoFromJson(json);
}

/// 이미지 첨부 항목 (스웨거 images[] 요소)
@freezed
class AttachmentImageDto with _$AttachmentImageDto {
  const factory AttachmentImageDto({
    @JsonKey(fromJson: _intFromJson) @Default(0) int attachmentsId,
    @JsonKey(fromJson: _intFromJson) @Default(0) int usersId,
    @Default('') String attachmentsType,
    @Default('') String textContent,
    @Default('') String objectKey,
    @Default('') String presignedUrl,
    @Default('') String attachmentsExtension,
    @Default(0.0) double attachmentsSize,
    @Default('') String fileName,
    @Default(0) int imagesWidth,
    @Default(0) int imagesHeight,
    String? createdAt,
  }) = _AttachmentImageDto;

  factory AttachmentImageDto.fromJson(Map<String, dynamic> json) =>
      _$AttachmentImageDtoFromJson(json);
}
