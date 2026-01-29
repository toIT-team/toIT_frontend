// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CalendarState {
  DateTime get focusedMonth => throw _privateConstructorUsedError;
  DateTime? get selectedDate => throw _privateConstructorUsedError;
  List<CalendarEvent> get events => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of CalendarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarStateCopyWith<CalendarState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarStateCopyWith<$Res> {
  factory $CalendarStateCopyWith(
    CalendarState value,
    $Res Function(CalendarState) then,
  ) = _$CalendarStateCopyWithImpl<$Res, CalendarState>;
  @useResult
  $Res call({
    DateTime focusedMonth,
    DateTime? selectedDate,
    List<CalendarEvent> events,
    bool isLoading,
  });
}

/// @nodoc
class _$CalendarStateCopyWithImpl<$Res, $Val extends CalendarState>
    implements $CalendarStateCopyWith<$Res> {
  _$CalendarStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? focusedMonth = null,
    Object? selectedDate = freezed,
    Object? events = null,
    Object? isLoading = null,
  }) {
    return _then(
      _value.copyWith(
            focusedMonth: null == focusedMonth
                ? _value.focusedMonth
                : focusedMonth // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            selectedDate: freezed == selectedDate
                ? _value.selectedDate
                : selectedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            events: null == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<CalendarEvent>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CalendarStateImplCopyWith<$Res>
    implements $CalendarStateCopyWith<$Res> {
  factory _$$CalendarStateImplCopyWith(
    _$CalendarStateImpl value,
    $Res Function(_$CalendarStateImpl) then,
  ) = __$$CalendarStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime focusedMonth,
    DateTime? selectedDate,
    List<CalendarEvent> events,
    bool isLoading,
  });
}

/// @nodoc
class __$$CalendarStateImplCopyWithImpl<$Res>
    extends _$CalendarStateCopyWithImpl<$Res, _$CalendarStateImpl>
    implements _$$CalendarStateImplCopyWith<$Res> {
  __$$CalendarStateImplCopyWithImpl(
    _$CalendarStateImpl _value,
    $Res Function(_$CalendarStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CalendarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? focusedMonth = null,
    Object? selectedDate = freezed,
    Object? events = null,
    Object? isLoading = null,
  }) {
    return _then(
      _$CalendarStateImpl(
        focusedMonth: null == focusedMonth
            ? _value.focusedMonth
            : focusedMonth // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        selectedDate: freezed == selectedDate
            ? _value.selectedDate
            : selectedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        events: null == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<CalendarEvent>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CalendarStateImpl implements _CalendarState {
  const _$CalendarStateImpl({
    required this.focusedMonth,
    this.selectedDate,
    final List<CalendarEvent> events = const [],
    this.isLoading = false,
  }) : _events = events;

  @override
  final DateTime focusedMonth;
  @override
  final DateTime? selectedDate;
  final List<CalendarEvent> _events;
  @override
  @JsonKey()
  List<CalendarEvent> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'CalendarState(focusedMonth: $focusedMonth, selectedDate: $selectedDate, events: $events, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarStateImpl &&
            (identical(other.focusedMonth, focusedMonth) ||
                other.focusedMonth == focusedMonth) &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    focusedMonth,
    selectedDate,
    const DeepCollectionEquality().hash(_events),
    isLoading,
  );

  /// Create a copy of CalendarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarStateImplCopyWith<_$CalendarStateImpl> get copyWith =>
      __$$CalendarStateImplCopyWithImpl<_$CalendarStateImpl>(this, _$identity);
}

abstract class _CalendarState implements CalendarState {
  const factory _CalendarState({
    required final DateTime focusedMonth,
    final DateTime? selectedDate,
    final List<CalendarEvent> events,
    final bool isLoading,
  }) = _$CalendarStateImpl;

  @override
  DateTime get focusedMonth;
  @override
  DateTime? get selectedDate;
  @override
  List<CalendarEvent> get events;
  @override
  bool get isLoading;

  /// Create a copy of CalendarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarStateImplCopyWith<_$CalendarStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
