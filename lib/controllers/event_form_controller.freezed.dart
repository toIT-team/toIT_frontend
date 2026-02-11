// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EventFormState {
  /// 이벤트 ID (null이면 생성 모드, 있으면 수정 모드)
  String? get id => throw _privateConstructorUsedError;

  /// 제목
  String get title => throw _privateConstructorUsedError;

  /// 시작 날짜
  DateTime? get startDate => throw _privateConstructorUsedError;

  /// 종료 날짜
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// 시작 시간 (HH:mm)
  String? get startTime => throw _privateConstructorUsedError;

  /// 종료 시간 (HH:mm)
  String? get endTime => throw _privateConstructorUsedError;

  /// 시간 설정 여부
  bool get timeSetting => throw _privateConstructorUsedError;

  /// 위치
  String? get location => throw _privateConstructorUsedError;

  /// 메모
  String? get memo => throw _privateConstructorUsedError;

  /// 알림 설정 (분 단위, 예: 10 = 10분 전)
  int? get alarmMinutes => throw _privateConstructorUsedError;

  /// 폴더/보관함 이름
  String? get folderName => throw _privateConstructorUsedError;

  /// 색상
  Color? get color => throw _privateConstructorUsedError;

  /// 저장 중 여부
  bool get isSaving => throw _privateConstructorUsedError;

  /// 유효성 검사 오류 메시지
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of EventFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventFormStateCopyWith<EventFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventFormStateCopyWith<$Res> {
  factory $EventFormStateCopyWith(
    EventFormState value,
    $Res Function(EventFormState) then,
  ) = _$EventFormStateCopyWithImpl<$Res, EventFormState>;
  @useResult
  $Res call({
    String? id,
    String title,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    bool timeSetting,
    String? location,
    String? memo,
    int? alarmMinutes,
    String? folderName,
    Color? color,
    bool isSaving,
    String? errorMessage,
  });
}

/// @nodoc
class _$EventFormStateCopyWithImpl<$Res, $Val extends EventFormState>
    implements $EventFormStateCopyWith<$Res> {
  _$EventFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? timeSetting = null,
    Object? location = freezed,
    Object? memo = freezed,
    Object? alarmMinutes = freezed,
    Object? folderName = freezed,
    Object? color = freezed,
    Object? isSaving = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            memo: freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String?,
            alarmMinutes: freezed == alarmMinutes
                ? _value.alarmMinutes
                : alarmMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            folderName: freezed == folderName
                ? _value.folderName
                : folderName // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as Color?,
            isSaving: null == isSaving
                ? _value.isSaving
                : isSaving // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventFormStateImplCopyWith<$Res>
    implements $EventFormStateCopyWith<$Res> {
  factory _$$EventFormStateImplCopyWith(
    _$EventFormStateImpl value,
    $Res Function(_$EventFormStateImpl) then,
  ) = __$$EventFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String title,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    bool timeSetting,
    String? location,
    String? memo,
    int? alarmMinutes,
    String? folderName,
    Color? color,
    bool isSaving,
    String? errorMessage,
  });
}

/// @nodoc
class __$$EventFormStateImplCopyWithImpl<$Res>
    extends _$EventFormStateCopyWithImpl<$Res, _$EventFormStateImpl>
    implements _$$EventFormStateImplCopyWith<$Res> {
  __$$EventFormStateImplCopyWithImpl(
    _$EventFormStateImpl _value,
    $Res Function(_$EventFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? timeSetting = null,
    Object? location = freezed,
    Object? memo = freezed,
    Object? alarmMinutes = freezed,
    Object? folderName = freezed,
    Object? color = freezed,
    Object? isSaving = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$EventFormStateImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        memo: freezed == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String?,
        alarmMinutes: freezed == alarmMinutes
            ? _value.alarmMinutes
            : alarmMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        folderName: freezed == folderName
            ? _value.folderName
            : folderName // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as Color?,
        isSaving: null == isSaving
            ? _value.isSaving
            : isSaving // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$EventFormStateImpl extends _EventFormState {
  const _$EventFormStateImpl({
    this.id,
    this.title = '',
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.timeSetting = false,
    this.location,
    this.memo,
    this.alarmMinutes,
    this.folderName,
    this.color,
    this.isSaving = false,
    this.errorMessage,
  }) : super._();

  /// 이벤트 ID (null이면 생성 모드, 있으면 수정 모드)
  @override
  final String? id;

  /// 제목
  @override
  @JsonKey()
  final String title;

  /// 시작 날짜
  @override
  final DateTime? startDate;

  /// 종료 날짜
  @override
  final DateTime? endDate;

  /// 시작 시간 (HH:mm)
  @override
  final String? startTime;

  /// 종료 시간 (HH:mm)
  @override
  final String? endTime;

  /// 시간 설정 여부
  @override
  @JsonKey()
  final bool timeSetting;

  /// 위치
  @override
  final String? location;

  /// 메모
  @override
  final String? memo;

  /// 알림 설정 (분 단위, 예: 10 = 10분 전)
  @override
  final int? alarmMinutes;

  /// 폴더/보관함 이름
  @override
  final String? folderName;

  /// 색상
  @override
  final Color? color;

  /// 저장 중 여부
  @override
  @JsonKey()
  final bool isSaving;

  /// 유효성 검사 오류 메시지
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'EventFormState(id: $id, title: $title, startDate: $startDate, endDate: $endDate, startTime: $startTime, endTime: $endTime, timeSetting: $timeSetting, location: $location, memo: $memo, alarmMinutes: $alarmMinutes, folderName: $folderName, color: $color, isSaving: $isSaving, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventFormStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.timeSetting, timeSetting) ||
                other.timeSetting == timeSetting) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.alarmMinutes, alarmMinutes) ||
                other.alarmMinutes == alarmMinutes) &&
            (identical(other.folderName, folderName) ||
                other.folderName == folderName) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    startDate,
    endDate,
    startTime,
    endTime,
    timeSetting,
    location,
    memo,
    alarmMinutes,
    folderName,
    color,
    isSaving,
    errorMessage,
  );

  /// Create a copy of EventFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventFormStateImplCopyWith<_$EventFormStateImpl> get copyWith =>
      __$$EventFormStateImplCopyWithImpl<_$EventFormStateImpl>(
        this,
        _$identity,
      );
}

abstract class _EventFormState extends EventFormState {
  const factory _EventFormState({
    final String? id,
    final String title,
    final DateTime? startDate,
    final DateTime? endDate,
    final String? startTime,
    final String? endTime,
    final bool timeSetting,
    final String? location,
    final String? memo,
    final int? alarmMinutes,
    final String? folderName,
    final Color? color,
    final bool isSaving,
    final String? errorMessage,
  }) = _$EventFormStateImpl;
  const _EventFormState._() : super._();

  /// 이벤트 ID (null이면 생성 모드, 있으면 수정 모드)
  @override
  String? get id;

  /// 제목
  @override
  String get title;

  /// 시작 날짜
  @override
  DateTime? get startDate;

  /// 종료 날짜
  @override
  DateTime? get endDate;

  /// 시작 시간 (HH:mm)
  @override
  String? get startTime;

  /// 종료 시간 (HH:mm)
  @override
  String? get endTime;

  /// 시간 설정 여부
  @override
  bool get timeSetting;

  /// 위치
  @override
  String? get location;

  /// 메모
  @override
  String? get memo;

  /// 알림 설정 (분 단위, 예: 10 = 10분 전)
  @override
  int? get alarmMinutes;

  /// 폴더/보관함 이름
  @override
  String? get folderName;

  /// 색상
  @override
  Color? get color;

  /// 저장 중 여부
  @override
  bool get isSaving;

  /// 유효성 검사 오류 메시지
  @override
  String? get errorMessage;

  /// Create a copy of EventFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventFormStateImplCopyWith<_$EventFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
