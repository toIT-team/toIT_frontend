// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Schedule _$ScheduleFromJson(Map<String, dynamic> json) {
  return _Schedule.fromJson(json);
}

/// @nodoc
mixin _$Schedule {
  /// 서버 일정 ID (상세 화면 이동용)
  int get schedulesId => throw _privateConstructorUsedError;

  /// 일정 제목
  String get title => throw _privateConstructorUsedError;

  /// 시간 범위 텍스트 (예: "오후10:00 - 오후11:00")
  String get timeRangeText => throw _privateConstructorUsedError;

  /// 일정 시간 표시 (예: "30분 전", "오늘 마감")
  String get scheduleTime => throw _privateConstructorUsedError;

  /// 강조 색상 (JSON 제외)
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color get accentColor => throw _privateConstructorUsedError;

  /// Serializes this Schedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleCopyWith<Schedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleCopyWith<$Res> {
  factory $ScheduleCopyWith(Schedule value, $Res Function(Schedule) then) =
      _$ScheduleCopyWithImpl<$Res, Schedule>;
  @useResult
  $Res call({
    int schedulesId,
    String title,
    String timeRangeText,
    String scheduleTime,
    @JsonKey(includeFromJson: false, includeToJson: false) Color accentColor,
  });
}

/// @nodoc
class _$ScheduleCopyWithImpl<$Res, $Val extends Schedule>
    implements $ScheduleCopyWith<$Res> {
  _$ScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schedulesId = null,
    Object? title = null,
    Object? timeRangeText = null,
    Object? scheduleTime = null,
    Object? accentColor = null,
  }) {
    return _then(
      _value.copyWith(
            schedulesId: null == schedulesId
                ? _value.schedulesId
                : schedulesId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            timeRangeText: null == timeRangeText
                ? _value.timeRangeText
                : timeRangeText // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduleTime: null == scheduleTime
                ? _value.scheduleTime
                : scheduleTime // ignore: cast_nullable_to_non_nullable
                      as String,
            accentColor: null == accentColor
                ? _value.accentColor
                : accentColor // ignore: cast_nullable_to_non_nullable
                      as Color,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduleImplCopyWith<$Res>
    implements $ScheduleCopyWith<$Res> {
  factory _$$ScheduleImplCopyWith(
    _$ScheduleImpl value,
    $Res Function(_$ScheduleImpl) then,
  ) = __$$ScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int schedulesId,
    String title,
    String timeRangeText,
    String scheduleTime,
    @JsonKey(includeFromJson: false, includeToJson: false) Color accentColor,
  });
}

/// @nodoc
class __$$ScheduleImplCopyWithImpl<$Res>
    extends _$ScheduleCopyWithImpl<$Res, _$ScheduleImpl>
    implements _$$ScheduleImplCopyWith<$Res> {
  __$$ScheduleImplCopyWithImpl(
    _$ScheduleImpl _value,
    $Res Function(_$ScheduleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schedulesId = null,
    Object? title = null,
    Object? timeRangeText = null,
    Object? scheduleTime = null,
    Object? accentColor = null,
  }) {
    return _then(
      _$ScheduleImpl(
        schedulesId: null == schedulesId
            ? _value.schedulesId
            : schedulesId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        timeRangeText: null == timeRangeText
            ? _value.timeRangeText
            : timeRangeText // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduleTime: null == scheduleTime
            ? _value.scheduleTime
            : scheduleTime // ignore: cast_nullable_to_non_nullable
                  as String,
        accentColor: null == accentColor
            ? _value.accentColor
            : accentColor // ignore: cast_nullable_to_non_nullable
                  as Color,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleImpl implements _Schedule {
  const _$ScheduleImpl({
    this.schedulesId = 0,
    required this.title,
    required this.timeRangeText,
    required this.scheduleTime,
    @JsonKey(includeFromJson: false, includeToJson: false)
    this.accentColor = const Color(0xFF4285F4),
  });

  factory _$ScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleImplFromJson(json);

  /// 서버 일정 ID (상세 화면 이동용)
  @override
  @JsonKey()
  final int schedulesId;

  /// 일정 제목
  @override
  final String title;

  /// 시간 범위 텍스트 (예: "오후10:00 - 오후11:00")
  @override
  final String timeRangeText;

  /// 일정 시간 표시 (예: "30분 전", "오늘 마감")
  @override
  final String scheduleTime;

  /// 강조 색상 (JSON 제외)
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Color accentColor;

  @override
  String toString() {
    return 'Schedule(schedulesId: $schedulesId, title: $title, timeRangeText: $timeRangeText, scheduleTime: $scheduleTime, accentColor: $accentColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleImpl &&
            (identical(other.schedulesId, schedulesId) ||
                other.schedulesId == schedulesId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.timeRangeText, timeRangeText) ||
                other.timeRangeText == timeRangeText) &&
            (identical(other.scheduleTime, scheduleTime) ||
                other.scheduleTime == scheduleTime) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    schedulesId,
    title,
    timeRangeText,
    scheduleTime,
    accentColor,
  );

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleImplCopyWith<_$ScheduleImpl> get copyWith =>
      __$$ScheduleImplCopyWithImpl<_$ScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleImplToJson(this);
  }
}

abstract class _Schedule implements Schedule {
  const factory _Schedule({
    final int schedulesId,
    required final String title,
    required final String timeRangeText,
    required final String scheduleTime,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final Color accentColor,
  }) = _$ScheduleImpl;

  factory _Schedule.fromJson(Map<String, dynamic> json) =
      _$ScheduleImpl.fromJson;

  /// 서버 일정 ID (상세 화면 이동용)
  @override
  int get schedulesId;

  /// 일정 제목
  @override
  String get title;

  /// 시간 범위 텍스트 (예: "오후10:00 - 오후11:00")
  @override
  String get timeRangeText;

  /// 일정 시간 표시 (예: "30분 전", "오늘 마감")
  @override
  String get scheduleTime;

  /// 강조 색상 (JSON 제외)
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color get accentColor;

  /// Create a copy of Schedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleImplCopyWith<_$ScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
