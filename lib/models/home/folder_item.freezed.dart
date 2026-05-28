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

  /// 폴더 아이콘 인덱스 (assets/icons/FolderIcon/0~11.png)
  int get iconIndex => throw _privateConstructorUsedError;

  /// 기본 보관함 여부 (자동 선택용)
  bool get isDefault => throw _privateConstructorUsedError;

  /// 즐겨찾기 여부 (홈·검색 응답과 동기)
  bool get isFavorite => throw _privateConstructorUsedError;

  /// 강조 색상 (JSON 제외)
  Color get accentColor => throw _privateConstructorUsedError;

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
    int iconIndex,
    bool isDefault,
    bool isFavorite,
    Color accentColor,
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
    Object? iconIndex = null,
    Object? isDefault = null,
    Object? isFavorite = null,
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
            iconIndex: null == iconIndex
                ? _value.iconIndex
                : iconIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
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
    int iconIndex,
    bool isDefault,
    bool isFavorite,
    Color accentColor,
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
    Object? iconIndex = null,
    Object? isDefault = null,
    Object? isFavorite = null,
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
        iconIndex: null == iconIndex
            ? _value.iconIndex
            : iconIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
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

class _$FolderItemImpl implements _FolderItem {
  const _$FolderItemImpl({
    this.foldersId = 0,
    required this.title,
    this.memo = '',
    required this.countText,
    this.colorIndex = 5,
    this.iconIndex = 0,
    this.isDefault = false,
    this.isFavorite = false,
    this.accentColor = const Color(0xFFA2CAFF),
  });

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

  /// 폴더 아이콘 인덱스 (assets/icons/FolderIcon/0~11.png)
  @override
  @JsonKey()
  final int iconIndex;

  /// 기본 보관함 여부 (자동 선택용)
  @override
  @JsonKey()
  final bool isDefault;

  /// 즐겨찾기 여부 (홈·검색 응답과 동기)
  @override
  @JsonKey()
  final bool isFavorite;

  /// 강조 색상 (JSON 제외)
  @override
  @JsonKey()
  final Color accentColor;

  @override
  String toString() {
    return 'FolderItem(foldersId: $foldersId, title: $title, memo: $memo, countText: $countText, colorIndex: $colorIndex, iconIndex: $iconIndex, isDefault: $isDefault, isFavorite: $isFavorite, accentColor: $accentColor)';
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
            (identical(other.iconIndex, iconIndex) ||
                other.iconIndex == iconIndex) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    foldersId,
    title,
    memo,
    countText,
    colorIndex,
    iconIndex,
    isDefault,
    isFavorite,
    accentColor,
  );

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FolderItemImplCopyWith<_$FolderItemImpl> get copyWith =>
      __$$FolderItemImplCopyWithImpl<_$FolderItemImpl>(this, _$identity);
}

abstract class _FolderItem implements FolderItem {
  const factory _FolderItem({
    final int foldersId,
    required final String title,
    final String memo,
    required final String countText,
    final int colorIndex,
    final int iconIndex,
    final bool isDefault,
    final bool isFavorite,
    final Color accentColor,
  }) = _$FolderItemImpl;

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

  /// 폴더 아이콘 인덱스 (assets/icons/FolderIcon/0~11.png)
  @override
  int get iconIndex;

  /// 기본 보관함 여부 (자동 선택용)
  @override
  bool get isDefault;

  /// 즐겨찾기 여부 (홈·검색 응답과 동기)
  @override
  bool get isFavorite;

  /// 강조 색상 (JSON 제외)
  @override
  Color get accentColor;

  /// Create a copy of FolderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FolderItemImplCopyWith<_$FolderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
