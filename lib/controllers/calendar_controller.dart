import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/utils/calendar_utils.dart';
import '../models/calendar/calendar_event.dart';
import '../services/schedule_api_client.dart';

part 'calendar_controller.freezed.dart';

/// 캘린더 이벤트 인덱스 (날짜별 이벤트 + 슬롯 정보)
class CalendarEventIndex {
  CalendarEventIndex({
    required this.eventsByDay,
    required this.eventSlots,
    required this.overflowByDay,
  });

  /// 날짜별 이벤트 목록 (key: "yyyy-MM-dd")
  final Map<String, List<CalendarEvent>> eventsByDay;

  /// 이벤트별 슬롯 위치 (key: eventId)
  final Map<String, int> eventSlots;

  /// 날짜별 오버플로우 카운트 (key: "yyyy-MM-dd")
  final Map<String, int> overflowByDay;

  static const int maxVisibleEvents = 3;

  /// 빈 인덱스
  factory CalendarEventIndex.empty() =>
      CalendarEventIndex(eventsByDay: {}, eventSlots: {}, overflowByDay: {});

  /// 월 단위로 이벤트 인덱스 생성
  factory CalendarEventIndex.build(DateTime month, List<CalendarEvent> events) {
    final days = CalendarUtils.getDaysInMonth(month);
    final eventsByDay = <String, List<CalendarEvent>>{};
    final eventSlots = <String, int>{};
    final overflowByDay = <String, int>{};

    // 주(week) 단위로 분할
    final weeks = <List<DateTime>>[];
    for (var i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7));
    }

    // 각 주별로 슬롯 할당
    for (final week in weeks) {
      final weekStart = week.first;
      final weekEvents = CalendarUtils.getEventsForWeek(weekStart, events)
        ..sort((a, b) {
          final startCompare = a.startDate.compareTo(b.startDate);
          if (startCompare != 0) return startCompare;
          return b.durationInDays.compareTo(a.durationInDays);
        });

      // 슬롯 할당
      final usedSlots = List.generate(7, (_) => <int>{});
      for (final event in weekEvents) {
        final dayIndices = <int>[];
        for (var i = 0; i < 7; i++) {
          if (event.occursOnDay(week[i])) {
            dayIndices.add(i);
          }
        }
        if (dayIndices.isEmpty) continue;

        var slot = 0;
        while (true) {
          var canUse = true;
          for (final dayIndex in dayIndices) {
            if (usedSlots[dayIndex].contains(slot)) {
              canUse = false;
              break;
            }
          }
          if (canUse) break;
          slot++;
        }

        eventSlots[event.id] = slot;
        for (final dayIndex in dayIndices) {
          usedSlots[dayIndex].add(slot);
        }
      }
    }

    // 날짜별 이벤트 & 오버플로우 계산
    for (final day in days) {
      final key = _dateKey(day);
      final dayEvents = events.where((e) => e.occursOnDay(day)).toList()
        ..sort((a, b) {
          final slotA = eventSlots[a.id] ?? 999;
          final slotB = eventSlots[b.id] ?? 999;
          return slotA.compareTo(slotB);
        });

      eventsByDay[key] = dayEvents;
      if (dayEvents.length > maxVisibleEvents) {
        overflowByDay[key] = dayEvents.length - maxVisibleEvents;
      }
    }

    return CalendarEventIndex(
      eventsByDay: eventsByDay,
      eventSlots: eventSlots,
      overflowByDay: overflowByDay,
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// 특정 날짜의 이벤트 조회 O(1)
  List<CalendarEvent> getEventsForDay(DateTime day) {
    return eventsByDay[_dateKey(day)] ?? [];
  }

  /// 특정 날짜의 오버플로우 카운트 조회 O(1)
  int getOverflowCount(DateTime day) {
    return overflowByDay[_dateKey(day)] ?? 0;
  }

  /// 이벤트의 슬롯 조회 O(1)
  int getSlot(String eventId) {
    return eventSlots[eventId] ?? 0;
  }
}

/// 캘린더 상태
@freezed
class CalendarState with _$CalendarState {
  const factory CalendarState({
    required DateTime focusedMonth,
    DateTime? selectedDate,
    @Default([]) List<CalendarEvent> events,
    @Default(false) bool isLoading,
  }) = _CalendarState;
}

/// 캘린더 컨트롤러 (Notifier)
class CalendarController extends Notifier<CalendarState> {
  late final ScheduleApiClient _apiClient;

  /// 스플래시 단계에서 주입된 프리패치를 이미 state 에 반영했음을 가리킨다.
  /// 최초 `loadEvents` 한 번은 같은 달에 대해 스킵하기 위한 1회성 플래그.
  ///
  /// `CalendarWidget.initState` 가 `addPostFrameCallback` 에서 `loadEvents` 를
  /// 호출하는 기존 동작을 유지하면서도, 프리패치 히트 시 네트워크 재호출이
  /// 발생하지 않게 만들기 위한 장치다. 두 번째 loadEvents 부터는 정상 동작.
  bool _primed = false;

  @override
  CalendarState build() {
    _apiClient = ref.watch(scheduleApiClientProvider);
    final now = DateTime.now();
    final focusedMonth = DateTime(now.year, now.month, 1);

    final prefetched = ref.read(calendarPrefetchProvider);
    if (prefetched != null &&
        prefetched.month.year == focusedMonth.year &&
        prefetched.month.month == focusedMonth.month) {
      // debugPrint(
        // '[BOOT] calendar_build source=prefetch_cache '
        // 'events=${prefetched.events.length}',
      // );
      _primed = true;
      // Riverpod 은 build() 도중 다른 Provider 의 state 수정을 금지하므로
      // 캐시 초기화는 한 틱 뒤로 미룬다(홈 프리패치와 동일한 패턴).
      Future<void>.microtask(() {
        ref.read(calendarPrefetchProvider.notifier).state = null;
      });
      return CalendarState(
        focusedMonth: focusedMonth,
        selectedDate: now,
        events: prefetched.events,
      );
    }

    // debugPrint('[BOOT] calendar_build source=network');
    return CalendarState(
      focusedMonth: focusedMonth,
      selectedDate: now,
      events: [],
    );
  }

  /// API에서 일정 로드
  Future<void> loadEvents(DateTime month) async {
    final targetMonth = DateTime(month.year, month.month, 1);
    // 프리패치로 이미 같은 달이 반영되어 있으면 초회 호출만 1회 스킵한다.
    if (_primed &&
        targetMonth.year == state.focusedMonth.year &&
        targetMonth.month == state.focusedMonth.month) {
      // debugPrint('[BOOT] calendar_loadEvents_skipped reason=primed_same_month');
      _primed = false;
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final startDate = targetMonth;
      final endDate = DateTime(targetMonth.year, targetMonth.month + 1, 0);
      final events = await _apiClient.searchSchedules(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(
        focusedMonth: targetMonth,
        events: events,
        isLoading: false,
      );
    } catch (e) {
      // debugPrint('일정 로드 실패: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// 이전 달로 이동
  void goToPreviousMonth() {
    final prev = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month - 1,
      1,
    );
    loadEvents(prev);
  }

  /// 다음 달로 이동
  void goToNextMonth() {
    final next = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
      1,
    );
    loadEvents(next);
  }

  /// 특정 월로 이동
  void goToMonth(DateTime month) {
    loadEvents(DateTime(month.year, month.month, 1));
  }

  /// 날짜 선택
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// 일정 추가
  void addEvent(CalendarEvent event) {
    state = state.copyWith(events: [...state.events, event]);
  }

  /// 일정 삭제
  void removeEvent(String eventId) {
    state = state.copyWith(
      events: state.events.where((e) => e.id != eventId).toList(),
    );
  }

  /// 일정 업데이트
  void updateEvent(CalendarEvent event) {
    state = state.copyWith(
      events: state.events.map((e) => e.id == event.id ? event : e).toList(),
    );
  }
}

/// 스플래시 부트스트랩에서 선요청해둔 현재월 일정 응답을 1회 주입하는 캐시.
///
/// - 스플래시 단계에서 `BootstrapController` 가 `(month, events)` 를 주입한다.
/// - `CalendarController.build()` 가 기동될 때 해당 월이 `focusedMonth` 와
///   일치하면 1회 소비되며 즉시 `null` 로 초기화된다.
/// - 이 값이 반영되면 `CalendarWidget` 의 초기 `loadEvents` 는 1회 스킵된다.
class CalendarPrefetchData {
  const CalendarPrefetchData({required this.month, required this.events});

  /// 이 프리패치가 담고 있는 월의 1일 (00:00).
  final DateTime month;

  /// `searchSchedules` 응답을 도메인 타입으로 변환한 결과.
  final List<CalendarEvent> events;
}

final calendarPrefetchProvider = StateProvider<CalendarPrefetchData?>(
  (ref) => null,
);

/// 캘린더 Provider
final calendarProvider = NotifierProvider<CalendarController, CalendarState>(
  CalendarController.new,
);

/// 선택된 날짜 Provider (셀 단위 리빌드 최적화용)
final selectedDateProvider = Provider<DateTime?>((ref) {
  return ref.watch(calendarProvider.select((s) => s.selectedDate));
});

/// 이벤트 목록 Provider (이벤트 변경 시에만 리빌드)
final eventsProvider = Provider<List<CalendarEvent>>((ref) {
  return ref.watch(calendarProvider.select((s) => s.events));
});

/// 월별 이벤트 인덱스 Provider (Family - 월별로 캐시됨)
final eventIndexFamilyProvider = Provider.family<CalendarEventIndex, String>((
  ref,
  monthKey,
) {
  final events = ref.watch(eventsProvider);
  final parts = monthKey.split('-');
  final month = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
  return CalendarEventIndex.build(month, events);
});

/// 월 키 생성 헬퍼
String getMonthKey(DateTime month) =>
    '${month.year}-${month.month.toString().padLeft(2, '0')}';
