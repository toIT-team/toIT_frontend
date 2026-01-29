// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarEventImpl _$$CalendarEventImplFromJson(Map<String, dynamic> json) =>
    _$CalendarEventImpl(
      id: json['id'] as String,
      usersId: (json['usersId'] as num).toInt(),
      title: json['title'] as String,
      startAt: json['startAt'] as String,
      endAt: json['endAt'] as String,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      timeSetting: json['timeSetting'] as bool? ?? false,
      createdAt: _dateTimeFromJson(json['createdAt'] as String?),
    );

Map<String, dynamic> _$$CalendarEventImplToJson(_$CalendarEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'usersId': instance.usersId,
      'title': instance.title,
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'timeSetting': instance.timeSetting,
      'createdAt': _dateTimeToJson(instance.createdAt),
    };
