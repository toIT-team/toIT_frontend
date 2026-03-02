// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'folder_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FolderItem _$FolderItemFromJson(Map<String, dynamic> json) {
  return _FolderItem.fromJson(json);
}

/// @nodoc
mixin _$FolderItem {
  /// 폴더 ID
  int get foldersId => throw _privateConstructorUsedError;

  /// 폴더 제목
  String get title => throw _privateConstructorUsedError;

  /// 메모
  String get memo => throw _privateConstructorUsedError;

  /// 항목 개수 텍스트 (예: "2개")
  String get countText => throw _privateConstructorUsedError;

  /// 색상 인덱스 (folderColors 기준)
  int get colorIndex => throw _privateConstructorUsedError;

  /// 기본 보관함 여부 (자동 선택용)
  @JsonKey(fromJson: _boolFromJson)
  bool get isDefault => throw _privateConstructorUsedError;

  /// 강조 색상 (JSON 제외)
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color get accentColor => throw _privateConstructorUsedError;

  /// Serializes this FolderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FolderItemCopyWith<FolderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FolderItemCopyWith<$Res> {
  factory $FolderItemCopyWith(
    FolderItem value,
    $Res Function(FolderItem) then,
  ) = _$FolderItemCopyWithImpl<$Res, FolderItem>;
  @useResult
  $Res call({
    int foldersId,
    String title,
    String memo,
    String countText,
    int colorIndex,
    @JsonKey(fromJson: _boolFromJson) bool isDefault,
    @JsonKey(includeFromJson: false, includeToJson: false) Color accentColor,
  });
}

/// @nodoc
class _$FolderItemCopyWithImpl<$Res, $Val extends FolderItem>
    implements $FolderItemCopyWith<$Res> {
  _$FolderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foldersId = null,
    Object? title = null,
    Object? memo = null,
    Object? countText = null,
    Object? colorIndex = null,
    Object? isDefault = null,
    Object? accentColor = null,
  }) {
    return _then(
      _value.copyWith(
            foldersId: null == foldersId
                ? _value.foldersId
                : foldersId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            memo: null == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String,
            countText: null == countText
                ? _value.countText
                : countText // ignore: cast_nullable_to_non_nullable
                      as String,
            colorIndex: null == colorIndex
                ? _value.colorIndex
                : colorIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$FolderItemImplCopyWith<$Res>
    implements $FolderItemCopyWith<$Res> {
  factory _$$FolderItemImplCopyWith(
    _$FolderItemImpl value,
    $Res Function(_$FolderItemImpl) then,
  ) = __$$FolderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int foldersId,
    String title,
    String memo,
    String countText,
    int colorIndex,
    @JsonKey(fromJson: _boolFromJson) bool isDefault,
    @JsonKey(includeFromJson: false, includeToJson: false) Color accentColor,
  });
}

/// @nodoc
class __$$FolderItemImplCopyWithImpl<$Res>
    extends _$FolderItemCopyWithImpl<$Res, _$FolderItemImpl>
    implements _$$FolderItemImplCopyWith<$Res> {
  __$$FolderItemImplCopyWithImpl(
    _$FolderItemImpl _value,
    $Res Function(_$FolderItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foldersId = null,
    Object? title = null,
    Object? memo = null,
    Object? countText = null,
    Object? colorIndex = null,
    Object? isDefault = null,
    Object? accentColor = null,
  }) {
    return _then(
      _$FolderItemImpl(
        foldersId: null == foldersId
            ? _value.foldersId
            : foldersId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        memo: null == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String,
        countText: null == countText
            ? _value.countText
            : countText // ignore: cast_nullable_to_non_nullable
                  as String,
        colorIndex: null == colorIndex
            ? _value.colorIndex
            : colorIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$FolderItemImpl implements _FolderItem {
  const _$FolderItemImpl({
    this.foldersId = 0,
    required this.title,
    this.memo = '',
    required this.countText,
    this.colorIndex = 5,
    @JsonKey(fromJson: _boolFromJson) this.isDefault = false,
    @JsonKey(includeFromJson: false, includeToJson: false)
    this.accentColor = const Color(0xFFA2CAFF),
  });

  factory _$FolderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FolderItemImplFromJson(json);

  /// 폴더 ID
  @override
  @JsonKey()
  final int foldersId;

  /// 폴더 제목
  @override
  final String title;

  /// 메모
  @override
  @JsonKey()
  final String memo;

  /// 항목 개수 텍스트 (예: "2개")
  @override
  final String countText;

  /// 색상 인덱스 (folderColors 기준)
  @override
  @JsonKey()
  final int colorIndex;

  /// 기본 보관함 여부 (자동 선택용)
  @override
  @JsonKey(fromJson: _boolFromJson)
  final bool isDefault;

  /// 강조 색상 (JSON 제외)
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Color accentColor;

  @override
  String toString() {
    return 'FolderItem(foldersId: $foldersId, title: $title, memo: $memo, countText: $countText, colorIndex: $colorIndex, isDefault: $isDefault, accentColor: $accentColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FolderItemImpl &&
            (identical(other.foldersId, foldersId) ||
                other.foldersId == foldersId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.countText, countText) ||
                other.countText == countText) &&
            (identical(other.colorIndex, colorIndex) ||
                other.colorIndex == colorIndex) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    foldersId,
    title,
    memo,
    countText,
    colorIndex,
    isDefault,
    accentColor,
  );

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FolderItemImplCopyWith<_$FolderItemImpl> get copyWith =>
      __$$FolderItemImplCopyWithImpl<_$FolderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FolderItemImplToJson(this);
  }
}

abstract class _FolderItem implements FolderItem {
  const factory _FolderItem({
    final int foldersId,
    required final String title,
    final String memo,
    required final String countText,
    final int colorIndex,
    @JsonKey(fromJson: _boolFromJson) final bool isDefault,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final Color accentColor,
  }) = _$FolderItemImpl;

  factory _FolderItem.fromJson(Map<String, dynamic> json) =
      _$FolderItemImpl.fromJson;

  /// 폴더 ID
  @override
  int get foldersId;

  /// 폴더 제목
  @override
  String get title;

  /// 메모
  @override
  String get memo;

  /// 항목 개수 텍스트 (예: "2개")
  @override
  String get countText;

  /// 색상 인덱스 (folderColors 기준)
  @override
  int get colorIndex;

  /// 기본 보관함 여부 (자동 선택용)
  @override
  @JsonKey(fromJson: _boolFromJson)
  bool get isDefault;

  /// 강조 색상 (JSON 제외)
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  Color get accentColor;

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FolderItemImplCopyWith<_$FolderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
