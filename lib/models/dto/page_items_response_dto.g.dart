// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_items_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PageItemsResponseDtoImpl _$$PageItemsResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PageItemsResponseDtoImpl(
  usersId: json['usersId'] == null ? 0 : _intFromJson(json['usersId']),
  foldersId: json['foldersId'] == null ? 0 : _intFromJson(json['foldersId']),
  links:
      (json['links'] as List<dynamic>?)
          ?.map((e) => LinkDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  texts:
      (json['texts'] as List<dynamic>?)
          ?.map((e) => TextDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => AttachmentFileDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => AttachmentImageDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$PageItemsResponseDtoImplToJson(
  _$PageItemsResponseDtoImpl instance,
) => <String, dynamic>{
  'usersId': instance.usersId,
  'foldersId': instance.foldersId,
  'links': instance.links,
  'texts': instance.texts,
  'files': instance.files,
  'images': instance.images,
};

_$TextDtoImpl _$$TextDtoImplFromJson(Map<String, dynamic> json) =>
    _$TextDtoImpl(
      textsId: json['textsId'] == null ? 0 : _intFromJson(json['textsId']),
      textContent: json['textContent'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$$TextDtoImplToJson(_$TextDtoImpl instance) =>
    <String, dynamic>{
      'textsId': instance.textsId,
      'textContent': instance.textContent,
      'createdAt': instance.createdAt,
    };

_$LinkDtoImpl _$$LinkDtoImplFromJson(Map<String, dynamic> json) =>
    _$LinkDtoImpl(
      linksId: json['linksId'] == null ? 0 : _intFromJson(json['linksId']),
      linksName: json['linksName'] as String? ?? '',
      linksUrl: json['linksUrl'] as String? ?? '',
      linksThumbnail: json['linksThumbnail'] as String? ?? '',
      textContent: json['textContent'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$$LinkDtoImplToJson(_$LinkDtoImpl instance) =>
    <String, dynamic>{
      'linksId': instance.linksId,
      'linksName': instance.linksName,
      'linksUrl': instance.linksUrl,
      'linksThumbnail': instance.linksThumbnail,
      'textContent': instance.textContent,
      'createdAt': instance.createdAt,
    };

_$AttachmentFileDtoImpl _$$AttachmentFileDtoImplFromJson(
  Map<String, dynamic> json,
) => _$AttachmentFileDtoImpl(
  attachmentsId: json['attachmentsId'] == null
      ? 0
      : _intFromJson(json['attachmentsId']),
  usersId: json['usersId'] == null ? 0 : _intFromJson(json['usersId']),
  attachmentsType: json['attachmentsType'] as String? ?? '',
  textContent: json['textContent'] as String? ?? '',
  objectKey: json['objectKey'] as String? ?? '',
  presignedUrl: _readPresignedUrlKey(json, 'presignedUrl') as String? ?? '',
  attachmentsExtension: json['attachmentsExtension'] as String? ?? '',
  attachmentsSize: (json['attachmentsSize'] as num?)?.toDouble() ?? 0.0,
  fileName: json['fileName'] as String? ?? '',
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$$AttachmentFileDtoImplToJson(
  _$AttachmentFileDtoImpl instance,
) => <String, dynamic>{
  'attachmentsId': instance.attachmentsId,
  'usersId': instance.usersId,
  'attachmentsType': instance.attachmentsType,
  'textContent': instance.textContent,
  'objectKey': instance.objectKey,
  'presignedUrl': instance.presignedUrl,
  'attachmentsExtension': instance.attachmentsExtension,
  'attachmentsSize': instance.attachmentsSize,
  'fileName': instance.fileName,
  'createdAt': instance.createdAt,
};

_$AttachmentImageDtoImpl _$$AttachmentImageDtoImplFromJson(
  Map<String, dynamic> json,
) => _$AttachmentImageDtoImpl(
  attachmentsId: json['attachmentsId'] == null
      ? 0
      : _intFromJson(json['attachmentsId']),
  usersId: json['usersId'] == null ? 0 : _intFromJson(json['usersId']),
  attachmentsType: json['attachmentsType'] as String? ?? '',
  textContent: json['textContent'] as String? ?? '',
  objectKey: json['objectKey'] as String? ?? '',
  presignedUrl: _readPresignedUrlKey(json, 'presignedUrl') as String? ?? '',
  attachmentsExtension: json['attachmentsExtension'] as String? ?? '',
  attachmentsSize: (json['attachmentsSize'] as num?)?.toDouble() ?? 0.0,
  fileName: json['fileName'] as String? ?? '',
  imagesWidth: (json['imagesWidth'] as num?)?.toInt() ?? 0,
  imagesHeight: (json['imagesHeight'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$$AttachmentImageDtoImplToJson(
  _$AttachmentImageDtoImpl instance,
) => <String, dynamic>{
  'attachmentsId': instance.attachmentsId,
  'usersId': instance.usersId,
  'attachmentsType': instance.attachmentsType,
  'textContent': instance.textContent,
  'objectKey': instance.objectKey,
  'presignedUrl': instance.presignedUrl,
  'attachmentsExtension': instance.attachmentsExtension,
  'attachmentsSize': instance.attachmentsSize,
  'fileName': instance.fileName,
  'imagesWidth': instance.imagesWidth,
  'imagesHeight': instance.imagesHeight,
  'createdAt': instance.createdAt,
};
