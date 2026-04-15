// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleSearchResponseImpl _$$ScheduleSearchResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ScheduleSearchResponseImpl(
  userId: json['userId'] == null ? 0 : _intFromJson(json['userId']),
  schedulesResponses:
      (json['schedulesResponses'] as List<dynamic>?)
          ?.map((e) => ScheduleItemResponse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ScheduleSearchResponseImplToJson(
  _$ScheduleSearchResponseImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'schedulesResponses': instance.schedulesResponses,
};

_$ScheduleItemResponseImpl _$$ScheduleItemResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ScheduleItemResponseImpl(
  schedulesId: _intFromJson(json['schedulesId']),
  title: _stringFromJson(json['title']),
  startDate: _stringFromJson(json['startDate']),
  endDate: _stringFromJson(json['endDate']),
  appColor: json['appColor'] as String?,
);

Map<String, dynamic> _$$ScheduleItemResponseImplToJson(
  _$ScheduleItemResponseImpl instance,
) => <String, dynamic>{
  'schedulesId': instance.schedulesId,
  'title': instance.title,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'appColor': instance.appColor,
};

_$SelectedSchedulesResponseImpl _$$SelectedSchedulesResponseImplFromJson(
  Map<String, dynamic> json,
) => _$SelectedSchedulesResponseImpl(
  userId: json['userId'] == null ? 0 : _intFromJson(json['userId']),
  schedulesResponses:
      (json['schedulesResponses'] as List<dynamic>?)
          ?.map(
            (e) => SelectedScheduleItemResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$SelectedSchedulesResponseImplToJson(
  _$SelectedSchedulesResponseImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'schedulesResponses': instance.schedulesResponses,
};

_$SelectedScheduleItemResponseImpl _$$SelectedScheduleItemResponseImplFromJson(
  Map<String, dynamic> json,
) => _$SelectedScheduleItemResponseImpl(
  schedulesId: _intFromJson(json['schedulesId']),
  title: _stringFromJson(json['title']),
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  appColor: json['appColor'] as String?,
);

Map<String, dynamic> _$$SelectedScheduleItemResponseImplToJson(
  _$SelectedScheduleItemResponseImpl instance,
) => <String, dynamic>{
  'schedulesId': instance.schedulesId,
  'title': instance.title,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'appColor': instance.appColor,
};

_$ScheduleDetailResponseImpl _$$ScheduleDetailResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ScheduleDetailResponseImpl(
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  schedulesId: _intFromJson(json['schedulesId']),
  title: _stringFromJson(json['title']),
  foldersId: json['foldersId'] == null ? 0 : _intFromJson(json['foldersId']),
  foldersTitle: json['foldersTitle'] == null
      ? ''
      : _stringFromJson(json['foldersTitle']),
  timeSetting: json['timeSetting'] as bool? ?? false,
  startDate: _stringFromJson(json['startDate']),
  endDate: _stringFromJson(json['endDate']),
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  alarmState: json['alarmState'] as bool? ?? false,
  alarmOffsetMinutes: (json['alarmOffsetMinutes'] as num?)?.toInt() ?? 0,
  memo: json['memo'] == null ? '' : _stringFromJson(json['memo']),
);

Map<String, dynamic> _$$ScheduleDetailResponseImplToJson(
  _$ScheduleDetailResponseImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
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
