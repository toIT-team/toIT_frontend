// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleImpl _$$ScheduleImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleImpl(
      schedulesId: (json['schedulesId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String,
      timeRangeText: json['timeRangeText'] as String,
      scheduleTime: json['scheduleTime'] as String,
    );

Map<String, dynamic> _$$ScheduleImplToJson(_$ScheduleImpl instance) =>
    <String, dynamic>{
      'schedulesId': instance.schedulesId,
      'title': instance.title,
      'timeRangeText': instance.timeRangeText,
      'scheduleTime': instance.scheduleTime,
    };
