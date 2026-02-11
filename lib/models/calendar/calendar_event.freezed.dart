// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) {
  return _CalendarEvent.fromJson(json);
}

/// @nodoc
mixin _$CalendarEvent {
  /// 클라이언트 식별용 ID (백엔드 ID 또는 자동 생성)
  String get id => throw _privateConstructorUsedError;

  /// 사용자 ID
  int get usersId => throw _privateConstructorUsedError;

  /// 일정 제목
  String get title => throw _privateConstructorUsedError;

  /// 시작 날짜 (YYYY-MM-DD 형식)
  @JsonKey(name: 'startAt')
  String get startAt => throw _privateConstructorUsedError;

  /// 종료 날짜 (YYYY-MM-DD 형식)
  @JsonKey(name: 'endAt')
  String get endAt => throw _privateConstructorUsedError;

  /// 시작 시간 (HH:mm 형식, nullable)
  String? get startTime => throw _privateConstructorUsedError;

  /// 종료 시간 (HH:mm 형식, nullable)
  String? get endTime => throw _privateConstructorUsedError;

  /// 시간 설정 여부
  bool get timeSetting => throw _privateConstructorUsedError;

  /// 보관함(폴더) 이름
  String? get folderName => throw _privateConstructorUsedError;

  /// 생성 일시
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// 표시 색상 (클라이언트 전용, JSON 제외)
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color get color => throw _privateConstructorUsedError;

  /// Serializes this CalendarEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarEventCopyWith<CalendarEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventCopyWith<$Res> {
  factory $CalendarEventCopyWith(
    CalendarEvent value,
    $Res Function(CalendarEvent) then,
  ) = _$CalendarEventCopyWithImpl<$Res, CalendarEvent>;
  @useResult
  $Res call({
    String id,
    int usersId,
    String title,
    @JsonKey(name: 'startAt') String startAt,
    @JsonKey(name: 'endAt') String endAt,
    String? startTime,
    String? endTime,
    bool timeSetting,
    String? folderName,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) Color color,
  });
}

/// @nodoc
class _$CalendarEventCopyWithImpl<$Res, $Val extends CalendarEvent>
    implements $CalendarEventCopyWith<$Res> {
  _$CalendarEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? usersId = null,
    Object? title = null,
    Object? startAt = null,
    Object? endAt = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? timeSetting = null,
    Object? folderName = freezed,
    Object? createdAt = freezed,
    Object? color = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            usersId: null == usersId
                ? _value.usersId
                : usersId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            startAt: null == startAt
                ? _value.startAt
                : startAt // ignore: cast_nullable_to_non_nullable
                      as String,
            endAt: null == endAt
                ? _value.endAt
                : endAt // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: freezed == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            timeSetting: null == timeSetting
                ? _value.timeSetting
                : timeSetting // ignore: cast_nullable_to_non_nullable
                      as bool,
            folderName: freezed == folderName
                ? _value.folderName
                : folderName // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as Color,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CalendarEventImplCopyWith<$Res>
    implements $CalendarEventCopyWith<$Res> {
  factory _$$CalendarEventImplCopyWith(
    _$CalendarEventImpl value,
    $Res Function(_$CalendarEventImpl) then,
  ) = __$$CalendarEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int usersId,
    String title,
    @JsonKey(name: 'startAt') String startAt,
    @JsonKey(name: 'endAt') String endAt,
    String? startTime,
    String? endTime,
    bool timeSetting,
    String? folderName,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) Color color,
  });
}

/// @nodoc
class __$$CalendarEventImplCopyWithImpl<$Res>
    extends _$CalendarEventCopyWithImpl<$Res, _$CalendarEventImpl>
    implements _$$CalendarEventImplCopyWith<$Res> {
  __$$CalendarEventImplCopyWithImpl(
    _$CalendarEventImpl _value,
    $Res Function(_$CalendarEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CalendarEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? usersId = null,
    Object? title = null,
    Object? startAt = null,
    Object? endAt = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? timeSetting = null,
    Object? folderName = freezed,
    Object? createdAt = freezed,
    Object? color = null,
  }) {
    return _then(
      _$CalendarEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        usersId: null == usersId
            ? _value.usersId
            : usersId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        startAt: null == startAt
            ? _value.startAt
            : startAt // ignore: cast_nullable_to_non_nullable
                  as String,
        endAt: null == endAt
            ? _value.endAt
            : endAt // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: freezed == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        timeSetting: null == timeSetting
            ? _value.timeSetting
            : timeSetting // ignore: cast_nullable_to_non_nullable
                  as bool,
        folderName: freezed == folderName
            ? _value.folderName
            : folderName // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as Color,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEventImpl extends _CalendarEvent {
  const _$CalendarEventImpl({
    required this.id,
    required this.usersId,
    required this.title,
    @JsonKey(name: 'startAt') required this.startAt,
    @JsonKey(name: 'endAt') required this.endAt,
    this.startTime,
    this.endTime,
    this.timeSetting = false,
    this.folderName,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    this.createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    this.color = const Color(0xFF4285F4),
  }) : super._();

  factory _$CalendarEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEventImplFromJson(json);

  /// 클라이언트 식별용 ID (백엔드 ID 또는 자동 생성)
  @override
  final String id;

  /// 사용자 ID
  @override
  final int usersId;

  /// 일정 제목
  @override
  final String title;

  /// 시작 날짜 (YYYY-MM-DD 형식)
  @override
  @JsonKey(name: 'startAt')
  final String startAt;

  /// 종료 날짜 (YYYY-MM-DD 형식)
  @override
  @JsonKey(name: 'endAt')
  final String endAt;

  /// 시작 시간 (HH:mm 형식, nullable)
  @override
  final String? startTime;

  /// 종료 시간 (HH:mm 형식, nullable)
  @override
  final String? endTime;

  /// 시간 설정 여부
  @override
  @JsonKey()
  final bool timeSetting;

  /// 보관함(폴더) 이름
  @override
  final String? folderName;

  /// 생성 일시
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;

  /// 표시 색상 (클라이언트 전용, JSON 제외)
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Color color;

  @override
  String toString() {
    return 'CalendarEvent(id: $id, usersId: $usersId, title: $title, startAt: $startAt, endAt: $endAt, startTime: $startTime, endTime: $endTime, timeSetting: $timeSetting, folderName: $folderName, createdAt: $createdAt, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.usersId, usersId) || other.usersId == usersId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.timeSetting, timeSetting) ||
                other.timeSetting == timeSetting) &&
            (identical(other.folderName, folderName) ||
                other.folderName == folderName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    usersId,
    title,
    startAt,
    endAt,
    startTime,
    endTime,
    timeSetting,
    folderName,
    createdAt,
    color,
  );

  /// Create a copy of CalendarEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventImplCopyWith<_$CalendarEventImpl> get copyWith =>
      __$$CalendarEventImplCopyWithImpl<_$CalendarEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventImplToJson(this);
  }
}

abstract class _CalendarEvent extends CalendarEvent {
  const factory _CalendarEvent({
    required final String id,
    required final int usersId,
    required final String title,
    @JsonKey(name: 'startAt') required final String startAt,
    @JsonKey(name: 'endAt') required final String endAt,
    final String? startTime,
    final String? endTime,
    final bool timeSetting,
    final String? folderName,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    final DateTime? createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) final Color color,
  }) = _$CalendarEventImpl;
  const _CalendarEvent._() : super._();

  factory _CalendarEvent.fromJson(Map<String, dynamic> json) =
      _$CalendarEventImpl.fromJson;

  /// 클라이언트 식별용 ID (백엔드 ID 또는 자동 생성)
  @override
  String get id;

  /// 사용자 ID
  @override
  int get usersId;

  /// 일정 제목
  @override
  String get title;

  /// 시작 날짜 (YYYY-MM-DD 형식)
  @override
  @JsonKey(name: 'startAt')
  String get startAt;

  /// 종료 날짜 (YYYY-MM-DD 형식)
  @override
  @JsonKey(name: 'endAt')
  String get endAt;

  /// 시작 시간 (HH:mm 형식, nullable)
  @override
  String? get startTime;

  /// 종료 시간 (HH:mm 형식, nullable)
  @override
  String? get endTime;

  /// 시간 설정 여부
  @override
  bool get timeSetting;

  /// 보관함(폴더) 이름
  @override
  String? get folderName;

  /// 생성 일시
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get createdAt;

  /// 표시 색상 (클라이언트 전용, JSON 제외)
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color get color;

  /// Create a copy of CalendarEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarEventImplCopyWith<_$CalendarEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
