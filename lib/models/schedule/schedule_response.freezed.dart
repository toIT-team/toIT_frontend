// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScheduleSearchResponse _$ScheduleSearchResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ScheduleSearchResponse.fromJson(json);
}

/// @nodoc
mixin _$ScheduleSearchResponse {
  @JsonKey(fromJson: _intFromJson)
  int get userId => throw _privateConstructorUsedError;
  List<ScheduleItemResponse> get schedulesResponses =>
      throw _privateConstructorUsedError;

  /// Serializes this ScheduleSearchResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleSearchResponseCopyWith<ScheduleSearchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleSearchResponseCopyWith<$Res> {
  factory $ScheduleSearchResponseCopyWith(
    ScheduleSearchResponse value,
    $Res Function(ScheduleSearchResponse) then,
  ) = _$ScheduleSearchResponseCopyWithImpl<$Res, ScheduleSearchResponse>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int userId,
    List<ScheduleItemResponse> schedulesResponses,
  });
}

/// @nodoc
class _$ScheduleSearchResponseCopyWithImpl<
  $Res,
  $Val extends ScheduleSearchResponse
>
    implements $ScheduleSearchResponseCopyWith<$Res> {
  _$ScheduleSearchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? schedulesResponses = null}) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            schedulesResponses: null == schedulesResponses
                ? _value.schedulesResponses
                : schedulesResponses // ignore: cast_nullable_to_non_nullable
                      as List<ScheduleItemResponse>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduleSearchResponseImplCopyWith<$Res>
    implements $ScheduleSearchResponseCopyWith<$Res> {
  factory _$$ScheduleSearchResponseImplCopyWith(
    _$ScheduleSearchResponseImpl value,
    $Res Function(_$ScheduleSearchResponseImpl) then,
  ) = __$$ScheduleSearchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int userId,
    List<ScheduleItemResponse> schedulesResponses,
  });
}

/// @nodoc
class __$$ScheduleSearchResponseImplCopyWithImpl<$Res>
    extends
        _$ScheduleSearchResponseCopyWithImpl<$Res, _$ScheduleSearchResponseImpl>
    implements _$$ScheduleSearchResponseImplCopyWith<$Res> {
  __$$ScheduleSearchResponseImplCopyWithImpl(
    _$ScheduleSearchResponseImpl _value,
    $Res Function(_$ScheduleSearchResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduleSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? schedulesResponses = null}) {
    return _then(
      _$ScheduleSearchResponseImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        schedulesResponses: null == schedulesResponses
            ? _value._schedulesResponses
            : schedulesResponses // ignore: cast_nullable_to_non_nullable
                  as List<ScheduleItemResponse>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleSearchResponseImpl implements _ScheduleSearchResponse {
  const _$ScheduleSearchResponseImpl({
    @JsonKey(fromJson: _intFromJson) this.userId = 0,
    final List<ScheduleItemResponse> schedulesResponses = const [],
  }) : _schedulesResponses = schedulesResponses;

  factory _$ScheduleSearchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleSearchResponseImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int userId;
  final List<ScheduleItemResponse> _schedulesResponses;
  @override
  @JsonKey()
  List<ScheduleItemResponse> get schedulesResponses {
    if (_schedulesResponses is EqualUnmodifiableListView)
      return _schedulesResponses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedulesResponses);
  }

  @override
  String toString() {
    return 'ScheduleSearchResponse(userId: $userId, schedulesResponses: $schedulesResponses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleSearchResponseImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(
              other._schedulesResponses,
              _schedulesResponses,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    const DeepCollectionEquality().hash(_schedulesResponses),
  );

  /// Create a copy of ScheduleSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleSearchResponseImplCopyWith<_$ScheduleSearchResponseImpl>
  get copyWith =>
      __$$ScheduleSearchResponseImplCopyWithImpl<_$ScheduleSearchResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleSearchResponseImplToJson(this);
  }
}

abstract class _ScheduleSearchResponse implements ScheduleSearchResponse {
  const factory _ScheduleSearchResponse({
    @JsonKey(fromJson: _intFromJson) final int userId,
    final List<ScheduleItemResponse> schedulesResponses,
  }) = _$ScheduleSearchResponseImpl;

  factory _ScheduleSearchResponse.fromJson(Map<String, dynamic> json) =
      _$ScheduleSearchResponseImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get userId;
  @override
  List<ScheduleItemResponse> get schedulesResponses;

  /// Create a copy of ScheduleSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleSearchResponseImplCopyWith<_$ScheduleSearchResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ScheduleItemResponse _$ScheduleItemResponseFromJson(Map<String, dynamic> json) {
  return _ScheduleItemResponse.fromJson(json);
}

/// @nodoc
mixin _$ScheduleItemResponse {
  @JsonKey(fromJson: _intFromJson)
  int get schedulesId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get title => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get startDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get endDate => throw _privateConstructorUsedError;
  String? get appColor => throw _privateConstructorUsedError;

  /// Serializes this ScheduleItemResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleItemResponseCopyWith<ScheduleItemResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleItemResponseCopyWith<$Res> {
  factory $ScheduleItemResponseCopyWith(
    ScheduleItemResponse value,
    $Res Function(ScheduleItemResponse) then,
  ) = _$ScheduleItemResponseCopyWithImpl<$Res, ScheduleItemResponse>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int schedulesId,
    @JsonKey(fromJson: _stringFromJson) String title,
    @JsonKey(fromJson: _stringFromJson) String startDate,
    @JsonKey(fromJson: _stringFromJson) String endDate,
    String? appColor,
  });
}

/// @nodoc
class _$ScheduleItemResponseCopyWithImpl<
  $Res,
  $Val extends ScheduleItemResponse
>
    implements $ScheduleItemResponseCopyWith<$Res> {
  _$ScheduleItemResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schedulesId = null,
    Object? title = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? appColor = freezed,
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
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as String,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as String,
            appColor: freezed == appColor
                ? _value.appColor
                : appColor // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduleItemResponseImplCopyWith<$Res>
    implements $ScheduleItemResponseCopyWith<$Res> {
  factory _$$ScheduleItemResponseImplCopyWith(
    _$ScheduleItemResponseImpl value,
    $Res Function(_$ScheduleItemResponseImpl) then,
  ) = __$$ScheduleItemResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int schedulesId,
    @JsonKey(fromJson: _stringFromJson) String title,
    @JsonKey(fromJson: _stringFromJson) String startDate,
    @JsonKey(fromJson: _stringFromJson) String endDate,
    String? appColor,
  });
}

/// @nodoc
class __$$ScheduleItemResponseImplCopyWithImpl<$Res>
    extends _$ScheduleItemResponseCopyWithImpl<$Res, _$ScheduleItemResponseImpl>
    implements _$$ScheduleItemResponseImplCopyWith<$Res> {
  __$$ScheduleItemResponseImplCopyWithImpl(
    _$ScheduleItemResponseImpl _value,
    $Res Function(_$ScheduleItemResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduleItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schedulesId = null,
    Object? title = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? appColor = freezed,
  }) {
    return _then(
      _$ScheduleItemResponseImpl(
        schedulesId: null == schedulesId
            ? _value.schedulesId
            : schedulesId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as String,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as String,
        appColor: freezed == appColor
            ? _value.appColor
            : appColor // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleItemResponseImpl implements _ScheduleItemResponse {
  const _$ScheduleItemResponseImpl({
    @JsonKey(fromJson: _intFromJson) required this.schedulesId,
    @JsonKey(fromJson: _stringFromJson) required this.title,
    @JsonKey(fromJson: _stringFromJson) required this.startDate,
    @JsonKey(fromJson: _stringFromJson) required this.endDate,
    this.appColor,
  });

  factory _$ScheduleItemResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleItemResponseImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int schedulesId;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String title;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String startDate;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String endDate;
  @override
  final String? appColor;

  @override
  String toString() {
    return 'ScheduleItemResponse(schedulesId: $schedulesId, title: $title, startDate: $startDate, endDate: $endDate, appColor: $appColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleItemResponseImpl &&
            (identical(other.schedulesId, schedulesId) ||
                other.schedulesId == schedulesId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.appColor, appColor) ||
                other.appColor == appColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    schedulesId,
    title,
    startDate,
    endDate,
    appColor,
  );

  /// Create a copy of ScheduleItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleItemResponseImplCopyWith<_$ScheduleItemResponseImpl>
  get copyWith =>
      __$$ScheduleItemResponseImplCopyWithImpl<_$ScheduleItemResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleItemResponseImplToJson(this);
  }
}

abstract class _ScheduleItemResponse implements ScheduleItemResponse {
  const factory _ScheduleItemResponse({
    @JsonKey(fromJson: _intFromJson) required final int schedulesId,
    @JsonKey(fromJson: _stringFromJson) required final String title,
    @JsonKey(fromJson: _stringFromJson) required final String startDate,
    @JsonKey(fromJson: _stringFromJson) required final String endDate,
    final String? appColor,
  }) = _$ScheduleItemResponseImpl;

  factory _ScheduleItemResponse.fromJson(Map<String, dynamic> json) =
      _$ScheduleItemResponseImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get schedulesId;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get title;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get startDate;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get endDate;
  @override
  String? get appColor;

  /// Create a copy of ScheduleItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleItemResponseImplCopyWith<_$ScheduleItemResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SelectedSchedulesResponse _$SelectedSchedulesResponseFromJson(
  Map<String, dynamic> json,
) {
  return _SelectedSchedulesResponse.fromJson(json);
}

/// @nodoc
mixin _$SelectedSchedulesResponse {
  @JsonKey(fromJson: _intFromJson)
  int get userId => throw _privateConstructorUsedError;
  List<SelectedScheduleItemResponse> get schedulesResponses =>
      throw _privateConstructorUsedError;

  /// Serializes this SelectedSchedulesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SelectedSchedulesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SelectedSchedulesResponseCopyWith<SelectedSchedulesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectedSchedulesResponseCopyWith<$Res> {
  factory $SelectedSchedulesResponseCopyWith(
    SelectedSchedulesResponse value,
    $Res Function(SelectedSchedulesResponse) then,
  ) = _$SelectedSchedulesResponseCopyWithImpl<$Res, SelectedSchedulesResponse>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int userId,
    List<SelectedScheduleItemResponse> schedulesResponses,
  });
}

/// @nodoc
class _$SelectedSchedulesResponseCopyWithImpl<
  $Res,
  $Val extends SelectedSchedulesResponse
>
    implements $SelectedSchedulesResponseCopyWith<$Res> {
  _$SelectedSchedulesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SelectedSchedulesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? schedulesResponses = null}) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            schedulesResponses: null == schedulesResponses
                ? _value.schedulesResponses
                : schedulesResponses // ignore: cast_nullable_to_non_nullable
                      as List<SelectedScheduleItemResponse>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SelectedSchedulesResponseImplCopyWith<$Res>
    implements $SelectedSchedulesResponseCopyWith<$Res> {
  factory _$$SelectedSchedulesResponseImplCopyWith(
    _$SelectedSchedulesResponseImpl value,
    $Res Function(_$SelectedSchedulesResponseImpl) then,
  ) = __$$SelectedSchedulesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int userId,
    List<SelectedScheduleItemResponse> schedulesResponses,
  });
}

/// @nodoc
class __$$SelectedSchedulesResponseImplCopyWithImpl<$Res>
    extends
        _$SelectedSchedulesResponseCopyWithImpl<
          $Res,
          _$SelectedSchedulesResponseImpl
        >
    implements _$$SelectedSchedulesResponseImplCopyWith<$Res> {
  __$$SelectedSchedulesResponseImplCopyWithImpl(
    _$SelectedSchedulesResponseImpl _value,
    $Res Function(_$SelectedSchedulesResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SelectedSchedulesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? schedulesResponses = null}) {
    return _then(
      _$SelectedSchedulesResponseImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        schedulesResponses: null == schedulesResponses
            ? _value._schedulesResponses
            : schedulesResponses // ignore: cast_nullable_to_non_nullable
                  as List<SelectedScheduleItemResponse>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SelectedSchedulesResponseImpl implements _SelectedSchedulesResponse {
  const _$SelectedSchedulesResponseImpl({
    @JsonKey(fromJson: _intFromJson) this.userId = 0,
    final List<SelectedScheduleItemResponse> schedulesResponses = const [],
  }) : _schedulesResponses = schedulesResponses;

  factory _$SelectedSchedulesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SelectedSchedulesResponseImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int userId;
  final List<SelectedScheduleItemResponse> _schedulesResponses;
  @override
  @JsonKey()
  List<SelectedScheduleItemResponse> get schedulesResponses {
    if (_schedulesResponses is EqualUnmodifiableListView)
      return _schedulesResponses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedulesResponses);
  }

  @override
  String toString() {
    return 'SelectedSchedulesResponse(userId: $userId, schedulesResponses: $schedulesResponses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectedSchedulesResponseImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(
              other._schedulesResponses,
              _schedulesResponses,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    const DeepCollectionEquality().hash(_schedulesResponses),
  );

  /// Create a copy of SelectedSchedulesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectedSchedulesResponseImplCopyWith<_$SelectedSchedulesResponseImpl>
  get copyWith =>
      __$$SelectedSchedulesResponseImplCopyWithImpl<
        _$SelectedSchedulesResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SelectedSchedulesResponseImplToJson(this);
  }
}

abstract class _SelectedSchedulesResponse implements SelectedSchedulesResponse {
  const factory _SelectedSchedulesResponse({
    @JsonKey(fromJson: _intFromJson) final int userId,
    final List<SelectedScheduleItemResponse> schedulesResponses,
  }) = _$SelectedSchedulesResponseImpl;

  factory _SelectedSchedulesResponse.fromJson(Map<String, dynamic> json) =
      _$SelectedSchedulesResponseImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get userId;
  @override
  List<SelectedScheduleItemResponse> get schedulesResponses;

  /// Create a copy of SelectedSchedulesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectedSchedulesResponseImplCopyWith<_$SelectedSchedulesResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SelectedScheduleItemResponse _$SelectedScheduleItemResponseFromJson(
  Map<String, dynamic> json,
) {
  return _SelectedScheduleItemResponse.fromJson(json);
}

/// @nodoc
mixin _$SelectedScheduleItemResponse {
  @JsonKey(fromJson: _intFromJson)
  int get schedulesId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get title => throw _privateConstructorUsedError;
  String? get startTime => throw _privateConstructorUsedError;
  String? get endTime => throw _privateConstructorUsedError;
  String? get appColor => throw _privateConstructorUsedError;

  /// Serializes this SelectedScheduleItemResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SelectedScheduleItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SelectedScheduleItemResponseCopyWith<SelectedScheduleItemResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectedScheduleItemResponseCopyWith<$Res> {
  factory $SelectedScheduleItemResponseCopyWith(
    SelectedScheduleItemResponse value,
    $Res Function(SelectedScheduleItemResponse) then,
  ) =
      _$SelectedScheduleItemResponseCopyWithImpl<
        $Res,
        SelectedScheduleItemResponse
      >;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int schedulesId,
    @JsonKey(fromJson: _stringFromJson) String title,
    String? startTime,
    String? endTime,
    String? appColor,
  });
}

/// @nodoc
class _$SelectedScheduleItemResponseCopyWithImpl<
  $Res,
  $Val extends SelectedScheduleItemResponse
>
    implements $SelectedScheduleItemResponseCopyWith<$Res> {
  _$SelectedScheduleItemResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SelectedScheduleItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schedulesId = null,
    Object? title = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? appColor = freezed,
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
            startTime: freezed == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            appColor: freezed == appColor
                ? _value.appColor
                : appColor // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SelectedScheduleItemResponseImplCopyWith<$Res>
    implements $SelectedScheduleItemResponseCopyWith<$Res> {
  factory _$$SelectedScheduleItemResponseImplCopyWith(
    _$SelectedScheduleItemResponseImpl value,
    $Res Function(_$SelectedScheduleItemResponseImpl) then,
  ) = __$$SelectedScheduleItemResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int schedulesId,
    @JsonKey(fromJson: _stringFromJson) String title,
    String? startTime,
    String? endTime,
    String? appColor,
  });
}

/// @nodoc
class __$$SelectedScheduleItemResponseImplCopyWithImpl<$Res>
    extends
        _$SelectedScheduleItemResponseCopyWithImpl<
          $Res,
          _$SelectedScheduleItemResponseImpl
        >
    implements _$$SelectedScheduleItemResponseImplCopyWith<$Res> {
  __$$SelectedScheduleItemResponseImplCopyWithImpl(
    _$SelectedScheduleItemResponseImpl _value,
    $Res Function(_$SelectedScheduleItemResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SelectedScheduleItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schedulesId = null,
    Object? title = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? appColor = freezed,
  }) {
    return _then(
      _$SelectedScheduleItemResponseImpl(
        schedulesId: null == schedulesId
            ? _value.schedulesId
            : schedulesId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: freezed == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        appColor: freezed == appColor
            ? _value.appColor
            : appColor // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SelectedScheduleItemResponseImpl
    implements _SelectedScheduleItemResponse {
  const _$SelectedScheduleItemResponseImpl({
    @JsonKey(fromJson: _intFromJson) required this.schedulesId,
    @JsonKey(fromJson: _stringFromJson) required this.title,
    this.startTime,
    this.endTime,
    this.appColor,
  });

  factory _$SelectedScheduleItemResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$SelectedScheduleItemResponseImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int schedulesId;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String title;
  @override
  final String? startTime;
  @override
  final String? endTime;
  @override
  final String? appColor;

  @override
  String toString() {
    return 'SelectedScheduleItemResponse(schedulesId: $schedulesId, title: $title, startTime: $startTime, endTime: $endTime, appColor: $appColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectedScheduleItemResponseImpl &&
            (identical(other.schedulesId, schedulesId) ||
                other.schedulesId == schedulesId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.appColor, appColor) ||
                other.appColor == appColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    schedulesId,
    title,
    startTime,
    endTime,
    appColor,
  );

  /// Create a copy of SelectedScheduleItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectedScheduleItemResponseImplCopyWith<
    _$SelectedScheduleItemResponseImpl
  >
  get copyWith =>
      __$$SelectedScheduleItemResponseImplCopyWithImpl<
        _$SelectedScheduleItemResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SelectedScheduleItemResponseImplToJson(this);
  }
}

abstract class _SelectedScheduleItemResponse
    implements SelectedScheduleItemResponse {
  const factory _SelectedScheduleItemResponse({
    @JsonKey(fromJson: _intFromJson) required final int schedulesId,
    @JsonKey(fromJson: _stringFromJson) required final String title,
    final String? startTime,
    final String? endTime,
    final String? appColor,
  }) = _$SelectedScheduleItemResponseImpl;

  factory _SelectedScheduleItemResponse.fromJson(Map<String, dynamic> json) =
      _$SelectedScheduleItemResponseImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get schedulesId;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get title;
  @override
  String? get startTime;
  @override
  String? get endTime;
  @override
  String? get appColor;

  /// Create a copy of SelectedScheduleItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectedScheduleItemResponseImplCopyWith<
    _$SelectedScheduleItemResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ScheduleDetailResponse _$ScheduleDetailResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ScheduleDetailResponse.fromJson(json);
}

/// @nodoc
mixin _$ScheduleDetailResponse {
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get schedulesId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get title => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get foldersId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get foldersTitle => throw _privateConstructorUsedError;
  bool get timeSetting => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get startDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get endDate => throw _privateConstructorUsedError;
  String? get startTime => throw _privateConstructorUsedError;
  String? get endTime => throw _privateConstructorUsedError;
  bool get alarmState => throw _privateConstructorUsedError;
  int get alarmOffsetMinutes => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get memo => throw _privateConstructorUsedError;

  /// Serializes this ScheduleDetailResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleDetailResponseCopyWith<ScheduleDetailResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleDetailResponseCopyWith<$Res> {
  factory $ScheduleDetailResponseCopyWith(
    ScheduleDetailResponse value,
    $Res Function(ScheduleDetailResponse) then,
  ) = _$ScheduleDetailResponseCopyWithImpl<$Res, ScheduleDetailResponse>;
  @useResult
  $Res call({
    int userId,
    @JsonKey(fromJson: _intFromJson) int schedulesId,
    @JsonKey(fromJson: _stringFromJson) String title,
    @JsonKey(fromJson: _intFromJson) int foldersId,
    @JsonKey(fromJson: _stringFromJson) String foldersTitle,
    bool timeSetting,
    @JsonKey(fromJson: _stringFromJson) String startDate,
    @JsonKey(fromJson: _stringFromJson) String endDate,
    String? startTime,
    String? endTime,
    bool alarmState,
    int alarmOffsetMinutes,
    @JsonKey(fromJson: _stringFromJson) String memo,
  });
}

/// @nodoc
class _$ScheduleDetailResponseCopyWithImpl<
  $Res,
  $Val extends ScheduleDetailResponse
>
    implements $ScheduleDetailResponseCopyWith<$Res> {
  _$ScheduleDetailResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? schedulesId = null,
    Object? title = null,
    Object? foldersId = null,
    Object? foldersTitle = null,
    Object? timeSetting = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? alarmState = null,
    Object? alarmOffsetMinutes = null,
    Object? memo = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            schedulesId: null == schedulesId
                ? _value.schedulesId
                : schedulesId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            foldersId: null == foldersId
                ? _value.foldersId
                : foldersId // ignore: cast_nullable_to_non_nullable
                      as int,
            foldersTitle: null == foldersTitle
                ? _value.foldersTitle
                : foldersTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            timeSetting: null == timeSetting
                ? _value.timeSetting
                : timeSetting // ignore: cast_nullable_to_non_nullable
                      as bool,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as String,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: freezed == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            alarmState: null == alarmState
                ? _value.alarmState
                : alarmState // ignore: cast_nullable_to_non_nullable
                      as bool,
            alarmOffsetMinutes: null == alarmOffsetMinutes
                ? _value.alarmOffsetMinutes
                : alarmOffsetMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            memo: null == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduleDetailResponseImplCopyWith<$Res>
    implements $ScheduleDetailResponseCopyWith<$Res> {
  factory _$$ScheduleDetailResponseImplCopyWith(
    _$ScheduleDetailResponseImpl value,
    $Res Function(_$ScheduleDetailResponseImpl) then,
  ) = __$$ScheduleDetailResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int userId,
    @JsonKey(fromJson: _intFromJson) int schedulesId,
    @JsonKey(fromJson: _stringFromJson) String title,
    @JsonKey(fromJson: _intFromJson) int foldersId,
    @JsonKey(fromJson: _stringFromJson) String foldersTitle,
    bool timeSetting,
    @JsonKey(fromJson: _stringFromJson) String startDate,
    @JsonKey(fromJson: _stringFromJson) String endDate,
    String? startTime,
    String? endTime,
    bool alarmState,
    int alarmOffsetMinutes,
    @JsonKey(fromJson: _stringFromJson) String memo,
  });
}

/// @nodoc
class __$$ScheduleDetailResponseImplCopyWithImpl<$Res>
    extends
        _$ScheduleDetailResponseCopyWithImpl<$Res, _$ScheduleDetailResponseImpl>
    implements _$$ScheduleDetailResponseImplCopyWith<$Res> {
  __$$ScheduleDetailResponseImplCopyWithImpl(
    _$ScheduleDetailResponseImpl _value,
    $Res Function(_$ScheduleDetailResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduleDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? schedulesId = null,
    Object? title = null,
    Object? foldersId = null,
    Object? foldersTitle = null,
    Object? timeSetting = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? alarmState = null,
    Object? alarmOffsetMinutes = null,
    Object? memo = null,
  }) {
    return _then(
      _$ScheduleDetailResponseImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        schedulesId: null == schedulesId
            ? _value.schedulesId
            : schedulesId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        foldersId: null == foldersId
            ? _value.foldersId
            : foldersId // ignore: cast_nullable_to_non_nullable
                  as int,
        foldersTitle: null == foldersTitle
            ? _value.foldersTitle
            : foldersTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        timeSetting: null == timeSetting
            ? _value.timeSetting
            : timeSetting // ignore: cast_nullable_to_non_nullable
                  as bool,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as String,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: freezed == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        alarmState: null == alarmState
            ? _value.alarmState
            : alarmState // ignore: cast_nullable_to_non_nullable
                  as bool,
        alarmOffsetMinutes: null == alarmOffsetMinutes
            ? _value.alarmOffsetMinutes
            : alarmOffsetMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        memo: null == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleDetailResponseImpl implements _ScheduleDetailResponse {
  const _$ScheduleDetailResponseImpl({
    this.userId = 0,
    @JsonKey(fromJson: _intFromJson) required this.schedulesId,
    @JsonKey(fromJson: _stringFromJson) required this.title,
    @JsonKey(fromJson: _intFromJson) this.foldersId = 0,
    @JsonKey(fromJson: _stringFromJson) this.foldersTitle = '',
    this.timeSetting = false,
    @JsonKey(fromJson: _stringFromJson) required this.startDate,
    @JsonKey(fromJson: _stringFromJson) required this.endDate,
    this.startTime,
    this.endTime,
    this.alarmState = false,
    this.alarmOffsetMinutes = 0,
    @JsonKey(fromJson: _stringFromJson) this.memo = '',
  });

  factory _$ScheduleDetailResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleDetailResponseImplFromJson(json);

  @override
  @JsonKey()
  final int userId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int schedulesId;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String title;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int foldersId;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String foldersTitle;
  @override
  @JsonKey()
  final bool timeSetting;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String startDate;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String endDate;
  @override
  final String? startTime;
  @override
  final String? endTime;
  @override
  @JsonKey()
  final bool alarmState;
  @override
  @JsonKey()
  final int alarmOffsetMinutes;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String memo;

  @override
  String toString() {
    return 'ScheduleDetailResponse(userId: $userId, schedulesId: $schedulesId, title: $title, foldersId: $foldersId, foldersTitle: $foldersTitle, timeSetting: $timeSetting, startDate: $startDate, endDate: $endDate, startTime: $startTime, endTime: $endTime, alarmState: $alarmState, alarmOffsetMinutes: $alarmOffsetMinutes, memo: $memo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleDetailResponseImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.schedulesId, schedulesId) ||
                other.schedulesId == schedulesId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.foldersId, foldersId) ||
                other.foldersId == foldersId) &&
            (identical(other.foldersTitle, foldersTitle) ||
                other.foldersTitle == foldersTitle) &&
            (identical(other.timeSetting, timeSetting) ||
                other.timeSetting == timeSetting) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.alarmState, alarmState) ||
                other.alarmState == alarmState) &&
            (identical(other.alarmOffsetMinutes, alarmOffsetMinutes) ||
                other.alarmOffsetMinutes == alarmOffsetMinutes) &&
            (identical(other.memo, memo) || other.memo == memo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    schedulesId,
    title,
    foldersId,
    foldersTitle,
    timeSetting,
    startDate,
    endDate,
    startTime,
    endTime,
    alarmState,
    alarmOffsetMinutes,
    memo,
  );

  /// Create a copy of ScheduleDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleDetailResponseImplCopyWith<_$ScheduleDetailResponseImpl>
  get copyWith =>
      __$$ScheduleDetailResponseImplCopyWithImpl<_$ScheduleDetailResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleDetailResponseImplToJson(this);
  }
}

abstract class _ScheduleDetailResponse implements ScheduleDetailResponse {
  const factory _ScheduleDetailResponse({
    final int userId,
    @JsonKey(fromJson: _intFromJson) required final int schedulesId,
    @JsonKey(fromJson: _stringFromJson) required final String title,
    @JsonKey(fromJson: _intFromJson) final int foldersId,
    @JsonKey(fromJson: _stringFromJson) final String foldersTitle,
    final bool timeSetting,
    @JsonKey(fromJson: _stringFromJson) required final String startDate,
    @JsonKey(fromJson: _stringFromJson) required final String endDate,
    final String? startTime,
    final String? endTime,
    final bool alarmState,
    final int alarmOffsetMinutes,
    @JsonKey(fromJson: _stringFromJson) final String memo,
  }) = _$ScheduleDetailResponseImpl;

  factory _ScheduleDetailResponse.fromJson(Map<String, dynamic> json) =
      _$ScheduleDetailResponseImpl.fromJson;

  @override
  int get userId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get schedulesId;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get title;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get foldersId;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get foldersTitle;
  @override
  bool get timeSetting;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get startDate;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get endDate;
  @override
  String? get startTime;
  @override
  String? get endTime;
  @override
  bool get alarmState;
  @override
  int get alarmOffsetMinutes;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get memo;

  /// Create a copy of ScheduleDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleDetailResponseImplCopyWith<_$ScheduleDetailResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
