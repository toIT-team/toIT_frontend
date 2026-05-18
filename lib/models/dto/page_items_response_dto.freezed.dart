// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_items_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PageItemsResponseDto _$PageItemsResponseDtoFromJson(Map<String, dynamic> json) {
  return _PageItemsResponseDto.fromJson(json);
}

/// @nodoc
mixin _$PageItemsResponseDto {
  @JsonKey(fromJson: _intFromJson)
  int get usersId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get foldersId => throw _privateConstructorUsedError;
  List<LinkDto> get links => throw _privateConstructorUsedError;
  List<TextDto> get texts => throw _privateConstructorUsedError;
  List<AttachmentFileDto> get files => throw _privateConstructorUsedError;
  List<AttachmentImageDto> get images => throw _privateConstructorUsedError;

  /// Serializes this PageItemsResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PageItemsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageItemsResponseDtoCopyWith<PageItemsResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageItemsResponseDtoCopyWith<$Res> {
  factory $PageItemsResponseDtoCopyWith(
    PageItemsResponseDto value,
    $Res Function(PageItemsResponseDto) then,
  ) = _$PageItemsResponseDtoCopyWithImpl<$Res, PageItemsResponseDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int usersId,
    @JsonKey(fromJson: _intFromJson) int foldersId,
    List<LinkDto> links,
    List<TextDto> texts,
    List<AttachmentFileDto> files,
    List<AttachmentImageDto> images,
  });
}

/// @nodoc
class _$PageItemsResponseDtoCopyWithImpl<
  $Res,
  $Val extends PageItemsResponseDto
>
    implements $PageItemsResponseDtoCopyWith<$Res> {
  _$PageItemsResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageItemsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usersId = null,
    Object? foldersId = null,
    Object? links = null,
    Object? texts = null,
    Object? files = null,
    Object? images = null,
  }) {
    return _then(
      _value.copyWith(
            usersId: null == usersId
                ? _value.usersId
                : usersId // ignore: cast_nullable_to_non_nullable
                      as int,
            foldersId: null == foldersId
                ? _value.foldersId
                : foldersId // ignore: cast_nullable_to_non_nullable
                      as int,
            links: null == links
                ? _value.links
                : links // ignore: cast_nullable_to_non_nullable
                      as List<LinkDto>,
            texts: null == texts
                ? _value.texts
                : texts // ignore: cast_nullable_to_non_nullable
                      as List<TextDto>,
            files: null == files
                ? _value.files
                : files // ignore: cast_nullable_to_non_nullable
                      as List<AttachmentFileDto>,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<AttachmentImageDto>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PageItemsResponseDtoImplCopyWith<$Res>
    implements $PageItemsResponseDtoCopyWith<$Res> {
  factory _$$PageItemsResponseDtoImplCopyWith(
    _$PageItemsResponseDtoImpl value,
    $Res Function(_$PageItemsResponseDtoImpl) then,
  ) = __$$PageItemsResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int usersId,
    @JsonKey(fromJson: _intFromJson) int foldersId,
    List<LinkDto> links,
    List<TextDto> texts,
    List<AttachmentFileDto> files,
    List<AttachmentImageDto> images,
  });
}

/// @nodoc
class __$$PageItemsResponseDtoImplCopyWithImpl<$Res>
    extends _$PageItemsResponseDtoCopyWithImpl<$Res, _$PageItemsResponseDtoImpl>
    implements _$$PageItemsResponseDtoImplCopyWith<$Res> {
  __$$PageItemsResponseDtoImplCopyWithImpl(
    _$PageItemsResponseDtoImpl _value,
    $Res Function(_$PageItemsResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PageItemsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usersId = null,
    Object? foldersId = null,
    Object? links = null,
    Object? texts = null,
    Object? files = null,
    Object? images = null,
  }) {
    return _then(
      _$PageItemsResponseDtoImpl(
        usersId: null == usersId
            ? _value.usersId
            : usersId // ignore: cast_nullable_to_non_nullable
                  as int,
        foldersId: null == foldersId
            ? _value.foldersId
            : foldersId // ignore: cast_nullable_to_non_nullable
                  as int,
        links: null == links
            ? _value._links
            : links // ignore: cast_nullable_to_non_nullable
                  as List<LinkDto>,
        texts: null == texts
            ? _value._texts
            : texts // ignore: cast_nullable_to_non_nullable
                  as List<TextDto>,
        files: null == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<AttachmentFileDto>,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<AttachmentImageDto>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PageItemsResponseDtoImpl implements _PageItemsResponseDto {
  const _$PageItemsResponseDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.usersId = 0,
    @JsonKey(fromJson: _intFromJson) this.foldersId = 0,
    final List<LinkDto> links = const [],
    final List<TextDto> texts = const [],
    final List<AttachmentFileDto> files = const [],
    final List<AttachmentImageDto> images = const [],
  }) : _links = links,
       _texts = texts,
       _files = files,
       _images = images;

  factory _$PageItemsResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PageItemsResponseDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int usersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int foldersId;
  final List<LinkDto> _links;
  @override
  @JsonKey()
  List<LinkDto> get links {
    if (_links is EqualUnmodifiableListView) return _links;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_links);
  }

  final List<TextDto> _texts;
  @override
  @JsonKey()
  List<TextDto> get texts {
    if (_texts is EqualUnmodifiableListView) return _texts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_texts);
  }

  final List<AttachmentFileDto> _files;
  @override
  @JsonKey()
  List<AttachmentFileDto> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  final List<AttachmentImageDto> _images;
  @override
  @JsonKey()
  List<AttachmentImageDto> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  String toString() {
    return 'PageItemsResponseDto(usersId: $usersId, foldersId: $foldersId, links: $links, texts: $texts, files: $files, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageItemsResponseDtoImpl &&
            (identical(other.usersId, usersId) || other.usersId == usersId) &&
            (identical(other.foldersId, foldersId) ||
                other.foldersId == foldersId) &&
            const DeepCollectionEquality().equals(other._links, _links) &&
            const DeepCollectionEquality().equals(other._texts, _texts) &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    usersId,
    foldersId,
    const DeepCollectionEquality().hash(_links),
    const DeepCollectionEquality().hash(_texts),
    const DeepCollectionEquality().hash(_files),
    const DeepCollectionEquality().hash(_images),
  );

  /// Create a copy of PageItemsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageItemsResponseDtoImplCopyWith<_$PageItemsResponseDtoImpl>
  get copyWith =>
      __$$PageItemsResponseDtoImplCopyWithImpl<_$PageItemsResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PageItemsResponseDtoImplToJson(this);
  }
}

abstract class _PageItemsResponseDto implements PageItemsResponseDto {
  const factory _PageItemsResponseDto({
    @JsonKey(fromJson: _intFromJson) final int usersId,
    @JsonKey(fromJson: _intFromJson) final int foldersId,
    final List<LinkDto> links,
    final List<TextDto> texts,
    final List<AttachmentFileDto> files,
    final List<AttachmentImageDto> images,
  }) = _$PageItemsResponseDtoImpl;

  factory _PageItemsResponseDto.fromJson(Map<String, dynamic> json) =
      _$PageItemsResponseDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get usersId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get foldersId;
  @override
  List<LinkDto> get links;
  @override
  List<TextDto> get texts;
  @override
  List<AttachmentFileDto> get files;
  @override
  List<AttachmentImageDto> get images;

  /// Create a copy of PageItemsResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageItemsResponseDtoImplCopyWith<_$PageItemsResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TextDto _$TextDtoFromJson(Map<String, dynamic> json) {
  return _TextDto.fromJson(json);
}

/// @nodoc
mixin _$TextDto {
  @JsonKey(fromJson: _intFromJson)
  int get textsId => throw _privateConstructorUsedError;
  String get textContent => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TextDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TextDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TextDtoCopyWith<TextDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TextDtoCopyWith<$Res> {
  factory $TextDtoCopyWith(TextDto value, $Res Function(TextDto) then) =
      _$TextDtoCopyWithImpl<$Res, TextDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int textsId,
    String textContent,
    String? createdAt,
  });
}

/// @nodoc
class _$TextDtoCopyWithImpl<$Res, $Val extends TextDto>
    implements $TextDtoCopyWith<$Res> {
  _$TextDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TextDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? textsId = null,
    Object? textContent = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            textsId: null == textsId
                ? _value.textsId
                : textsId // ignore: cast_nullable_to_non_nullable
                      as int,
            textContent: null == textContent
                ? _value.textContent
                : textContent // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TextDtoImplCopyWith<$Res> implements $TextDtoCopyWith<$Res> {
  factory _$$TextDtoImplCopyWith(
    _$TextDtoImpl value,
    $Res Function(_$TextDtoImpl) then,
  ) = __$$TextDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int textsId,
    String textContent,
    String? createdAt,
  });
}

/// @nodoc
class __$$TextDtoImplCopyWithImpl<$Res>
    extends _$TextDtoCopyWithImpl<$Res, _$TextDtoImpl>
    implements _$$TextDtoImplCopyWith<$Res> {
  __$$TextDtoImplCopyWithImpl(
    _$TextDtoImpl _value,
    $Res Function(_$TextDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TextDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? textsId = null,
    Object? textContent = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TextDtoImpl(
        textsId: null == textsId
            ? _value.textsId
            : textsId // ignore: cast_nullable_to_non_nullable
                  as int,
        textContent: null == textContent
            ? _value.textContent
            : textContent // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TextDtoImpl implements _TextDto {
  const _$TextDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.textsId = 0,
    this.textContent = '',
    this.createdAt,
  });

  factory _$TextDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TextDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int textsId;
  @override
  @JsonKey()
  final String textContent;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'TextDto(textsId: $textsId, textContent: $textContent, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextDtoImpl &&
            (identical(other.textsId, textsId) || other.textsId == textsId) &&
            (identical(other.textContent, textContent) ||
                other.textContent == textContent) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, textsId, textContent, createdAt);

  /// Create a copy of TextDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextDtoImplCopyWith<_$TextDtoImpl> get copyWith =>
      __$$TextDtoImplCopyWithImpl<_$TextDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TextDtoImplToJson(this);
  }
}

abstract class _TextDto implements TextDto {
  const factory _TextDto({
    @JsonKey(fromJson: _intFromJson) final int textsId,
    final String textContent,
    final String? createdAt,
  }) = _$TextDtoImpl;

  factory _TextDto.fromJson(Map<String, dynamic> json) = _$TextDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get textsId;
  @override
  String get textContent;
  @override
  String? get createdAt;

  /// Create a copy of TextDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TextDtoImplCopyWith<_$TextDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LinkDto _$LinkDtoFromJson(Map<String, dynamic> json) {
  return _LinkDto.fromJson(json);
}

/// @nodoc
mixin _$LinkDto {
  @JsonKey(fromJson: _intFromJson)
  int get linksId => throw _privateConstructorUsedError;
  String get linksName => throw _privateConstructorUsedError;
  String get linksUrl => throw _privateConstructorUsedError;
  String get linksThumbnail => throw _privateConstructorUsedError;
  String get textContent => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LinkDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LinkDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LinkDtoCopyWith<LinkDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LinkDtoCopyWith<$Res> {
  factory $LinkDtoCopyWith(LinkDto value, $Res Function(LinkDto) then) =
      _$LinkDtoCopyWithImpl<$Res, LinkDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int linksId,
    String linksName,
    String linksUrl,
    String linksThumbnail,
    String textContent,
    String? createdAt,
  });
}

/// @nodoc
class _$LinkDtoCopyWithImpl<$Res, $Val extends LinkDto>
    implements $LinkDtoCopyWith<$Res> {
  _$LinkDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LinkDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linksId = null,
    Object? linksName = null,
    Object? linksUrl = null,
    Object? linksThumbnail = null,
    Object? textContent = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            linksId: null == linksId
                ? _value.linksId
                : linksId // ignore: cast_nullable_to_non_nullable
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LinkDtoImplCopyWith<$Res> implements $LinkDtoCopyWith<$Res> {
  factory _$$LinkDtoImplCopyWith(
    _$LinkDtoImpl value,
    $Res Function(_$LinkDtoImpl) then,
  ) = __$$LinkDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int linksId,
    String linksName,
    String linksUrl,
    String linksThumbnail,
    String textContent,
    String? createdAt,
  });
}

/// @nodoc
class __$$LinkDtoImplCopyWithImpl<$Res>
    extends _$LinkDtoCopyWithImpl<$Res, _$LinkDtoImpl>
    implements _$$LinkDtoImplCopyWith<$Res> {
  __$$LinkDtoImplCopyWithImpl(
    _$LinkDtoImpl _value,
    $Res Function(_$LinkDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LinkDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linksId = null,
    Object? linksName = null,
    Object? linksUrl = null,
    Object? linksThumbnail = null,
    Object? textContent = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$LinkDtoImpl(
        linksId: null == linksId
            ? _value.linksId
            : linksId // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LinkDtoImpl implements _LinkDto {
  const _$LinkDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.linksId = 0,
    this.linksName = '',
    this.linksUrl = '',
    this.linksThumbnail = '',
    this.textContent = '',
    this.createdAt,
  });

  factory _$LinkDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LinkDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int linksId;
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
  String toString() {
    return 'LinkDto(linksId: $linksId, linksName: $linksName, linksUrl: $linksUrl, linksThumbnail: $linksThumbnail, textContent: $textContent, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LinkDtoImpl &&
            (identical(other.linksId, linksId) || other.linksId == linksId) &&
            (identical(other.linksName, linksName) ||
                other.linksName == linksName) &&
            (identical(other.linksUrl, linksUrl) ||
                other.linksUrl == linksUrl) &&
            (identical(other.linksThumbnail, linksThumbnail) ||
                other.linksThumbnail == linksThumbnail) &&
            (identical(other.textContent, textContent) ||
                other.textContent == textContent) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    linksId,
    linksName,
    linksUrl,
    linksThumbnail,
    textContent,
    createdAt,
  );

  /// Create a copy of LinkDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LinkDtoImplCopyWith<_$LinkDtoImpl> get copyWith =>
      __$$LinkDtoImplCopyWithImpl<_$LinkDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LinkDtoImplToJson(this);
  }
}

abstract class _LinkDto implements LinkDto {
  const factory _LinkDto({
    @JsonKey(fromJson: _intFromJson) final int linksId,
    final String linksName,
    final String linksUrl,
    final String linksThumbnail,
    final String textContent,
    final String? createdAt,
  }) = _$LinkDtoImpl;

  factory _LinkDto.fromJson(Map<String, dynamic> json) = _$LinkDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get linksId;
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

  /// Create a copy of LinkDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LinkDtoImplCopyWith<_$LinkDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AttachmentFileDto _$AttachmentFileDtoFromJson(Map<String, dynamic> json) {
  return _AttachmentFileDto.fromJson(json);
}

/// @nodoc
mixin _$AttachmentFileDto {
  @JsonKey(fromJson: _intFromJson)
  int get attachmentsId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get usersId => throw _privateConstructorUsedError;
  String get attachmentsType => throw _privateConstructorUsedError;
  String get textContent => throw _privateConstructorUsedError;
  String get objectKey => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readPresignedUrlKey)
  String get presignedUrl => throw _privateConstructorUsedError;
  String get attachmentsExtension => throw _privateConstructorUsedError;
  double get attachmentsSize => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AttachmentFileDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttachmentFileDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttachmentFileDtoCopyWith<AttachmentFileDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttachmentFileDtoCopyWith<$Res> {
  factory $AttachmentFileDtoCopyWith(
    AttachmentFileDto value,
    $Res Function(AttachmentFileDto) then,
  ) = _$AttachmentFileDtoCopyWithImpl<$Res, AttachmentFileDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int attachmentsId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    String attachmentsType,
    String textContent,
    String objectKey,
    @JsonKey(readValue: _readPresignedUrlKey) String presignedUrl,
    String attachmentsExtension,
    double attachmentsSize,
    String fileName,
    String? createdAt,
  });
}

/// @nodoc
class _$AttachmentFileDtoCopyWithImpl<$Res, $Val extends AttachmentFileDto>
    implements $AttachmentFileDtoCopyWith<$Res> {
  _$AttachmentFileDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttachmentFileDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachmentsId = null,
    Object? usersId = null,
    Object? attachmentsType = null,
    Object? textContent = null,
    Object? objectKey = null,
    Object? presignedUrl = null,
    Object? attachmentsExtension = null,
    Object? attachmentsSize = null,
    Object? fileName = null,
    Object? createdAt = freezed,
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
            attachmentsType: null == attachmentsType
                ? _value.attachmentsType
                : attachmentsType // ignore: cast_nullable_to_non_nullable
                      as String,
            textContent: null == textContent
                ? _value.textContent
                : textContent // ignore: cast_nullable_to_non_nullable
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttachmentFileDtoImplCopyWith<$Res>
    implements $AttachmentFileDtoCopyWith<$Res> {
  factory _$$AttachmentFileDtoImplCopyWith(
    _$AttachmentFileDtoImpl value,
    $Res Function(_$AttachmentFileDtoImpl) then,
  ) = __$$AttachmentFileDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int attachmentsId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    String attachmentsType,
    String textContent,
    String objectKey,
    @JsonKey(readValue: _readPresignedUrlKey) String presignedUrl,
    String attachmentsExtension,
    double attachmentsSize,
    String fileName,
    String? createdAt,
  });
}

/// @nodoc
class __$$AttachmentFileDtoImplCopyWithImpl<$Res>
    extends _$AttachmentFileDtoCopyWithImpl<$Res, _$AttachmentFileDtoImpl>
    implements _$$AttachmentFileDtoImplCopyWith<$Res> {
  __$$AttachmentFileDtoImplCopyWithImpl(
    _$AttachmentFileDtoImpl _value,
    $Res Function(_$AttachmentFileDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttachmentFileDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachmentsId = null,
    Object? usersId = null,
    Object? attachmentsType = null,
    Object? textContent = null,
    Object? objectKey = null,
    Object? presignedUrl = null,
    Object? attachmentsExtension = null,
    Object? attachmentsSize = null,
    Object? fileName = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AttachmentFileDtoImpl(
        attachmentsId: null == attachmentsId
            ? _value.attachmentsId
            : attachmentsId // ignore: cast_nullable_to_non_nullable
                  as int,
        usersId: null == usersId
            ? _value.usersId
            : usersId // ignore: cast_nullable_to_non_nullable
                  as int,
        attachmentsType: null == attachmentsType
            ? _value.attachmentsType
            : attachmentsType // ignore: cast_nullable_to_non_nullable
                  as String,
        textContent: null == textContent
            ? _value.textContent
            : textContent // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttachmentFileDtoImpl implements _AttachmentFileDto {
  const _$AttachmentFileDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.attachmentsId = 0,
    @JsonKey(fromJson: _intFromJson) this.usersId = 0,
    this.attachmentsType = '',
    this.textContent = '',
    this.objectKey = '',
    @JsonKey(readValue: _readPresignedUrlKey) this.presignedUrl = '',
    this.attachmentsExtension = '',
    this.attachmentsSize = 0.0,
    this.fileName = '',
    this.createdAt,
  });

  factory _$AttachmentFileDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttachmentFileDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int attachmentsId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int usersId;
  @override
  @JsonKey()
  final String attachmentsType;
  @override
  @JsonKey()
  final String textContent;
  @override
  @JsonKey()
  final String objectKey;
  @override
  @JsonKey(readValue: _readPresignedUrlKey)
  final String presignedUrl;
  @override
  @JsonKey()
  final String attachmentsExtension;
  @override
  @JsonKey()
  final double attachmentsSize;
  @override
  @JsonKey()
  final String fileName;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'AttachmentFileDto(attachmentsId: $attachmentsId, usersId: $usersId, attachmentsType: $attachmentsType, textContent: $textContent, objectKey: $objectKey, presignedUrl: $presignedUrl, attachmentsExtension: $attachmentsExtension, attachmentsSize: $attachmentsSize, fileName: $fileName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttachmentFileDtoImpl &&
            (identical(other.attachmentsId, attachmentsId) ||
                other.attachmentsId == attachmentsId) &&
            (identical(other.usersId, usersId) || other.usersId == usersId) &&
            (identical(other.attachmentsType, attachmentsType) ||
                other.attachmentsType == attachmentsType) &&
            (identical(other.textContent, textContent) ||
                other.textContent == textContent) &&
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
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    attachmentsId,
    usersId,
    attachmentsType,
    textContent,
    objectKey,
    presignedUrl,
    attachmentsExtension,
    attachmentsSize,
    fileName,
    createdAt,
  );

  /// Create a copy of AttachmentFileDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttachmentFileDtoImplCopyWith<_$AttachmentFileDtoImpl> get copyWith =>
      __$$AttachmentFileDtoImplCopyWithImpl<_$AttachmentFileDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttachmentFileDtoImplToJson(this);
  }
}

abstract class _AttachmentFileDto implements AttachmentFileDto {
  const factory _AttachmentFileDto({
    @JsonKey(fromJson: _intFromJson) final int attachmentsId,
    @JsonKey(fromJson: _intFromJson) final int usersId,
    final String attachmentsType,
    final String textContent,
    final String objectKey,
    @JsonKey(readValue: _readPresignedUrlKey) final String presignedUrl,
    final String attachmentsExtension,
    final double attachmentsSize,
    final String fileName,
    final String? createdAt,
  }) = _$AttachmentFileDtoImpl;

  factory _AttachmentFileDto.fromJson(Map<String, dynamic> json) =
      _$AttachmentFileDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get attachmentsId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get usersId;
  @override
  String get attachmentsType;
  @override
  String get textContent;
  @override
  String get objectKey;
  @override
  @JsonKey(readValue: _readPresignedUrlKey)
  String get presignedUrl;
  @override
  String get attachmentsExtension;
  @override
  double get attachmentsSize;
  @override
  String get fileName;
  @override
  String? get createdAt;

  /// Create a copy of AttachmentFileDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttachmentFileDtoImplCopyWith<_$AttachmentFileDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AttachmentImageDto _$AttachmentImageDtoFromJson(Map<String, dynamic> json) {
  return _AttachmentImageDto.fromJson(json);
}

/// @nodoc
mixin _$AttachmentImageDto {
  @JsonKey(fromJson: _intFromJson)
  int get attachmentsId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get usersId => throw _privateConstructorUsedError;
  String get attachmentsType => throw _privateConstructorUsedError;
  String get textContent => throw _privateConstructorUsedError;
  String get objectKey => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readPresignedUrlKey)
  String get presignedUrl => throw _privateConstructorUsedError;
  String get attachmentsExtension => throw _privateConstructorUsedError;
  double get attachmentsSize => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  int get imagesWidth => throw _privateConstructorUsedError;
  int get imagesHeight => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AttachmentImageDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttachmentImageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttachmentImageDtoCopyWith<AttachmentImageDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttachmentImageDtoCopyWith<$Res> {
  factory $AttachmentImageDtoCopyWith(
    AttachmentImageDto value,
    $Res Function(AttachmentImageDto) then,
  ) = _$AttachmentImageDtoCopyWithImpl<$Res, AttachmentImageDto>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int attachmentsId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    String attachmentsType,
    String textContent,
    String objectKey,
    @JsonKey(readValue: _readPresignedUrlKey) String presignedUrl,
    String attachmentsExtension,
    double attachmentsSize,
    String fileName,
    int imagesWidth,
    int imagesHeight,
    String? createdAt,
  });
}

/// @nodoc
class _$AttachmentImageDtoCopyWithImpl<$Res, $Val extends AttachmentImageDto>
    implements $AttachmentImageDtoCopyWith<$Res> {
  _$AttachmentImageDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttachmentImageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachmentsId = null,
    Object? usersId = null,
    Object? attachmentsType = null,
    Object? textContent = null,
    Object? objectKey = null,
    Object? presignedUrl = null,
    Object? attachmentsExtension = null,
    Object? attachmentsSize = null,
    Object? fileName = null,
    Object? imagesWidth = null,
    Object? imagesHeight = null,
    Object? createdAt = freezed,
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
            attachmentsType: null == attachmentsType
                ? _value.attachmentsType
                : attachmentsType // ignore: cast_nullable_to_non_nullable
                      as String,
            textContent: null == textContent
                ? _value.textContent
                : textContent // ignore: cast_nullable_to_non_nullable
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
            imagesWidth: null == imagesWidth
                ? _value.imagesWidth
                : imagesWidth // ignore: cast_nullable_to_non_nullable
                      as int,
            imagesHeight: null == imagesHeight
                ? _value.imagesHeight
                : imagesHeight // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttachmentImageDtoImplCopyWith<$Res>
    implements $AttachmentImageDtoCopyWith<$Res> {
  factory _$$AttachmentImageDtoImplCopyWith(
    _$AttachmentImageDtoImpl value,
    $Res Function(_$AttachmentImageDtoImpl) then,
  ) = __$$AttachmentImageDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _intFromJson) int attachmentsId,
    @JsonKey(fromJson: _intFromJson) int usersId,
    String attachmentsType,
    String textContent,
    String objectKey,
    @JsonKey(readValue: _readPresignedUrlKey) String presignedUrl,
    String attachmentsExtension,
    double attachmentsSize,
    String fileName,
    int imagesWidth,
    int imagesHeight,
    String? createdAt,
  });
}

/// @nodoc
class __$$AttachmentImageDtoImplCopyWithImpl<$Res>
    extends _$AttachmentImageDtoCopyWithImpl<$Res, _$AttachmentImageDtoImpl>
    implements _$$AttachmentImageDtoImplCopyWith<$Res> {
  __$$AttachmentImageDtoImplCopyWithImpl(
    _$AttachmentImageDtoImpl _value,
    $Res Function(_$AttachmentImageDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttachmentImageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachmentsId = null,
    Object? usersId = null,
    Object? attachmentsType = null,
    Object? textContent = null,
    Object? objectKey = null,
    Object? presignedUrl = null,
    Object? attachmentsExtension = null,
    Object? attachmentsSize = null,
    Object? fileName = null,
    Object? imagesWidth = null,
    Object? imagesHeight = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AttachmentImageDtoImpl(
        attachmentsId: null == attachmentsId
            ? _value.attachmentsId
            : attachmentsId // ignore: cast_nullable_to_non_nullable
                  as int,
        usersId: null == usersId
            ? _value.usersId
            : usersId // ignore: cast_nullable_to_non_nullable
                  as int,
        attachmentsType: null == attachmentsType
            ? _value.attachmentsType
            : attachmentsType // ignore: cast_nullable_to_non_nullable
                  as String,
        textContent: null == textContent
            ? _value.textContent
            : textContent // ignore: cast_nullable_to_non_nullable
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
        imagesWidth: null == imagesWidth
            ? _value.imagesWidth
            : imagesWidth // ignore: cast_nullable_to_non_nullable
                  as int,
        imagesHeight: null == imagesHeight
            ? _value.imagesHeight
            : imagesHeight // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttachmentImageDtoImpl implements _AttachmentImageDto {
  const _$AttachmentImageDtoImpl({
    @JsonKey(fromJson: _intFromJson) this.attachmentsId = 0,
    @JsonKey(fromJson: _intFromJson) this.usersId = 0,
    this.attachmentsType = '',
    this.textContent = '',
    this.objectKey = '',
    @JsonKey(readValue: _readPresignedUrlKey) this.presignedUrl = '',
    this.attachmentsExtension = '',
    this.attachmentsSize = 0.0,
    this.fileName = '',
    this.imagesWidth = 0,
    this.imagesHeight = 0,
    this.createdAt,
  });

  factory _$AttachmentImageDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttachmentImageDtoImplFromJson(json);

  @override
  @JsonKey(fromJson: _intFromJson)
  final int attachmentsId;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int usersId;
  @override
  @JsonKey()
  final String attachmentsType;
  @override
  @JsonKey()
  final String textContent;
  @override
  @JsonKey()
  final String objectKey;
  @override
  @JsonKey(readValue: _readPresignedUrlKey)
  final String presignedUrl;
  @override
  @JsonKey()
  final String attachmentsExtension;
  @override
  @JsonKey()
  final double attachmentsSize;
  @override
  @JsonKey()
  final String fileName;
  @override
  @JsonKey()
  final int imagesWidth;
  @override
  @JsonKey()
  final int imagesHeight;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'AttachmentImageDto(attachmentsId: $attachmentsId, usersId: $usersId, attachmentsType: $attachmentsType, textContent: $textContent, objectKey: $objectKey, presignedUrl: $presignedUrl, attachmentsExtension: $attachmentsExtension, attachmentsSize: $attachmentsSize, fileName: $fileName, imagesWidth: $imagesWidth, imagesHeight: $imagesHeight, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttachmentImageDtoImpl &&
            (identical(other.attachmentsId, attachmentsId) ||
                other.attachmentsId == attachmentsId) &&
            (identical(other.usersId, usersId) || other.usersId == usersId) &&
            (identical(other.attachmentsType, attachmentsType) ||
                other.attachmentsType == attachmentsType) &&
            (identical(other.textContent, textContent) ||
                other.textContent == textContent) &&
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
            (identical(other.imagesWidth, imagesWidth) ||
                other.imagesWidth == imagesWidth) &&
            (identical(other.imagesHeight, imagesHeight) ||
                other.imagesHeight == imagesHeight) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    attachmentsId,
    usersId,
    attachmentsType,
    textContent,
    objectKey,
    presignedUrl,
    attachmentsExtension,
    attachmentsSize,
    fileName,
    imagesWidth,
    imagesHeight,
    createdAt,
  );

  /// Create a copy of AttachmentImageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttachmentImageDtoImplCopyWith<_$AttachmentImageDtoImpl> get copyWith =>
      __$$AttachmentImageDtoImplCopyWithImpl<_$AttachmentImageDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttachmentImageDtoImplToJson(this);
  }
}

abstract class _AttachmentImageDto implements AttachmentImageDto {
  const factory _AttachmentImageDto({
    @JsonKey(fromJson: _intFromJson) final int attachmentsId,
    @JsonKey(fromJson: _intFromJson) final int usersId,
    final String attachmentsType,
    final String textContent,
    final String objectKey,
    @JsonKey(readValue: _readPresignedUrlKey) final String presignedUrl,
    final String attachmentsExtension,
    final double attachmentsSize,
    final String fileName,
    final int imagesWidth,
    final int imagesHeight,
    final String? createdAt,
  }) = _$AttachmentImageDtoImpl;

  factory _AttachmentImageDto.fromJson(Map<String, dynamic> json) =
      _$AttachmentImageDtoImpl.fromJson;

  @override
  @JsonKey(fromJson: _intFromJson)
  int get attachmentsId;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get usersId;
  @override
  String get attachmentsType;
  @override
  String get textContent;
  @override
  String get objectKey;
  @override
  @JsonKey(readValue: _readPresignedUrlKey)
  String get presignedUrl;
  @override
  String get attachmentsExtension;
  @override
  double get attachmentsSize;
  @override
  String get fileName;
  @override
  int get imagesWidth;
  @override
  int get imagesHeight;
  @override
  String? get createdAt;

  /// Create a copy of AttachmentImageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttachmentImageDtoImplCopyWith<_$AttachmentImageDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
