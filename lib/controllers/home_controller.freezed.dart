// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HomeState {
  /// 사용자 이름
  String get userName => throw _privateConstructorUsedError;

  /// 오늘 일정 개수
  int get todayScheduleCount => throw _privateConstructorUsedError;

  /// 오늘 일정 목록
  List<Schedule> get schedules => throw _privateConstructorUsedError;

  /// 폴더 목록
  List<FolderItem> get folders => throw _privateConstructorUsedError;

  /// 필터 목록
  List<String> get filters => throw _privateConstructorUsedError;

  /// 선택된 필터 인덱스
  int get selectedFilterIndex => throw _privateConstructorUsedError;

  /// 로딩 상태
  bool get isLoading => throw _privateConstructorUsedError;

  /// 에러 메시지
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call({
    String userName,
    int todayScheduleCount,
    List<Schedule> schedules,
    List<FolderItem> folders,
    List<String> filters,
    int selectedFilterIndex,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userName = null,
    Object? todayScheduleCount = null,
    Object? schedules = null,
    Object? folders = null,
    Object? filters = null,
    Object? selectedFilterIndex = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            todayScheduleCount: null == todayScheduleCount
                ? _value.todayScheduleCount
                : todayScheduleCount // ignore: cast_nullable_to_non_nullable
                      as int,
            schedules: null == schedules
                ? _value.schedules
                : schedules // ignore: cast_nullable_to_non_nullable
                      as List<Schedule>,
            folders: null == folders
                ? _value.folders
                : folders // ignore: cast_nullable_to_non_nullable
                      as List<FolderItem>,
            filters: null == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            selectedFilterIndex: null == selectedFilterIndex
                ? _value.selectedFilterIndex
                : selectedFilterIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
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
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
    _$HomeStateImpl value,
    $Res Function(_$HomeStateImpl) then,
  ) = __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userName,
    int todayScheduleCount,
    List<Schedule> schedules,
    List<FolderItem> folders,
    List<String> filters,
    int selectedFilterIndex,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
    _$HomeStateImpl _value,
    $Res Function(_$HomeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userName = null,
    Object? todayScheduleCount = null,
    Object? schedules = null,
    Object? folders = null,
    Object? filters = null,
    Object? selectedFilterIndex = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$HomeStateImpl(
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        todayScheduleCount: null == todayScheduleCount
            ? _value.todayScheduleCount
            : todayScheduleCount // ignore: cast_nullable_to_non_nullable
                  as int,
        schedules: null == schedules
            ? _value._schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<Schedule>,
        folders: null == folders
            ? _value._folders
            : folders // ignore: cast_nullable_to_non_nullable
                  as List<FolderItem>,
        filters: null == filters
            ? _value._filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        selectedFilterIndex: null == selectedFilterIndex
            ? _value.selectedFilterIndex
            : selectedFilterIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
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

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl({
    this.userName = '',
    this.todayScheduleCount = 0,
    final List<Schedule> schedules = const [],
    final List<FolderItem> folders = const [],
    final List<String> filters = const [],
    this.selectedFilterIndex = 0,
    this.isLoading = true,
    this.errorMessage,
  }) : _schedules = schedules,
       _folders = folders,
       _filters = filters;

  /// 사용자 이름
  @override
  @JsonKey()
  final String userName;

  /// 오늘 일정 개수
  @override
  @JsonKey()
  final int todayScheduleCount;

  /// 오늘 일정 목록
  final List<Schedule> _schedules;

  /// 오늘 일정 목록
  @override
  @JsonKey()
  List<Schedule> get schedules {
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedules);
  }

  /// 폴더 목록
  final List<FolderItem> _folders;

  /// 폴더 목록
  @override
  @JsonKey()
  List<FolderItem> get folders {
    if (_folders is EqualUnmodifiableListView) return _folders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_folders);
  }

  /// 필터 목록
  final List<String> _filters;

  /// 필터 목록
  @override
  @JsonKey()
  List<String> get filters {
    if (_filters is EqualUnmodifiableListView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filters);
  }

  /// 선택된 필터 인덱스
  @override
  @JsonKey()
  final int selectedFilterIndex;

  /// 로딩 상태
  @override
  @JsonKey()
  final bool isLoading;

  /// 에러 메시지
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'HomeState(userName: $userName, todayScheduleCount: $todayScheduleCount, schedules: $schedules, folders: $folders, filters: $filters, selectedFilterIndex: $selectedFilterIndex, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.todayScheduleCount, todayScheduleCount) ||
                other.todayScheduleCount == todayScheduleCount) &&
            const DeepCollectionEquality().equals(
              other._schedules,
              _schedules,
            ) &&
            const DeepCollectionEquality().equals(other._folders, _folders) &&
            const DeepCollectionEquality().equals(other._filters, _filters) &&
            (identical(other.selectedFilterIndex, selectedFilterIndex) ||
                other.selectedFilterIndex == selectedFilterIndex) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userName,
    todayScheduleCount,
    const DeepCollectionEquality().hash(_schedules),
    const DeepCollectionEquality().hash(_folders),
    const DeepCollectionEquality().hash(_filters),
    selectedFilterIndex,
    isLoading,
    errorMessage,
  );

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState implements HomeState {
  const factory _HomeState({
    final String userName,
    final int todayScheduleCount,
    final List<Schedule> schedules,
    final List<FolderItem> folders,
    final List<String> filters,
    final int selectedFilterIndex,
    final bool isLoading,
    final String? errorMessage,
  }) = _$HomeStateImpl;

  /// 사용자 이름
  @override
  String get userName;

  /// 오늘 일정 개수
  @override
  int get todayScheduleCount;

  /// 오늘 일정 목록
  @override
  List<Schedule> get schedules;

  /// 폴더 목록
  @override
  List<FolderItem> get folders;

  /// 필터 목록
  @override
  List<String> get filters;

  /// 선택된 필터 인덱스
  @override
  int get selectedFilterIndex;

  /// 로딩 상태
  @override
  bool get isLoading;

  /// 에러 메시지
  @override
  String? get errorMessage;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
