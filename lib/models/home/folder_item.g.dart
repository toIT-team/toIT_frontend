// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FolderItemImpl _$$FolderItemImplFromJson(Map<String, dynamic> json) =>
    _$FolderItemImpl(
      foldersId: (json['foldersId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String,
      memo: json['memo'] as String? ?? '',
      countText: json['countText'] as String,
      colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 5,
      isDefault: json['isDefault'] == null
          ? false
          : _boolFromJson(json['isDefault']),
    );

Map<String, dynamic> _$$FolderItemImplToJson(_$FolderItemImpl instance) =>
    <String, dynamic>{
      'foldersId': instance.foldersId,
      'title': instance.title,
      'memo': instance.memo,
      'countText': instance.countText,
      'colorIndex': instance.colorIndex,
      'isDefault': instance.isDefault,
    };
