// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SearchState {
  String get query => throw _privateConstructorUsedError;
  SearchStatus get status => throw _privateConstructorUsedError;
  List<SearchResultItem> get items => throw _privateConstructorUsedError;
  SearchFilterType? get selectedFilter => throw _privateConstructorUsedError;
  List<String> get recentKeywords => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchStateCopyWith<SearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
    SearchState value,
    $Res Function(SearchState) then,
  ) = _$SearchStateCopyWithImpl<$Res, SearchState>;
  @useResult
  $Res call({
    String query,
    SearchStatus status,
    List<SearchResultItem> items,
    SearchFilterType? selectedFilter,
    List<String> recentKeywords,
    String? errorMessage,
  });
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res, $Val extends SearchState>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? status = null,
    Object? items = null,
    Object? selectedFilter = freezed,
    Object? recentKeywords = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SearchStatus,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<SearchResultItem>,
            selectedFilter: freezed == selectedFilter
                ? _value.selectedFilter
                : selectedFilter // ignore: cast_nullable_to_non_nullable
                      as SearchFilterType?,
            recentKeywords: null == recentKeywords
                ? _value.recentKeywords
                : recentKeywords // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
    _$SearchStateImpl value,
    $Res Function(_$SearchStateImpl) then,
  ) = __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String query,
    SearchStatus status,
    List<SearchResultItem> items,
    SearchFilterType? selectedFilter,
    List<String> recentKeywords,
    String? errorMessage,
  });
}

/// @nodoc
class __$$SearchStateImplCopyWithImpl<$Res>
    extends _$SearchStateCopyWithImpl<$Res, _$SearchStateImpl>
    implements _$$SearchStateImplCopyWith<$Res> {
  __$$SearchStateImplCopyWithImpl(
    _$SearchStateImpl _value,
    $Res Function(_$SearchStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? status = null,
    Object? items = null,
    Object? selectedFilter = freezed,
    Object? recentKeywords = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$SearchStateImpl(
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SearchStatus,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<SearchResultItem>,
        selectedFilter: freezed == selectedFilter
            ? _value.selectedFilter
            : selectedFilter // ignore: cast_nullable_to_non_nullable
                  as SearchFilterType?,
        recentKeywords: null == recentKeywords
            ? _value._recentKeywords
            : recentKeywords // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SearchStateImpl implements _SearchState {
  const _$SearchStateImpl({
    this.query = '',
    this.status = SearchStatus.initial,
    final List<SearchResultItem> items = const [],
    this.selectedFilter,
    final List<String> recentKeywords = const [],
    this.errorMessage,
  }) : _items = items,
       _recentKeywords = recentKeywords;

  @override
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final SearchStatus status;
  final List<SearchResultItem> _items;
  @override
  @JsonKey()
  List<SearchResultItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final SearchFilterType? selectedFilter;
  final List<String> _recentKeywords;
  @override
  @JsonKey()
  List<String> get recentKeywords {
    if (_recentKeywords is EqualUnmodifiableListView) return _recentKeywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentKeywords);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'SearchState(query: $query, status: $status, items: $items, selectedFilter: $selectedFilter, recentKeywords: $recentKeywords, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.selectedFilter, selectedFilter) ||
                other.selectedFilter == selectedFilter) &&
            const DeepCollectionEquality().equals(
              other._recentKeywords,
              _recentKeywords,
            ) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    query,
    status,
    const DeepCollectionEquality().hash(_items),
    selectedFilter,
    const DeepCollectionEquality().hash(_recentKeywords),
    errorMessage,
  );

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);
}

abstract class _SearchState implements SearchState {
  const factory _SearchState({
    final String query,
    final SearchStatus status,
    final List<SearchResultItem> items,
    final SearchFilterType? selectedFilter,
    final List<String> recentKeywords,
    final String? errorMessage,
  }) = _$SearchStateImpl;

  @override
  String get query;
  @override
  SearchStatus get status;
  @override
  List<SearchResultItem> get items;
  @override
  SearchFilterType? get selectedFilter;
  @override
  List<String> get recentKeywords;
  @override
  String? get errorMessage;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
