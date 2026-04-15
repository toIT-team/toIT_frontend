// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchResponseDtoImpl _$$SearchResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SearchResponseDtoImpl(
  folders:
      (json['folders'] as List<dynamic>?)
          ?.map((e) => SearchFolderItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  schedules:
      (json['schedules'] as List<dynamic>?)
          ?.map(
            (e) => SearchScheduleItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  links:
      (json['links'] as List<dynamic>?)
          ?.map((e) => SearchLinkItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  texts:
      (json['texts'] as List<dynamic>?)
          ?.map((e) => SearchTextItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => SearchFileItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$SearchResponseDtoImplToJson(
  _$SearchResponseDtoImpl instance,
) => <String, dynamic>{
  'folders': instance.folders,
  'schedules': instance.schedules,
  'links': instance.links,
  'texts': instance.texts,
  'files': instance.files,
};

_$SearchFolderItemDtoImpl _$$SearchFolderItemDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SearchFolderItemDtoImpl(
  foldersId: json['foldersId'] == null ? 0 : _intFromJson(json['foldersId']),
  usersId: json['usersId'] == null ? 0 : _intFromJson(json['usersId']),
  name: json['name'] as String? ?? '',
  memo: json['memo'] as String? ?? '',
  isDefault: json['isDefault'] == null
      ? false
      : _boolFromJson(json['isDefault']),
  color: json['color'] as String? ?? '',
  createdAt: json['createdAt'] as String?,
  isFavorite: json['isFavorite'] == null
      ? false
      : _boolFromJson(json['isFavorite']),
  iconIdx: (json['iconIdx'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$SearchFolderItemDtoImplToJson(
  _$SearchFolderItemDtoImpl instance,
) => <String, dynamic>{
  'foldersId': instance.foldersId,
  'usersId': instance.usersId,
  'name': instance.name,
  'memo': instance.memo,
  'isDefault': instance.isDefault,
  'color': instance.color,
  'createdAt': instance.createdAt,
  'isFavorite': instance.isFavorite,
  'iconIdx': instance.iconIdx,
};

_$SearchScheduleItemDtoImpl _$$SearchScheduleItemDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SearchScheduleItemDtoImpl(
  usersId: json['usersId'] == null ? 0 : _intFromJson(json['usersId']),
  schedulesId: json['schedulesId'] == null
      ? 0
      : _intFromJson(json['schedulesId']),
  title: json['title'] as String? ?? '',
  foldersId: (json['foldersId'] as num?)?.toInt() ?? 0,
  foldersTitle: json['foldersTitle'] as String? ?? '',
  timeSetting: json['timeSetting'] as bool? ?? false,
  startDate: json['startDate'] as String? ?? '',
  endDate: json['endDate'] as String? ?? '',
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  alarmState: json['alarmState'] as bool? ?? false,
  alarmOffsetMinutes: (json['alarmOffsetMinutes'] as num?)?.toInt() ?? 0,
  memo: json['memo'] as String? ?? '',
);

Map<String, dynamic> _$$SearchScheduleItemDtoImplToJson(
  _$SearchScheduleItemDtoImpl instance,
) => <String, dynamic>{
  'usersId': instance.usersId,
  'schedulesId': instance.schedulesId,
  'title': instance.title,
  'foldersId': instance.foldersId,
  'foldersTitle': instance.foldersTitle,
  'timeSetting': instance.timeSetting,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'alarmState': instance.alarmState,
  'alarmOffsetMinutes': instance.alarmOffsetMinutes,
  'memo': instance.memo,
};

_$SearchLinkItemDtoImpl _$$SearchLinkItemDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SearchLinkItemDtoImpl(
  linksId: json['linksId'] == null ? 0 : _intFromJson(json['linksId']),
  foldersId: json['foldersId'] == null ? 0 : _intFromJson(json['foldersId']),
  usersId: json['usersId'] == null ? 0 : _intFromJson(json['usersId']),
  linksName: json['linksName'] as String? ?? '',
  linksUrl: json['linksUrl'] as String? ?? '',
  linksThumbnail: json['linksThumbnail'] as String? ?? '',
  textContent: json['textContent'] as String? ?? '',
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$$SearchLinkItemDtoImplToJson(
  _$SearchLinkItemDtoImpl instance,
) => <String, dynamic>{
  'linksId': instance.linksId,
  'foldersId': instance.foldersId,
  'usersId': instance.usersId,
  'linksName': instance.linksName,
  'linksUrl': instance.linksUrl,
  'linksThumbnail': instance.linksThumbnail,
  'textContent': instance.textContent,
  'createdAt': instance.createdAt,
};

_$SearchTextItemDtoImpl _$$SearchTextItemDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SearchTextItemDtoImpl(
  textsId: json['textsId'] == null ? 0 : _intFromJson(json['textsId']),
  usersId: json['usersId'] == null ? 0 : _intFromJson(json['usersId']),
  foldersId: json['foldersId'] == null ? 0 : _intFromJson(json['foldersId']),
  textContent: json['textContent'] as String? ?? '',
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$$SearchTextItemDtoImplToJson(
  _$SearchTextItemDtoImpl instance,
) => <String, dynamic>{
  'textsId': instance.textsId,
  'usersId': instance.usersId,
  'foldersId': instance.foldersId,
  'textContent': instance.textContent,
  'createdAt': instance.createdAt,
};

_$SearchFileItemDtoImpl _$$SearchFileItemDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SearchFileItemDtoImpl(
  attachmentsId: json['attachmentsId'] == null
      ? 0
      : _intFromJson(json['attachmentsId']),
  usersId: json['usersId'] == null ? 0 : _intFromJson(json['usersId']),
  foldersId: json['foldersId'] == null ? 0 : _intFromJson(json['foldersId']),
  attachmentsType: json['attachmentsType'] as String? ?? '',
  objectKey: json['objectKey'] as String? ?? '',
  presignedUrl: json['presignedUrl'] as String? ?? '',
  attachmentsExtension: json['attachmentsExtension'] as String? ?? '',
  attachmentsSize: (json['attachmentsSize'] as num?)?.toDouble() ?? 0.0,
  fileName: json['fileName'] as String? ?? '',
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$$SearchFileItemDtoImplToJson(
  _$SearchFileItemDtoImpl instance,
) => <String, dynamic>{
  'attachmentsId': instance.attachmentsId,
  'usersId': instance.usersId,
  'foldersId': instance.foldersId,
  'attachmentsType': instance.attachmentsType,
  'objectKey': instance.objectKey,
  'presignedUrl': instance.presignedUrl,
  'attachmentsExtension': instance.attachmentsExtension,
  'attachmentsSize': instance.attachmentsSize,
  'fileName': instance.fileName,
  'createdAt': instance.createdAt,
};
