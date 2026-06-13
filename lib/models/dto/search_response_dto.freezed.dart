// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SearchResponseDto _$SearchResponseDtoFromJson(Map<String, dynamic> json) {
  return _SearchResponseDto.fromJson(json);
}

/// @nodoc
mixin _$SearchResponseDto {
  List<SearchFolderItemDto> get folders => throw _privateConstructorUsedError;
  List<SearchScheduleItemDto> get schedules =>
      throw _privateConstructorUsedError;
  List<SearchLinkItemDto> get links => throw _privateConstructorUsedError;
  List<SearchTextItemDto> get texts => throw _privateConstructorUsedError;
  List<SearchFileItemDto> get files => throw _privateConstructorUsedError;

  /// Serializes this SearchResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResponseDtoCopyWith<SearchResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResponseDtoCopyWith<$Res> {
  factory $SearchResponseDtoCopyWith(
    SearchResponseDto value,
    $Res Function(SearchResponseDto) then,
  ) = _$SearchResponseDtoCopyWithImpl<$Res, SearchResponseDto>;
  @useResult
  $Res call({
    List<SearchFolderItemDto> folders,
    List<SearchScheduleItemDto> schedules,
    List<SearchLinkItemDto> links,
    List<SearchTextItemDto> texts,
    List<SearchFileItemDto> files,
  });
}

/// @nodoc
class _$SearchResponseDtoCopyWithImpl<$Res, $Val extends SearchResponseDto>
    implements $SearchResponseDtoCopyWith<$Res> {
  _$SearchResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? folders = null,
    Object? schedules = null,
    Object? links = null,
    Object? texts = null,
    Object? files = null,
  }) {
    return _then(
      _value.copyWith(
            folders: null == folders
                ? _value.folders
                : folders // ignore: cast_nullable_to_non_nullable
                      as List<SearchFolderItemDto>,
            schedules: null == schedules
                ? _value.schedules
                : schedules // ignore: cast_nullable_to_non_nullable
                      as List<SearchScheduleItemDto>,
            links: null == links
                ? _value.links
                : links // ignore: cast_nullable_to_non_nullable
                      as List<SearchLinkItemDto>,
            texts: null == texts
                ? _value.texts
                : texts // ignore: cast_nullable_to_non_nullable
                      as List<SearchTextItemDto>,
            files: null == files
                ? _value.files
                : files // ignore: cast_nullable_to_non_nullable
                      as List<SearchFileItemDto>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchResponseDtoImplCopyWith<$Res>
    implements $SearchResponseDtoCopyWith<$Res> {
  factory _$$SearchResponseDtoImplCopyWith(
    _$SearchResponseDtoImpl value,
    $Res Function(_$SearchResponseDtoImpl) then,
  ) = __$$SearchResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<SearchFolderItemDto> folders,
    List<SearchScheduleItemDto> schedules,
    List<SearchLinkItemDto> links,
    List<SearchTextItemDto> texts,
    List<SearchFileItemDto> files,
  });
}

/// @nodoc
class __$$SearchResponseDtoImplCopyWithImpl<$Res>
    extends _$SearchResponseDtoCopyWithImpl<$Res, _$SearchResponseDtoImpl>
    implements _$$SearchResponseDtoImplCopyWith<$Res> {
  __$$SearchResponseDtoImplCopyWithImpl(
    _$SearchResponseDtoImpl _value,
    $Res Function(_$SearchResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? folders = null,
    Object? schedules = null,
    Object? links = null,
    Object? texts = null,
    Object? files = null,
  }) {
    return _then(
      _$SearchResponseDtoImpl(
        folders: null == folders
            ? _value._folders
            : folders // ignore: cast_nullable_to_non_nullable
                  as List<SearchFolderItemDto>,
        schedules: null == schedules
            ? _value._schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<SearchScheduleItemDto>,
        links: null == links
            ? _value._links
            : links // ignore: cast_nullable_to_non_nullable
                  as List<SearchLinkItemDto>,
        texts: null == texts
            ? _value._texts
            : texts // ignore: cast_nullable_to_non_nullable
                  as List<SearchTextItemDto>,
        files: null == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<SearchFileItemDto>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchResponseDtoImpl implements _SearchResponseDto {
  const _$SearchResponseDtoImpl({
    final List<SearchFolderItemDto> folders = const [],
    final List<SearchScheduleItemDto> schedules = const [],
    final List<SearchLinkItemDto> links = const [],
    final List<SearchTextItemDto> texts = const [],
    final List<SearchFileItemDto> files = const [],
  }) : _folders = folders,
       _schedules = schedules,
       _links = links,
       _texts = texts,
       _files = files;

  factory _$SearchResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchResponseDtoImplFromJson(json);

  final List<SearchFolderItemDto> _folders;
  @override
  @JsonKey()
  List<SearchFolderItemDto> get folders {
    if (_folders is EqualUnmodifiableListView) return _folders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_folders);
  }

  final List<SearchScheduleItemDto> _schedules;
  @override
  @JsonKey()
  List<SearchScheduleItemDto> get schedules {
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedules);
  }

  final List<SearchLinkItemDto> _links;
  @override
  @JsonKey()
  List<SearchLinkItemDto> get links {
    if (_links is EqualUnmodifiableListView) return _links;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_links);
  }

  final List<SearchTextItemDto> _texts;
  @override
  @JsonKey()
  List<SearchTextItemDto> get texts {
    if (_texts is EqualUnmodifiableListView) return _texts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_texts);
  }

  final List<SearchFileItemDto> _files;
  @override
  @JsonKey()
  List<SearchFileItemDto> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  @override
  String toString() {
    return 'SearchResponseDto(folders: $folders, schedules: $schedules, links: $links, texts: $texts, files: $files)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResponseDtoImpl &&
            const DeepCollectionEquality().equals(other._folders, _folders) &&
            const DeepCollectionEquality().equals(
              other._schedules,
              _schedules,
            ) &&
            const DeepCollectionEquality().equals(other._links, _links) &&
            const DeepCollectionEquality().equals(other._texts, _texts) &&
            const DeepCollectionEquality().equals(other._files, _files));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_folders),
    const DeepCollectionEquality().hash(_schedules),
    const DeepCollectionEquality().hash(_links),
    const DeepCollectionEquality().hash(_texts),
    const DeepCollectionEquality().hash(_files),
  );

  /// Create a copy of SearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResponseDtoImplCopyWith<_$SearchResponseDtoImpl> get copyWith =>
      __$$SearchResponseDtoImplCopyWithImpl<_$SearchResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchResponseDtoImplToJson(this);
  }
}

abstract class _SearchResponseDto implements SearchResponseDto {
  const factory _SearchResponseDto({
    final List<SearchFolderItemDto> folders,
    final List<SearchScheduleItemDto> schedules,
    final List<SearchLinkItemDto> links,
    final List<SearchTextItemDto> texts,
    final List<SearchFileItemDto> files,
  }) = _$SearchResponseDtoImpl;

  factory _SearchResponseDto.fromJson(Map<String, dynamic> json) =
      _$SearchResponseDtoImpl.fromJson;

  @override
  List<SearchFolderItemDto> get folders;
  @override
  List<SearchScheduleItemDto> get schedules;
  @override
  List<SearchLinkItemDto> get links;
  @override
  List<SearchTextItemDto> get texts;
  @override
  List<SearchFileItemDto> get files;

  /// Create a copy of SearchResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResponseDtoImplCopyWith<_$SearchResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchFolderItemDto _$SearchFolderItemDtoFromJson(Map<String, dynamic> json) {
  return _SearchFolderItemDto.fromJson(json);
}

/// @nodoc
mixin _$SearchFolderItemDto {
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
  @JsonKey(fromJson: _boolFromJson)
  bool get isFavorite => throw _privateConstructorUsedError;
  int get iconIdx => throw _privateConstructorUsedError;

  /// Serializes this SearchFolderItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchFolderItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchFolderItemDtoCopyWith<SearchFolderItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchFolderItemDtoCopyWith<$Res> {
  factory $SearchFolderItemDtoCopyWith(
    SearchFolderItemDto value,
    $Res Function(SearchFolderItemDto) then,
  ) = _$SearchFolderItemDtoCopyWithImpl<$Res, SearchFolderItemDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int foldersId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    String name,
    String memo,
    @JsonKey(fromJson: _boolFromJson) bool isDefault,
    String color,
    String? createdAt,
    @JsonKey(fromJson: _boolFromJson) bool isFavorite,
    int iconIdx,
  });
}

/// @nodoc
class _$SearchFolderItemDtoCopyWithImpl<$Res, $Val extends SearchFolderItemDto>
    implements $SearchFolderItemDtoCopyWith<$Res> {
  _$SearchFolderItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchFolderItemDto
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchFolderItemDtoImplCopyWith<$Res>
    implements $SearchFolderItemDtoCopyWith<$Res> {
  factory _$$SearchFolderItemDtoImplCopyWith(
    _$SearchFolderItemDtoImpl value,
    $Res Function(_$SearchFolderItemDtoImpl) then,
  ) = __$$SearchFolderItemDtoImplCopyWithImpl<$Res>;
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
    @JsonKey(fromJson: _boolFromJson) bool isFavorite,
    int iconIdx,
  });
}

/// @nodoc
class __$$SearchFolderItemDtoImplCopyWithImpl<$Res>
    extends _$SearchFolderItemDtoCopyWithImpl<$Res, _$SearchFolderItemDtoImpl>
    implements _$$SearchFolderItemDtoImplCopyWith<$Res> {
  __$$SearchFolderItemDtoImplCopyWithImpl(
    _$SearchFolderItemDtoImpl _value,
    $Res Function(_$SearchFolderItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchFolderItemDto
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
  }) {
    return _then(
      _$SearchFolderItemDtoImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchFolderItemDtoImpl implements _SearchFolderItemDto {
  const _$SearchFolderItemDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.foldersId = 0,
    @JsonKey(fromJson: _intFromJson) this.usersId = 0,
    this.name = '',
    this.memo = '',
    @JsonKey(fromJson: _boolFromJson) this.isDefault = false,
    this.color = '',
    this.createdAt,
    @JsonKey(fromJson: _boolFromJson) this.isFavorite = false,
    this.iconIdx = 0,
  });

  factory _$SearchFolderItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchFolderItemDtoImplFromJson(json);

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
  @JsonKey(fromJson: _boolFromJson)
  final bool isFavorite;
  @override
  @JsonKey()
  final int iconIdx;

  @override
  String toString() {
    return 'SearchFolderItemDto(foldersId: $foldersId, usersId: $usersId, name: $name, memo: $memo, isDefault: $isDefault, color: $color, createdAt: $createdAt, isFavorite: $isFavorite, iconIdx: $iconIdx)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchFolderItemDtoImpl &&
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
            (identical(other.iconIdx, iconIdx) || other.iconIdx == iconIdx));
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
  );

  /// Create a copy of SearchFolderItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchFolderItemDtoImplCopyWith<_$SearchFolderItemDtoImpl> get copyWith =>
      __$$SearchFolderItemDtoImplCopyWithImpl<_$SearchFolderItemDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchFolderItemDtoImplToJson(this);
  }
}

abstract class _SearchFolderItemDto implements SearchFolderItemDto {
  const factory _SearchFolderItemDto({
    @JsonKey(fromJson: _intFromJson) final int foldersId,
    @JsonKey(fromJson: _intFromJson) final int usersId,
    final String name,
    final String memo,
    @JsonKey(fromJson: _boolFromJson) final bool isDefault,
    final String color,
    final String? createdAt,
    @JsonKey(fromJson: _boolFromJson) final bool isFavorite,
    final int iconIdx,
  }) = _$SearchFolderItemDtoImpl;

  factory _SearchFolderItemDto.fromJson(Map<String, dynamic> json) =
      _$SearchFolderItemDtoImpl.fromJson;

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
  @JsonKey(fromJson: _boolFromJson)
  bool get isFavorite;
  @override
  int get iconIdx;

  /// Create a copy of SearchFolderItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchFolderItemDtoImplCopyWith<_$SearchFolderItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchScheduleItemDto _$SearchScheduleItemDtoFromJson(
  Map<String, dynamic> json,
) {
  return _SearchScheduleItemDto.fromJson(json);
}

/// @nodoc
mixin _$SearchScheduleItemDto {
  @JsonKey(fromJson: _intFromJson)
  int get usersId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get schedulesId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get foldersId => throw _privateConstructorUsedError;
  String get foldersTitle => throw _privateConstructorUsedError;
  bool get timeSetting => throw _privateConstructorUsedError;
  String get startDate => throw _privateConstructorUsedError;
  String get endDate => throw _privateConstructorUsedError;
  String? get startTime => throw _privateConstructorUsedError;
  String? get endTime =>
      throw _privateConstructorUsedError; // TODO(알림-비활성화): 테스트 중 임시 주석 — 백엔드 미지원
  // @Default(false) bool alarmState,
  // @Default(0) int alarmOffsetMinutes,
  String get memo => throw _privateConstructorUsedError;

  /// Serializes this SearchScheduleItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchScheduleItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchScheduleItemDtoCopyWith<SearchScheduleItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchScheduleItemDtoCopyWith<$Res> {
  factory $SearchScheduleItemDtoCopyWith(
    SearchScheduleItemDto value,
    $Res Function(SearchScheduleItemDto) then,
  ) = _$SearchScheduleItemDtoCopyWithImpl<$Res, SearchScheduleItemDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int usersId,
    @JsonKey(fromJson: _intFromJson) int schedulesId,
    String title,
    int foldersId,
    String foldersTitle,
    bool timeSetting,
    String startDate,
    String endDate,
    String? startTime,
    String? endTime,
    String memo,
  });
}

/// @nodoc
class _$SearchScheduleItemDtoCopyWithImpl<
  $Res,
  $Val extends SearchScheduleItemDto
>
    implements $SearchScheduleItemDtoCopyWith<$Res> {
  _$SearchScheduleItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchScheduleItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usersId = null,
    Object? schedulesId = null,
    Object? title = null,
    Object? foldersId = null,
    Object? foldersTitle = null,
    Object? timeSetting = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? memo = null,
  }) {
    return _then(
      _value.copyWith(
            usersId: null == usersId
                ? _value.usersId
                : usersId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SearchScheduleItemDtoImplCopyWith<$Res>
    implements $SearchScheduleItemDtoCopyWith<$Res> {
  factory _$$SearchScheduleItemDtoImplCopyWith(
    _$SearchScheduleItemDtoImpl value,
    $Res Function(_$SearchScheduleItemDtoImpl) then,
  ) = __$$SearchScheduleItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int usersId,
    @JsonKey(fromJson: _intFromJson) int schedulesId,
    String title,
    int foldersId,
    String foldersTitle,
    bool timeSetting,
    String startDate,
    String endDate,
    String? startTime,
    String? endTime,
    String memo,
  });
}

/// @nodoc
class __$$SearchScheduleItemDtoImplCopyWithImpl<$Res>
    extends
        _$SearchScheduleItemDtoCopyWithImpl<$Res, _$SearchScheduleItemDtoImpl>
    implements _$$SearchScheduleItemDtoImplCopyWith<$Res> {
  __$$SearchScheduleItemDtoImplCopyWithImpl(
    _$SearchScheduleItemDtoImpl _value,
    $Res Function(_$SearchScheduleItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchScheduleItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usersId = null,
    Object? schedulesId = null,
    Object? title = null,
    Object? foldersId = null,
    Object? foldersTitle = null,
    Object? timeSetting = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? memo = null,
  }) {
    return _then(
      _$SearchScheduleItemDtoImpl(
        usersId: null == usersId
            ? _value.usersId
            : usersId // ignore: cast_nullable_to_non_nullable
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
class _$SearchScheduleItemDtoImpl implements _SearchScheduleItemDto {
  const _$SearchScheduleItemDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.usersId = 0,
    @JsonKey(fromJson: _intFromJson) this.schedulesId = 0,
    this.title = '',
    this.foldersId = 0,
    this.foldersTitle = '',
    this.timeSetting = false,
    this.startDate = '',
    this.endDate = '',
    this.startTime,
    this.endTime,
    this.memo = '',
  });

  factory _$SearchScheduleItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchScheduleItemDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int usersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int schedulesId;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final int foldersId;
  @override
  @JsonKey()
  final String foldersTitle;
  @override
  @JsonKey()
  final bool timeSetting;
  @override
  @JsonKey()
  final String startDate;
  @override
  @JsonKey()
  final String endDate;
  @override
  final String? startTime;
  @override
  final String? endTime;
  // TODO(알림-비활성화): 테스트 중 임시 주석 — 백엔드 미지원
  // @Default(false) bool alarmState,
  // @Default(0) int alarmOffsetMinutes,
  @override
  @JsonKey()
  final String memo;

  @override
  String toString() {
    return 'SearchScheduleItemDto(usersId: $usersId, schedulesId: $schedulesId, title: $title, foldersId: $foldersId, foldersTitle: $foldersTitle, timeSetting: $timeSetting, startDate: $startDate, endDate: $endDate, startTime: $startTime, endTime: $endTime, memo: $memo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchScheduleItemDtoImpl &&
            (identical(other.usersId, usersId) || other.usersId == usersId) &&
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
            (identical(other.memo, memo) || other.memo == memo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    usersId,
    schedulesId,
    title,
    foldersId,
    foldersTitle,
    timeSetting,
    startDate,
    endDate,
    startTime,
    endTime,
    memo,
  );

  /// Create a copy of SearchScheduleItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchScheduleItemDtoImplCopyWith<_$SearchScheduleItemDtoImpl>
  get copyWith =>
      __$$SearchScheduleItemDtoImplCopyWithImpl<_$SearchScheduleItemDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchScheduleItemDtoImplToJson(this);
  }
}

abstract class _SearchScheduleItemDto implements SearchScheduleItemDto {
  const factory _SearchScheduleItemDto({
    @JsonKey(fromJson: _intFromJson) final int usersId,
    @JsonKey(fromJson: _intFromJson) final int schedulesId,
    final String title,
    final int foldersId,
    final String foldersTitle,
    final bool timeSetting,
    final String startDate,
    final String endDate,
    final String? startTime,
    final String? endTime,
    final String memo,
  }) = _$SearchScheduleItemDtoImpl;

  factory _SearchScheduleItemDto.fromJson(Map<String, dynamic> json) =
      _$SearchScheduleItemDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get usersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get schedulesId;
  @override
  String get title;
  @override
  int get foldersId;
  @override
  String get foldersTitle;
  @override
  bool get timeSetting;
  @override
  String get startDate;
  @override
  String get endDate;
  @override
  String? get startTime;
  @override
  String? get endTime; // TODO(알림-비활성화): 테스트 중 임시 주석 — 백엔드 미지원
  // @Default(false) bool alarmState,
  // @Default(0) int alarmOffsetMinutes,
  @override
  String get memo;

  /// Create a copy of SearchScheduleItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchScheduleItemDtoImplCopyWith<_$SearchScheduleItemDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SearchLinkItemDto _$SearchLinkItemDtoFromJson(Map<String, dynamic> json) {
  return _SearchLinkItemDto.fromJson(json);
}

/// @nodoc
mixin _$SearchLinkItemDto {
  @JsonKey(fromJson: _intFromJson)
  int get linksId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get foldersId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get usersId => throw _privateConstructorUsedError;
  String get linksName => throw _privateConstructorUsedError;
  String get linksUrl => throw _privateConstructorUsedError;
  String get linksThumbnail => throw _privateConstructorUsedError;
  String get textContent => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String get foldersName => throw _privateConstructorUsedError;
  String get dayOfWeek => throw _privateConstructorUsedError;

  /// Serializes this SearchLinkItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchLinkItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchLinkItemDtoCopyWith<SearchLinkItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchLinkItemDtoCopyWith<$Res> {
  factory $SearchLinkItemDtoCopyWith(
    SearchLinkItemDto value,
    $Res Function(SearchLinkItemDto) then,
  ) = _$SearchLinkItemDtoCopyWithImpl<$Res, SearchLinkItemDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int linksId,
    @JsonKey(fromJson: _intFromJson) int foldersId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    String linksName,
    String linksUrl,
    String linksThumbnail,
    String textContent,
    String? createdAt,
    String foldersName,
    String dayOfWeek,
  });
}

/// @nodoc
class _$SearchLinkItemDtoCopyWithImpl<$Res, $Val extends SearchLinkItemDto>
    implements $SearchLinkItemDtoCopyWith<$Res> {
  _$SearchLinkItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchLinkItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linksId = null,
    Object? foldersId = null,
    Object? usersId = null,
    Object? linksName = null,
    Object? linksUrl = null,
    Object? linksThumbnail = null,
    Object? textContent = null,
    Object? createdAt = freezed,
    Object? foldersName = null,
    Object? dayOfWeek = null,
  }) {
    return _then(
      _value.copyWith(
            linksId: null == linksId
                ? _value.linksId
                : linksId // ignore: cast_nullable_to_non_nullable
                      as int,
            foldersId: null == foldersId
                ? _value.foldersId
                : foldersId // ignore: cast_nullable_to_non_nullable
                      as int,
            usersId: null == usersId
                ? _value.usersId
                : usersId // ignore: cast_nullable_to_non_nullable
                      as int,
            linksName: null == linksName
                ? _value.linksName
                : linksName // ignore: cast_nullable_to_non_nullable
                      as String,
            linksUrl: null == linksUrl
                ? _value.linksUrl
                : linksUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            linksThumbnail: null == linksThumbnail
                ? _value.linksThumbnail
                : linksThumbnail // ignore: cast_nullable_to_non_nullable
                      as String,
            textContent: null == textContent
                ? _value.textContent
                : textContent // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            foldersName: null == foldersName
                ? _value.foldersName
                : foldersName // ignore: cast_nullable_to_non_nullable
                      as String,
            dayOfWeek: null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchLinkItemDtoImplCopyWith<$Res>
    implements $SearchLinkItemDtoCopyWith<$Res> {
  factory _$$SearchLinkItemDtoImplCopyWith(
    _$SearchLinkItemDtoImpl value,
    $Res Function(_$SearchLinkItemDtoImpl) then,
  ) = __$$SearchLinkItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int linksId,
    @JsonKey(fromJson: _intFromJson) int foldersId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    String linksName,
    String linksUrl,
    String linksThumbnail,
    String textContent,
    String? createdAt,
    String foldersName,
    String dayOfWeek,
  });
}

/// @nodoc
class __$$SearchLinkItemDtoImplCopyWithImpl<$Res>
    extends _$SearchLinkItemDtoCopyWithImpl<$Res, _$SearchLinkItemDtoImpl>
    implements _$$SearchLinkItemDtoImplCopyWith<$Res> {
  __$$SearchLinkItemDtoImplCopyWithImpl(
    _$SearchLinkItemDtoImpl _value,
    $Res Function(_$SearchLinkItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchLinkItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linksId = null,
    Object? foldersId = null,
    Object? usersId = null,
    Object? linksName = null,
    Object? linksUrl = null,
    Object? linksThumbnail = null,
    Object? textContent = null,
    Object? createdAt = freezed,
    Object? foldersName = null,
    Object? dayOfWeek = null,
  }) {
    return _then(
      _$SearchLinkItemDtoImpl(
        linksId: null == linksId
            ? _value.linksId
            : linksId // ignore: cast_nullable_to_non_nullable
                  as int,
        foldersId: null == foldersId
            ? _value.foldersId
            : foldersId // ignore: cast_nullable_to_non_nullable
                  as int,
        usersId: null == usersId
            ? _value.usersId
            : usersId // ignore: cast_nullable_to_non_nullable
                  as int,
        linksName: null == linksName
            ? _value.linksName
            : linksName // ignore: cast_nullable_to_non_nullable
                  as String,
        linksUrl: null == linksUrl
            ? _value.linksUrl
            : linksUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        linksThumbnail: null == linksThumbnail
            ? _value.linksThumbnail
            : linksThumbnail // ignore: cast_nullable_to_non_nullable
                  as String,
        textContent: null == textContent
            ? _value.textContent
            : textContent // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        foldersName: null == foldersName
            ? _value.foldersName
            : foldersName // ignore: cast_nullable_to_non_nullable
                  as String,
        dayOfWeek: null == dayOfWeek
            ? _value.dayOfWeek
            : dayOfWeek // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchLinkItemDtoImpl implements _SearchLinkItemDto {
  const _$SearchLinkItemDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.linksId = 0,
    @JsonKey(fromJson: _intFromJson) this.foldersId = 0,
    @JsonKey(fromJson: _intFromJson) this.usersId = 0,
    this.linksName = '',
    this.linksUrl = '',
    this.linksThumbnail = '',
    this.textContent = '',
    this.createdAt,
    this.foldersName = '',
    this.dayOfWeek = '',
  });

  factory _$SearchLinkItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchLinkItemDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int linksId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int foldersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int usersId;
  @override
  @JsonKey()
  final String linksName;
  @override
  @JsonKey()
  final String linksUrl;
  @override
  @JsonKey()
  final String linksThumbnail;
  @override
  @JsonKey()
  final String textContent;
  @override
  final String? createdAt;
  @override
  @JsonKey()
  final String foldersName;
  @override
  @JsonKey()
  final String dayOfWeek;

  @override
  String toString() {
    return 'SearchLinkItemDto(linksId: $linksId, foldersId: $foldersId, usersId: $usersId, linksName: $linksName, linksUrl: $linksUrl, linksThumbnail: $linksThumbnail, textContent: $textContent, createdAt: $createdAt, foldersName: $foldersName, dayOfWeek: $dayOfWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchLinkItemDtoImpl &&
            (identical(other.linksId, linksId) || other.linksId == linksId) &&
            (identical(other.foldersId, foldersId) ||
                other.foldersId == foldersId) &&
            (identical(other.usersId, usersId) || other.usersId == usersId) &&
            (identical(other.linksName, linksName) ||
                other.linksName == linksName) &&
            (identical(other.linksUrl, linksUrl) ||
                other.linksUrl == linksUrl) &&
            (identical(other.linksThumbnail, linksThumbnail) ||
                other.linksThumbnail == linksThumbnail) &&
            (identical(other.textContent, textContent) ||
                other.textContent == textContent) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.foldersName, foldersName) ||
                other.foldersName == foldersName) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    linksId,
    foldersId,
    usersId,
    linksName,
    linksUrl,
    linksThumbnail,
    textContent,
    createdAt,
    foldersName,
    dayOfWeek,
  );

  /// Create a copy of SearchLinkItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchLinkItemDtoImplCopyWith<_$SearchLinkItemDtoImpl> get copyWith =>
      __$$SearchLinkItemDtoImplCopyWithImpl<_$SearchLinkItemDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchLinkItemDtoImplToJson(this);
  }
}

abstract class _SearchLinkItemDto implements SearchLinkItemDto {
  const factory _SearchLinkItemDto({
    @JsonKey(fromJson: _intFromJson) final int linksId,
    @JsonKey(fromJson: _intFromJson) final int foldersId,
    @JsonKey(fromJson: _intFromJson) final int usersId,
    final String linksName,
    final String linksUrl,
    final String linksThumbnail,
    final String textContent,
    final String? createdAt,
    final String foldersName,
    final String dayOfWeek,
  }) = _$SearchLinkItemDtoImpl;

  factory _SearchLinkItemDto.fromJson(Map<String, dynamic> json) =
      _$SearchLinkItemDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get linksId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get foldersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get usersId;
  @override
  String get linksName;
  @override
  String get linksUrl;
  @override
  String get linksThumbnail;
  @override
  String get textContent;
  @override
  String? get createdAt;
  @override
  String get foldersName;
  @override
  String get dayOfWeek;

  /// Create a copy of SearchLinkItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchLinkItemDtoImplCopyWith<_$SearchLinkItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchTextItemDto _$SearchTextItemDtoFromJson(Map<String, dynamic> json) {
  return _SearchTextItemDto.fromJson(json);
}

/// @nodoc
mixin _$SearchTextItemDto {
  @JsonKey(fromJson: _intFromJson)
  int get textsId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get usersId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get foldersId => throw _privateConstructorUsedError;
  String get textContent => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String get foldersName => throw _privateConstructorUsedError;
  String get dayOfWeek => throw _privateConstructorUsedError;

  /// Serializes this SearchTextItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchTextItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchTextItemDtoCopyWith<SearchTextItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchTextItemDtoCopyWith<$Res> {
  factory $SearchTextItemDtoCopyWith(
    SearchTextItemDto value,
    $Res Function(SearchTextItemDto) then,
  ) = _$SearchTextItemDtoCopyWithImpl<$Res, SearchTextItemDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int textsId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    @JsonKey(fromJson: _intFromJson) int foldersId,
    String textContent,
    String? createdAt,
    String foldersName,
    String dayOfWeek,
  });
}

/// @nodoc
class _$SearchTextItemDtoCopyWithImpl<$Res, $Val extends SearchTextItemDto>
    implements $SearchTextItemDtoCopyWith<$Res> {
  _$SearchTextItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchTextItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? textsId = null,
    Object? usersId = null,
    Object? foldersId = null,
    Object? textContent = null,
    Object? createdAt = freezed,
    Object? foldersName = null,
    Object? dayOfWeek = null,
  }) {
    return _then(
      _value.copyWith(
            textsId: null == textsId
                ? _value.textsId
                : textsId // ignore: cast_nullable_to_non_nullable
                      as int,
            usersId: null == usersId
                ? _value.usersId
                : usersId // ignore: cast_nullable_to_non_nullable
                      as int,
            foldersId: null == foldersId
                ? _value.foldersId
                : foldersId // ignore: cast_nullable_to_non_nullable
                      as int,
            textContent: null == textContent
                ? _value.textContent
                : textContent // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            foldersName: null == foldersName
                ? _value.foldersName
                : foldersName // ignore: cast_nullable_to_non_nullable
                      as String,
            dayOfWeek: null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchTextItemDtoImplCopyWith<$Res>
    implements $SearchTextItemDtoCopyWith<$Res> {
  factory _$$SearchTextItemDtoImplCopyWith(
    _$SearchTextItemDtoImpl value,
    $Res Function(_$SearchTextItemDtoImpl) then,
  ) = __$$SearchTextItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int textsId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    @JsonKey(fromJson: _intFromJson) int foldersId,
    String textContent,
    String? createdAt,
    String foldersName,
    String dayOfWeek,
  });
}

/// @nodoc
class __$$SearchTextItemDtoImplCopyWithImpl<$Res>
    extends _$SearchTextItemDtoCopyWithImpl<$Res, _$SearchTextItemDtoImpl>
    implements _$$SearchTextItemDtoImplCopyWith<$Res> {
  __$$SearchTextItemDtoImplCopyWithImpl(
    _$SearchTextItemDtoImpl _value,
    $Res Function(_$SearchTextItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchTextItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? textsId = null,
    Object? usersId = null,
    Object? foldersId = null,
    Object? textContent = null,
    Object? createdAt = freezed,
    Object? foldersName = null,
    Object? dayOfWeek = null,
  }) {
    return _then(
      _$SearchTextItemDtoImpl(
        textsId: null == textsId
            ? _value.textsId
            : textsId // ignore: cast_nullable_to_non_nullable
                  as int,
        usersId: null == usersId
            ? _value.usersId
            : usersId // ignore: cast_nullable_to_non_nullable
                  as int,
        foldersId: null == foldersId
            ? _value.foldersId
            : foldersId // ignore: cast_nullable_to_non_nullable
                  as int,
        textContent: null == textContent
            ? _value.textContent
            : textContent // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        foldersName: null == foldersName
            ? _value.foldersName
            : foldersName // ignore: cast_nullable_to_non_nullable
                  as String,
        dayOfWeek: null == dayOfWeek
            ? _value.dayOfWeek
            : dayOfWeek // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchTextItemDtoImpl implements _SearchTextItemDto {
  const _$SearchTextItemDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.textsId = 0,
    @JsonKey(fromJson: _intFromJson) this.usersId = 0,
    @JsonKey(fromJson: _intFromJson) this.foldersId = 0,
    this.textContent = '',
    this.createdAt,
    this.foldersName = '',
    this.dayOfWeek = '',
  });

  factory _$SearchTextItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchTextItemDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int textsId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int usersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int foldersId;
  @override
  @JsonKey()
  final String textContent;
  @override
  final String? createdAt;
  @override
  @JsonKey()
  final String foldersName;
  @override
  @JsonKey()
  final String dayOfWeek;

  @override
  String toString() {
    return 'SearchTextItemDto(textsId: $textsId, usersId: $usersId, foldersId: $foldersId, textContent: $textContent, createdAt: $createdAt, foldersName: $foldersName, dayOfWeek: $dayOfWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchTextItemDtoImpl &&
            (identical(other.textsId, textsId) || other.textsId == textsId) &&
            (identical(other.usersId, usersId) || other.usersId == usersId) &&
            (identical(other.foldersId, foldersId) ||
                other.foldersId == foldersId) &&
            (identical(other.textContent, textContent) ||
                other.textContent == textContent) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.foldersName, foldersName) ||
                other.foldersName == foldersName) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    textsId,
    usersId,
    foldersId,
    textContent,
    createdAt,
    foldersName,
    dayOfWeek,
  );

  /// Create a copy of SearchTextItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchTextItemDtoImplCopyWith<_$SearchTextItemDtoImpl> get copyWith =>
      __$$SearchTextItemDtoImplCopyWithImpl<_$SearchTextItemDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchTextItemDtoImplToJson(this);
  }
}

abstract class _SearchTextItemDto implements SearchTextItemDto {
  const factory _SearchTextItemDto({
    @JsonKey(fromJson: _intFromJson) final int textsId,
    @JsonKey(fromJson: _intFromJson) final int usersId,
    @JsonKey(fromJson: _intFromJson) final int foldersId,
    final String textContent,
    final String? createdAt,
    final String foldersName,
    final String dayOfWeek,
  }) = _$SearchTextItemDtoImpl;

  factory _SearchTextItemDto.fromJson(Map<String, dynamic> json) =
      _$SearchTextItemDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get textsId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get usersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get foldersId;
  @override
  String get textContent;
  @override
  String? get createdAt;
  @override
  String get foldersName;
  @override
  String get dayOfWeek;

  /// Create a copy of SearchTextItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchTextItemDtoImplCopyWith<_$SearchTextItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchFileItemDto _$SearchFileItemDtoFromJson(Map<String, dynamic> json) {
  return _SearchFileItemDto.fromJson(json);
}

/// @nodoc
mixin _$SearchFileItemDto {
  @JsonKey(fromJson: _intFromJson)
  int get attachmentsId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get usersId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get foldersId => throw _privateConstructorUsedError;
  String get attachmentsType => throw _privateConstructorUsedError;
  String get objectKey => throw _privateConstructorUsedError;
  String get presignedUrl => throw _privateConstructorUsedError;
  String get attachmentsExtension => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _doubleFromJson)
  double get attachmentsSize => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String get foldersName => throw _privateConstructorUsedError;
  String get dayOfWeek => throw _privateConstructorUsedError;

  /// Serializes this SearchFileItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchFileItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchFileItemDtoCopyWith<SearchFileItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchFileItemDtoCopyWith<$Res> {
  factory $SearchFileItemDtoCopyWith(
    SearchFileItemDto value,
    $Res Function(SearchFileItemDto) then,
  ) = _$SearchFileItemDtoCopyWithImpl<$Res, SearchFileItemDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int attachmentsId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    @JsonKey(fromJson: _intFromJson) int foldersId,
    String attachmentsType,
    String objectKey,
    String presignedUrl,
    String attachmentsExtension,
    @JsonKey(fromJson: _doubleFromJson) double attachmentsSize,
    String fileName,
    String? createdAt,
    String foldersName,
    String dayOfWeek,
  });
}

/// @nodoc
class _$SearchFileItemDtoCopyWithImpl<$Res, $Val extends SearchFileItemDto>
    implements $SearchFileItemDtoCopyWith<$Res> {
  _$SearchFileItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchFileItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachmentsId = null,
    Object? usersId = null,
    Object? foldersId = null,
    Object? attachmentsType = null,
    Object? objectKey = null,
    Object? presignedUrl = null,
    Object? attachmentsExtension = null,
    Object? attachmentsSize = null,
    Object? fileName = null,
    Object? createdAt = freezed,
    Object? foldersName = null,
    Object? dayOfWeek = null,
  }) {
    return _then(
      _value.copyWith(
            attachmentsId: null == attachmentsId
                ? _value.attachmentsId
                : attachmentsId // ignore: cast_nullable_to_non_nullable
                      as int,
            usersId: null == usersId
                ? _value.usersId
                : usersId // ignore: cast_nullable_to_non_nullable
                      as int,
            foldersId: null == foldersId
                ? _value.foldersId
                : foldersId // ignore: cast_nullable_to_non_nullable
                      as int,
            attachmentsType: null == attachmentsType
                ? _value.attachmentsType
                : attachmentsType // ignore: cast_nullable_to_non_nullable
                      as String,
            objectKey: null == objectKey
                ? _value.objectKey
                : objectKey // ignore: cast_nullable_to_non_nullable
                      as String,
            presignedUrl: null == presignedUrl
                ? _value.presignedUrl
                : presignedUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            attachmentsExtension: null == attachmentsExtension
                ? _value.attachmentsExtension
                : attachmentsExtension // ignore: cast_nullable_to_non_nullable
                      as String,
            attachmentsSize: null == attachmentsSize
                ? _value.attachmentsSize
                : attachmentsSize // ignore: cast_nullable_to_non_nullable
                      as double,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            foldersName: null == foldersName
                ? _value.foldersName
                : foldersName // ignore: cast_nullable_to_non_nullable
                      as String,
            dayOfWeek: null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchFileItemDtoImplCopyWith<$Res>
    implements $SearchFileItemDtoCopyWith<$Res> {
  factory _$$SearchFileItemDtoImplCopyWith(
    _$SearchFileItemDtoImpl value,
    $Res Function(_$SearchFileItemDtoImpl) then,
  ) = __$$SearchFileItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int attachmentsId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    @JsonKey(fromJson: _intFromJson) int foldersId,
    String attachmentsType,
    String objectKey,
    String presignedUrl,
    String attachmentsExtension,
    @JsonKey(fromJson: _doubleFromJson) double attachmentsSize,
    String fileName,
    String? createdAt,
    String foldersName,
    String dayOfWeek,
  });
}

/// @nodoc
class __$$SearchFileItemDtoImplCopyWithImpl<$Res>
    extends _$SearchFileItemDtoCopyWithImpl<$Res, _$SearchFileItemDtoImpl>
    implements _$$SearchFileItemDtoImplCopyWith<$Res> {
  __$$SearchFileItemDtoImplCopyWithImpl(
    _$SearchFileItemDtoImpl _value,
    $Res Function(_$SearchFileItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchFileItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachmentsId = null,
    Object? usersId = null,
    Object? foldersId = null,
    Object? attachmentsType = null,
    Object? objectKey = null,
    Object? presignedUrl = null,
    Object? attachmentsExtension = null,
    Object? attachmentsSize = null,
    Object? fileName = null,
    Object? createdAt = freezed,
    Object? foldersName = null,
    Object? dayOfWeek = null,
  }) {
    return _then(
      _$SearchFileItemDtoImpl(
        attachmentsId: null == attachmentsId
            ? _value.attachmentsId
            : attachmentsId // ignore: cast_nullable_to_non_nullable
                  as int,
        usersId: null == usersId
            ? _value.usersId
            : usersId // ignore: cast_nullable_to_non_nullable
                  as int,
        foldersId: null == foldersId
            ? _value.foldersId
            : foldersId // ignore: cast_nullable_to_non_nullable
                  as int,
        attachmentsType: null == attachmentsType
            ? _value.attachmentsType
            : attachmentsType // ignore: cast_nullable_to_non_nullable
                  as String,
        objectKey: null == objectKey
            ? _value.objectKey
            : objectKey // ignore: cast_nullable_to_non_nullable
                  as String,
        presignedUrl: null == presignedUrl
            ? _value.presignedUrl
            : presignedUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        attachmentsExtension: null == attachmentsExtension
            ? _value.attachmentsExtension
            : attachmentsExtension // ignore: cast_nullable_to_non_nullable
                  as String,
        attachmentsSize: null == attachmentsSize
            ? _value.attachmentsSize
            : attachmentsSize // ignore: cast_nullable_to_non_nullable
                  as double,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        foldersName: null == foldersName
            ? _value.foldersName
            : foldersName // ignore: cast_nullable_to_non_nullable
                  as String,
        dayOfWeek: null == dayOfWeek
            ? _value.dayOfWeek
            : dayOfWeek // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchFileItemDtoImpl implements _SearchFileItemDto {
  const _$SearchFileItemDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.attachmentsId = 0,
    @JsonKey(fromJson: _intFromJson) this.usersId = 0,
    @JsonKey(fromJson: _intFromJson) this.foldersId = 0,
    this.attachmentsType = '',
    this.objectKey = '',
    this.presignedUrl = '',
    this.attachmentsExtension = '',
    @JsonKey(fromJson: _doubleFromJson) this.attachmentsSize = 0.0,
    this.fileName = '',
    this.createdAt,
    this.foldersName = '',
    this.dayOfWeek = '',
  });

  factory _$SearchFileItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchFileItemDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int attachmentsId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int usersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int foldersId;
  @override
  @JsonKey()
  final String attachmentsType;
  @override
  @JsonKey()
  final String objectKey;
  @override
  @JsonKey()
  final String presignedUrl;
  @override
  @JsonKey()
  final String attachmentsExtension;
  @override
  @JsonKey(fromJson: _doubleFromJson)
  final double attachmentsSize;
  @override
  @JsonKey()
  final String fileName;
  @override
  final String? createdAt;
  @override
  @JsonKey()
  final String foldersName;
  @override
  @JsonKey()
  final String dayOfWeek;

  @override
  String toString() {
    return 'SearchFileItemDto(attachmentsId: $attachmentsId, usersId: $usersId, foldersId: $foldersId, attachmentsType: $attachmentsType, objectKey: $objectKey, presignedUrl: $presignedUrl, attachmentsExtension: $attachmentsExtension, attachmentsSize: $attachmentsSize, fileName: $fileName, createdAt: $createdAt, foldersName: $foldersName, dayOfWeek: $dayOfWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchFileItemDtoImpl &&
            (identical(other.attachmentsId, attachmentsId) ||
                other.attachmentsId == attachmentsId) &&
            (identical(other.usersId, usersId) || other.usersId == usersId) &&
            (identical(other.foldersId, foldersId) ||
                other.foldersId == foldersId) &&
            (identical(other.attachmentsType, attachmentsType) ||
                other.attachmentsType == attachmentsType) &&
            (identical(other.objectKey, objectKey) ||
                other.objectKey == objectKey) &&
            (identical(other.presignedUrl, presignedUrl) ||
                other.presignedUrl == presignedUrl) &&
            (identical(other.attachmentsExtension, attachmentsExtension) ||
                other.attachmentsExtension == attachmentsExtension) &&
            (identical(other.attachmentsSize, attachmentsSize) ||
                other.attachmentsSize == attachmentsSize) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.foldersName, foldersName) ||
                other.foldersName == foldersName) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    attachmentsId,
    usersId,
    foldersId,
    attachmentsType,
    objectKey,
    presignedUrl,
    attachmentsExtension,
    attachmentsSize,
    fileName,
    createdAt,
    foldersName,
    dayOfWeek,
  );

  /// Create a copy of SearchFileItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchFileItemDtoImplCopyWith<_$SearchFileItemDtoImpl> get copyWith =>
      __$$SearchFileItemDtoImplCopyWithImpl<_$SearchFileItemDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchFileItemDtoImplToJson(this);
  }
}

abstract class _SearchFileItemDto implements SearchFileItemDto {
  const factory _SearchFileItemDto({
    @JsonKey(fromJson: _intFromJson) final int attachmentsId,
    @JsonKey(fromJson: _intFromJson) final int usersId,
    @JsonKey(fromJson: _intFromJson) final int foldersId,
    final String attachmentsType,
    final String objectKey,
    final String presignedUrl,
    final String attachmentsExtension,
    @JsonKey(fromJson: _doubleFromJson) final double attachmentsSize,
    final String fileName,
    final String? createdAt,
    final String foldersName,
    final String dayOfWeek,
  }) = _$SearchFileItemDtoImpl;

  factory _SearchFileItemDto.fromJson(Map<String, dynamic> json) =
      _$SearchFileItemDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get attachmentsId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get usersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get foldersId;
  @override
  String get attachmentsType;
  @override
  String get objectKey;
  @override
  String get presignedUrl;
  @override
  String get attachmentsExtension;
  @override
  @JsonKey(fromJson: _doubleFromJson)
  double get attachmentsSize;
  @override
  String get fileName;
  @override
  String? get createdAt;
  @override
  String get foldersName;
  @override
  String get dayOfWeek;

  /// Create a copy of SearchFileItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchFileItemDtoImplCopyWith<_$SearchFileItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
