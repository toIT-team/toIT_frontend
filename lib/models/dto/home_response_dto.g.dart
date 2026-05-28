// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeResponseDtoImpl _$$HomeResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$HomeResponseDtoImpl(
  userId: json['userId'] == null ? 0 : _intFromJson(json['userId']),
  folders:
      (json['folders'] as List<dynamic>?)
          ?.map((e) => FolderDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  foldersViews:
      (json['foldersViews'] as List<dynamic>?)
          ?.map((e) => FolderViewDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  schedules:
      (json['schedules'] as List<dynamic>?)
          ?.map((e) => ScheduleDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$HomeResponseDtoImplToJson(
  _$HomeResponseDtoImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'folders': instance.folders,
  'foldersViews': instance.foldersViews,
  'schedules': instance.schedules,
};

_$FolderDtoImpl _$$FolderDtoImplFromJson(Map<String, dynamic> json) =>
    _$FolderDtoImpl(
      foldersId: json['foldersId'] == null
          ? 0
          : _intFromJson(json['foldersId']),
      usersId: json['usersId'] == null ? 0 : _intFromJson(json['usersId']),
      name: json['name'] as String? ?? '',
      memo: json['memo'] as String? ?? '',
      isDefault: json['isDefault'] == null
          ? false
          : _boolFromJson(json['isDefault']),
      color: json['color'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      iconIdx: (json['iconIdx'] as num?)?.toInt() ?? 0,
      itemsCount: (json['itemsCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$FolderDtoImplToJson(_$FolderDtoImpl instance) =>
    <String, dynamic>{
      'foldersId': instance.foldersId,
      'usersId': instance.usersId,
      'name': instance.name,
      'memo': instance.memo,
      'isDefault': instance.isDefault,
      'color': instance.color,
      'createdAt': instance.createdAt,
      'isFavorite': instance.isFavorite,
      'iconIdx': instance.iconIdx,
      'itemsCount': instance.itemsCount,
    };

_$FolderViewDtoImpl _$$FolderViewDtoImplFromJson(Map<String, dynamic> json) =>
    _$FolderViewDtoImpl(
      folderId: (json['folderId'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      lastViewedAt: json['lastViewedAt'] as String?,
    );

Map<String, dynamic> _$$FolderViewDtoImplToJson(_$FolderViewDtoImpl instance) =>
    <String, dynamic>{
      'folderId': instance.folderId,
      'name': instance.name,
      'lastViewedAt': instance.lastViewedAt,
    };

_$ScheduleDtoImpl _$$ScheduleDtoImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleDtoImpl(
      schedulesId: (json['schedulesId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      appColor: json['appColor'] as String? ?? '',
    );

Map<String, dynamic> _$$ScheduleDtoImplToJson(_$ScheduleDtoImpl instance) =>
    <String, dynamic>{
      'schedulesId': instance.schedulesId,
      'title': instance.title,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'appColor': instance.appColor,
    };
