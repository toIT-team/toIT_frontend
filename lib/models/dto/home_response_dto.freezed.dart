// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HomeResponseDto _$HomeResponseDtoFromJson(Map<String, dynamic> json) {
  return _HomeResponseDto.fromJson(json);
}

/// @nodoc
mixin _$HomeResponseDto {
  @JsonKey(fromJson: _intFromJson)
  int get userId => throw _privateConstructorUsedError;
  List<FolderDto> get folders => throw _privateConstructorUsedError;
  List<FolderViewDto> get foldersViews => throw _privateConstructorUsedError;
  List<ScheduleDto> get schedules => throw _privateConstructorUsedError;

  /// Serializes this HomeResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeResponseDtoCopyWith<HomeResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeResponseDtoCopyWith<$Res> {
  factory $HomeResponseDtoCopyWith(
    HomeResponseDto value,
    $Res Function(HomeResponseDto) then,
  ) = _$HomeResponseDtoCopyWithImpl<$Res, HomeResponseDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int userId,
    List<FolderDto> folders,
    List<FolderViewDto> foldersViews,
    List<ScheduleDto> schedules,
  });
}

/// @nodoc
class _$HomeResponseDtoCopyWithImpl<$Res, $Val extends HomeResponseDto>
    implements $HomeResponseDtoCopyWith<$Res> {
  _$HomeResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? folders = null,
    Object? foldersViews = null,
    Object? schedules = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            folders: null == folders
                ? _value.folders
                : folders // ignore: cast_nullable_to_non_nullable
                      as List<FolderDto>,
            foldersViews: null == foldersViews
                ? _value.foldersViews
                : foldersViews // ignore: cast_nullable_to_non_nullable
                      as List<FolderViewDto>,
            schedules: null == schedules
                ? _value.schedules
                : schedules // ignore: cast_nullable_to_non_nullable
                      as List<ScheduleDto>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HomeResponseDtoImplCopyWith<$Res>
    implements $HomeResponseDtoCopyWith<$Res> {
  factory _$$HomeResponseDtoImplCopyWith(
    _$HomeResponseDtoImpl value,
    $Res Function(_$HomeResponseDtoImpl) then,
  ) = __$$HomeResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int userId,
    List<FolderDto> folders,
    List<FolderViewDto> foldersViews,
    List<ScheduleDto> schedules,
  });
}

/// @nodoc
class __$$HomeResponseDtoImplCopyWithImpl<$Res>
    extends _$HomeResponseDtoCopyWithImpl<$Res, _$HomeResponseDtoImpl>
    implements _$$HomeResponseDtoImplCopyWith<$Res> {
  __$$HomeResponseDtoImplCopyWithImpl(
    _$HomeResponseDtoImpl _value,
    $Res Function(_$HomeResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? folders = null,
    Object? foldersViews = null,
    Object? schedules = null,
  }) {
    return _then(
      _$HomeResponseDtoImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        folders: null == folders
            ? _value._folders
            : folders // ignore: cast_nullable_to_non_nullable
                  as List<FolderDto>,
        foldersViews: null == foldersViews
            ? _value._foldersViews
            : foldersViews // ignore: cast_nullable_to_non_nullable
                  as List<FolderViewDto>,
        schedules: null == schedules
            ? _value._schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<ScheduleDto>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeResponseDtoImpl implements _HomeResponseDto {
  const _$HomeResponseDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.userId = 0,
    final List<FolderDto> folders = const [],
    final List<FolderViewDto> foldersViews = const [],
    final List<ScheduleDto> schedules = const [],
  }) : _folders = folders,
       _foldersViews = foldersViews,
       _schedules = schedules;

  factory _$HomeResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeResponseDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int userId;
  final List<FolderDto> _folders;
  @override
  @JsonKey()
  List<FolderDto> get folders {
    if (_folders is EqualUnmodifiableListView) return _folders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_folders);
  }

  final List<FolderViewDto> _foldersViews;
  @override
  @JsonKey()
  List<FolderViewDto> get foldersViews {
    if (_foldersViews is EqualUnmodifiableListView) return _foldersViews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_foldersViews);
  }

  final List<ScheduleDto> _schedules;
  @override
  @JsonKey()
  List<ScheduleDto> get schedules {
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedules);
  }

  @override
  String toString() {
    return 'HomeResponseDto(userId: $userId, folders: $folders, foldersViews: $foldersViews, schedules: $schedules)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeResponseDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._folders, _folders) &&
            const DeepCollectionEquality().equals(
              other._foldersViews,
              _foldersViews,
            ) &&
            const DeepCollectionEquality().equals(
              other._schedules,
              _schedules,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    const DeepCollectionEquality().hash(_folders),
    const DeepCollectionEquality().hash(_foldersViews),
    const DeepCollectionEquality().hash(_schedules),
  );

  /// Create a copy of HomeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeResponseDtoImplCopyWith<_$HomeResponseDtoImpl> get copyWith =>
      __$$HomeResponseDtoImplCopyWithImpl<_$HomeResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeResponseDtoImplToJson(this);
  }
}

abstract class _HomeResponseDto implements HomeResponseDto {
  const factory _HomeResponseDto({
    @JsonKey(fromJson: _intFromJson) final int userId,
    final List<FolderDto> folders,
    final List<FolderViewDto> foldersViews,
    final List<ScheduleDto> schedules,
  }) = _$HomeResponseDtoImpl;

  factory _HomeResponseDto.fromJson(Map<String, dynamic> json) =
      _$HomeResponseDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get userId;
  @override
  List<FolderDto> get folders;
  @override
  List<FolderViewDto> get foldersViews;
  @override
  List<ScheduleDto> get schedules;

  /// Create a copy of HomeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeResponseDtoImplCopyWith<_$HomeResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FolderDto _$FolderDtoFromJson(Map<String, dynamic> json) {
  return _FolderDto.fromJson(json);
}

/// @nodoc
mixin _$FolderDto {
  @JsonKey(fromJson: _intFromJson)
  int get foldersId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get usersId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get memo => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _boolFromJson)
  bool get isDefault => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  int get iconIdx => throw _privateConstructorUsedError;
  int get itemsCount => throw _privateConstructorUsedError;

  /// Serializes this FolderDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FolderDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FolderDtoCopyWith<FolderDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FolderDtoCopyWith<$Res> {
  factory $FolderDtoCopyWith(FolderDto value, $Res Function(FolderDto) then) =
      _$FolderDtoCopyWithImpl<$Res, FolderDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int foldersId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    String name,
    String memo,
    @JsonKey(fromJson: _boolFromJson) bool isDefault,
    String color,
    String? createdAt,
    bool isFavorite,
    int iconIdx,
    int itemsCount,
  });
}

/// @nodoc
class _$FolderDtoCopyWithImpl<$Res, $Val extends FolderDto>
    implements $FolderDtoCopyWith<$Res> {
  _$FolderDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FolderDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foldersId = null,
    Object? usersId = null,
    Object? name = null,
    Object? memo = null,
    Object? isDefault = null,
    Object? color = null,
    Object? createdAt = freezed,
    Object? isFavorite = null,
    Object? iconIdx = null,
    Object? itemsCount = null,
  }) {
    return _then(
      _value.copyWith(
            foldersId: null == foldersId
                ? _value.foldersId
                : foldersId // ignore: cast_nullable_to_non_nullable
                      as int,
            usersId: null == usersId
                ? _value.usersId
                : usersId // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            memo: null == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool,
            iconIdx: null == iconIdx
                ? _value.iconIdx
                : iconIdx // ignore: cast_nullable_to_non_nullable
                      as int,
            itemsCount: null == itemsCount
                ? _value.itemsCount
                : itemsCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FolderDtoImplCopyWith<$Res>
    implements $FolderDtoCopyWith<$Res> {
  factory _$$FolderDtoImplCopyWith(
    _$FolderDtoImpl value,
    $Res Function(_$FolderDtoImpl) then,
  ) = __$$FolderDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int foldersId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    String name,
    String memo,
    @JsonKey(fromJson: _boolFromJson) bool isDefault,
    String color,
    String? createdAt,
    bool isFavorite,
    int iconIdx,
    int itemsCount,
  });
}

/// @nodoc
class __$$FolderDtoImplCopyWithImpl<$Res>
    extends _$FolderDtoCopyWithImpl<$Res, _$FolderDtoImpl>
    implements _$$FolderDtoImplCopyWith<$Res> {
  __$$FolderDtoImplCopyWithImpl(
    _$FolderDtoImpl _value,
    $Res Function(_$FolderDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FolderDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foldersId = null,
    Object? usersId = null,
    Object? name = null,
    Object? memo = null,
    Object? isDefault = null,
    Object? color = null,
    Object? createdAt = freezed,
    Object? isFavorite = null,
    Object? iconIdx = null,
    Object? itemsCount = null,
  }) {
    return _then(
      _$FolderDtoImpl(
        foldersId: null == foldersId
            ? _value.foldersId
            : foldersId // ignore: cast_nullable_to_non_nullable
                  as int,
        usersId: null == usersId
            ? _value.usersId
            : usersId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        memo: null == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool,
        iconIdx: null == iconIdx
            ? _value.iconIdx
            : iconIdx // ignore: cast_nullable_to_non_nullable
                  as int,
        itemsCount: null == itemsCount
            ? _value.itemsCount
            : itemsCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FolderDtoImpl implements _FolderDto {
  const _$FolderDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.foldersId = 0,
    @JsonKey(fromJson: _intFromJson) this.usersId = 0,
    this.name = '',
    this.memo = '',
    @JsonKey(fromJson: _boolFromJson) this.isDefault = false,
    this.color = '',
    this.createdAt,
    this.isFavorite = false,
    this.iconIdx = 0,
    this.itemsCount = 0,
  });

  factory _$FolderDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FolderDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int foldersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int usersId;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String memo;
  @override
  @JsonKey(fromJson: _boolFromJson)
  final bool isDefault;
  @override
  @JsonKey()
  final String color;
  @override
  final String? createdAt;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  @JsonKey()
  final int iconIdx;
  @override
  @JsonKey()
  final int itemsCount;

  @override
  String toString() {
    return 'FolderDto(foldersId: $foldersId, usersId: $usersId, name: $name, memo: $memo, isDefault: $isDefault, color: $color, createdAt: $createdAt, isFavorite: $isFavorite, iconIdx: $iconIdx, itemsCount: $itemsCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FolderDtoImpl &&
            (identical(other.foldersId, foldersId) ||
                other.foldersId == foldersId) &&
            (identical(other.usersId, usersId) || other.usersId == usersId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.iconIdx, iconIdx) || other.iconIdx == iconIdx) &&
            (identical(other.itemsCount, itemsCount) ||
                other.itemsCount == itemsCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    foldersId,
    usersId,
    name,
    memo,
    isDefault,
    color,
    createdAt,
    isFavorite,
    iconIdx,
    itemsCount,
  );

  /// Create a copy of FolderDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FolderDtoImplCopyWith<_$FolderDtoImpl> get copyWith =>
      __$$FolderDtoImplCopyWithImpl<_$FolderDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FolderDtoImplToJson(this);
  }
}

abstract class _FolderDto implements FolderDto {
  const factory _FolderDto({
    @JsonKey(fromJson: _intFromJson) final int foldersId,
    @JsonKey(fromJson: _intFromJson) final int usersId,
    final String name,
    final String memo,
    @JsonKey(fromJson: _boolFromJson) final bool isDefault,
    final String color,
    final String? createdAt,
    final bool isFavorite,
    final int iconIdx,
    final int itemsCount,
  }) = _$FolderDtoImpl;

  factory _FolderDto.fromJson(Map<String, dynamic> json) =
      _$FolderDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get foldersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get usersId;
  @override
  String get name;
  @override
  String get memo;
  @override
  @JsonKey(fromJson: _boolFromJson)
  bool get isDefault;
  @override
  String get color;
  @override
  String? get createdAt;
  @override
  bool get isFavorite;
  @override
  int get iconIdx;
  @override
  int get itemsCount;

  /// Create a copy of FolderDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FolderDtoImplCopyWith<_$FolderDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FolderViewDto _$FolderViewDtoFromJson(Map<String, dynamic> json) {
  return _FolderViewDto.fromJson(json);
}

/// @nodoc
mixin _$FolderViewDto {
  int get folderId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get lastViewedAt => throw _privateConstructorUsedError;

  /// Serializes this FolderViewDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FolderViewDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FolderViewDtoCopyWith<FolderViewDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FolderViewDtoCopyWith<$Res> {
  factory $FolderViewDtoCopyWith(
    FolderViewDto value,
    $Res Function(FolderViewDto) then,
  ) = _$FolderViewDtoCopyWithImpl<$Res, FolderViewDto>;
  @useResult
  $Res call({int folderId, String name, String? lastViewedAt});
}

/// @nodoc
class _$FolderViewDtoCopyWithImpl<$Res, $Val extends FolderViewDto>
    implements $FolderViewDtoCopyWith<$Res> {
  _$FolderViewDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FolderViewDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? folderId = null,
    Object? name = null,
    Object? lastViewedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            folderId: null == folderId
                ? _value.folderId
                : folderId // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            lastViewedAt: freezed == lastViewedAt
                ? _value.lastViewedAt
                : lastViewedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FolderViewDtoImplCopyWith<$Res>
    implements $FolderViewDtoCopyWith<$Res> {
  factory _$$FolderViewDtoImplCopyWith(
    _$FolderViewDtoImpl value,
    $Res Function(_$FolderViewDtoImpl) then,
  ) = __$$FolderViewDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int folderId, String name, String? lastViewedAt});
}

/// @nodoc
class __$$FolderViewDtoImplCopyWithImpl<$Res>
    extends _$FolderViewDtoCopyWithImpl<$Res, _$FolderViewDtoImpl>
    implements _$$FolderViewDtoImplCopyWith<$Res> {
  __$$FolderViewDtoImplCopyWithImpl(
    _$FolderViewDtoImpl _value,
    $Res Function(_$FolderViewDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FolderViewDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? folderId = null,
    Object? name = null,
    Object? lastViewedAt = freezed,
  }) {
    return _then(
      _$FolderViewDtoImpl(
        folderId: null == folderId
            ? _value.folderId
            : folderId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        lastViewedAt: freezed == lastViewedAt
            ? _value.lastViewedAt
            : lastViewedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FolderViewDtoImpl implements _FolderViewDto {
  const _$FolderViewDtoImpl({
    this.folderId = 0,
    this.name = '',
    this.lastViewedAt,
  });

  factory _$FolderViewDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FolderViewDtoImplFromJson(json);

  @override
  @JsonKey()
  final int folderId;
  @override
  @JsonKey()
  final String name;
  @override
  final String? lastViewedAt;

  @override
  String toString() {
    return 'FolderViewDto(folderId: $folderId, name: $name, lastViewedAt: $lastViewedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FolderViewDtoImpl &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.lastViewedAt, lastViewedAt) ||
                other.lastViewedAt == lastViewedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, folderId, name, lastViewedAt);

  /// Create a copy of FolderViewDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FolderViewDtoImplCopyWith<_$FolderViewDtoImpl> get copyWith =>
      __$$FolderViewDtoImplCopyWithImpl<_$FolderViewDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FolderViewDtoImplToJson(this);
  }
}

abstract class _FolderViewDto implements FolderViewDto {
  const factory _FolderViewDto({
    final int folderId,
    final String name,
    final String? lastViewedAt,
  }) = _$FolderViewDtoImpl;

  factory _FolderViewDto.fromJson(Map<String, dynamic> json) =
      _$FolderViewDtoImpl.fromJson;

  @override
  int get folderId;
  @override
  String get name;
  @override
  String? get lastViewedAt;

  /// Create a copy of FolderViewDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FolderViewDtoImplCopyWith<_$FolderViewDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduleDto _$ScheduleDtoFromJson(Map<String, dynamic> json) {
  return _ScheduleDto.fromJson(json);
}

/// @nodoc
mixin _$ScheduleDto {
  int get schedulesId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get startTime => throw _privateConstructorUsedError;
  String? get endTime => throw _privateConstructorUsedError;
  String get appColor => throw _privateConstructorUsedError;

  /// Serializes this ScheduleDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleDtoCopyWith<ScheduleDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleDtoCopyWith<$Res> {
  factory $ScheduleDtoCopyWith(
    ScheduleDto value,
    $Res Function(ScheduleDto) then,
  ) = _$ScheduleDtoCopyWithImpl<$Res, ScheduleDto>;
  @useResult
  $Res call({
    int schedulesId,
    String title,
    String? startTime,
    String? endTime,
    String appColor,
  });
}

/// @nodoc
class _$ScheduleDtoCopyWithImpl<$Res, $Val extends ScheduleDto>
    implements $ScheduleDtoCopyWith<$Res> {
  _$ScheduleDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schedulesId = null,
    Object? title = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? appColor = null,
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
            appColor: null == appColor
                ? _value.appColor
                : appColor // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduleDtoImplCopyWith<$Res>
    implements $ScheduleDtoCopyWith<$Res> {
  factory _$$ScheduleDtoImplCopyWith(
    _$ScheduleDtoImpl value,
    $Res Function(_$ScheduleDtoImpl) then,
  ) = __$$ScheduleDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int schedulesId,
    String title,
    String? startTime,
    String? endTime,
    String appColor,
  });
}

/// @nodoc
class __$$ScheduleDtoImplCopyWithImpl<$Res>
    extends _$ScheduleDtoCopyWithImpl<$Res, _$ScheduleDtoImpl>
    implements _$$ScheduleDtoImplCopyWith<$Res> {
  __$$ScheduleDtoImplCopyWithImpl(
    _$ScheduleDtoImpl _value,
    $Res Function(_$ScheduleDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduleDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schedulesId = null,
    Object? title = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? appColor = null,
  }) {
    return _then(
      _$ScheduleDtoImpl(
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
        appColor: null == appColor
            ? _value.appColor
            : appColor // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleDtoImpl implements _ScheduleDto {
  const _$ScheduleDtoImpl({
    this.schedulesId = 0,
    this.title = '',
    this.startTime,
    this.endTime,
    this.appColor = '',
  });

  factory _$ScheduleDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleDtoImplFromJson(json);

  @override
  @JsonKey()
  final int schedulesId;
  @override
  @JsonKey()
  final String title;
  @override
  final String? startTime;
  @override
  final String? endTime;
  @override
  @JsonKey()
  final String appColor;

  @override
  String toString() {
    return 'ScheduleDto(schedulesId: $schedulesId, title: $title, startTime: $startTime, endTime: $endTime, appColor: $appColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleDtoImpl &&
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

  /// Create a copy of ScheduleDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleDtoImplCopyWith<_$ScheduleDtoImpl> get copyWith =>
      __$$ScheduleDtoImplCopyWithImpl<_$ScheduleDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleDtoImplToJson(this);
  }
}

abstract class _ScheduleDto implements ScheduleDto {
  const factory _ScheduleDto({
    final int schedulesId,
    final String title,
    final String? startTime,
    final String? endTime,
    final String appColor,
  }) = _$ScheduleDtoImpl;

  factory _ScheduleDto.fromJson(Map<String, dynamic> json) =
      _$ScheduleDtoImpl.fromJson;

  @override
  int get schedulesId;
  @override
  String get title;
  @override
  String? get startTime;
  @override
  String? get endTime;
  @override
  String get appColor;

  /// Create a copy of ScheduleDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleDtoImplCopyWith<_$ScheduleDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
