import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/utils/calendar_utils.dart';
import '../models/calendar/calendar_event.dart';
import '../services/schedule_api_client.dart';

part 'calendar_controller.freezed.dart';

/// 주 단위 이벤트 연속 구간 (슬롯·열 범위 포함)
class CalendarWeekEventSegment {
  const CalendarWeekEventSegment({
    required this.event,
    required this.startCol,
    required this.endCol,
    required this.slot,
  });

  final CalendarEvent event;
  final int startCol;
  final int endCol;
  final int slot;
}

/// 캘린더 이벤트 인덱스 (날짜별 이벤트 + 슬롯 정보)
class CalendarEventIndex {
  CalendarEventIndex({
    required this.eventsByDay,
    required this.segmentsByWeek,
    required this.overflowByDay,
  });

  /// 날짜별 이벤트 목록 (key: "yyyy-MM-dd")
  final Map<String, List<CalendarEvent>> eventsByDay;

  /// 주별 이벤트 구간 목록 (key: 주 시작일 "yyyy-MM-dd")
  final Map<String, List<CalendarWeekEventSegment>> segmentsByWeek;

  /// 날짜별 오버플로우 카운트 (key: "yyyy-MM-dd")
  final Map<String, int> overflowByDay;

  static const int maxVisibleEvents = 3;

  /// 빈 인덱스
  factory CalendarEventIndex.empty() => CalendarEventIndex(
        eventsByDay: {},
        segmentsByWeek: {},
        overflowByDay: {},
      );

  /// 열 인덱스를 연속 구간으로 분리 (일요일=0 … 토요일=6)
  static List<List<int>> splitContiguousDayIndices(List<int> dayIndices) {
    if (dayIndices.isEmpty) return [];

    final sorted = List<int>.from(dayIndices)..sort();
    final segments = <List<int>>[];
    var current = [sorted.first];

    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i] == sorted[i - 1] + 1) {
        current.add(sorted[i]);
      } else {
        segments.add(current);
        current = [sorted[i]];
      }
    }
    segments.add(current);
    return segments;
  }

  /// 슬롯 할당·표시 우선순위 비교
  static int compareEventsForSlot(CalendarEvent a, CalendarEvent b) {
    final startCompare = a.startDate.compareTo(b.startDate);
    if (startCompare != 0) return startCompare;

    final durationCompare =
        b.durationInDays.compareTo(a.durationInDays);
    if (durationCompare != 0) return durationCompare;

    if (!a.timeSetting && b.timeSetting) return -1;
    if (a.timeSetting && !b.timeSetting) return 1;
    if (a.timeSetting &&
        b.timeSetting &&
        a.startTime != null &&
        b.startTime != null) {
      final timeCompare = a.startTime!.compareTo(b.startTime!);
      if (timeCompare != 0) return timeCompare;
    }

    if (a.createdAt != null && b.createdAt != null) {
      final createdCompare = a.createdAt!.compareTo(b.createdAt!);
      if (createdCompare != 0) return createdCompare;
    } else if (a.createdAt != null) {
      return -1;
    } else if (b.createdAt != null) {
      return 1;
    }

    return a.id.compareTo(b.id);
  }

  /// 월 단위로 이벤트 인덱스 생성
  factory CalendarEventIndex.build(DateTime month, List<CalendarEvent> events) {
    final days = CalendarUtils.getDaysInMonth(month);
    final eventsByDay = <String, List<CalendarEvent>>{};
    final segmentsByWeek = <String, List<CalendarWeekEventSegment>>{};
    final overflowByDay = <String, int>{};

    // 주(week) 단위로 분할
    final weeks = <List<DateTime>>[];
    for (var i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7));
    }

    // 각 주별로 구간 단위 슬롯 할당.
    // 매 주 동일한 우선순위 규칙으로 새로 배치하므로, 같은 일정 구성에서는
    // 자연히 같은 슬롯을 얻어 안정적이고, 위 슬롯이 비면 곧바로 채운다.
    for (final week in weeks) {
      final weekStart = week.first;
      final weekKey = _dateKey(weekStart);
      final weekEvents = CalendarUtils.getEventsForWeek(weekStart, events);

      final pendingSegments = <_PendingWeekSegment>[];
      for (final event in weekEvents) {
        final dayIndices = <int>[];
        for (var i = 0; i < 7; i++) {
          if (event.occursOnDay(week[i])) {
            dayIndices.add(i);
          }
        }

        for (final indices in splitContiguousDayIndices(dayIndices)) {
          pendingSegments.add(
            _PendingWeekSegment(
              event: event,
              dayIndices: indices,
              startCol: indices.first,
              endCol: indices.last,
            ),
          );
        }
      }

      // 우선순위 단일 규칙: 시작일 빠른 순 → 기간 긴 순 → … → createdAt.
      // 늦게 만든/늦게 시작한 일정은 뒤로 정렬되어 기존 줄을 밀어내지 못한다.
      pendingSegments.sort((a, b) {
        final eventCmp = compareEventsForSlot(a.event, b.event);
        if (eventCmp != 0) return eventCmp;
        return a.startCol.compareTo(b.startCol);
      });

      final usedSlots = List.generate(7, (_) => <int>{});
      var weekSegments = <CalendarWeekEventSegment>[];

      for (final pending in pendingSegments) {
        var slot = 0;
        while (!_canUseSlot(pending.dayIndices, slot, usedSlots)) {
          slot++;
        }

        for (final dayIndex in pending.dayIndices) {
          usedSlots[dayIndex].add(slot);
        }

        weekSegments.add(
          CalendarWeekEventSegment(
            event: pending.event,
            startCol: pending.startCol,
            endCol: pending.endCol,
            slot: slot,
          ),
        );
      }

      // 숨겨진(슬롯 3+) 구간만, 빈 줄이 생기면 그 줄로 "등장"시킨다.
      // 이미 보이는 줄은 절대 건드리지 않고, 한 번 보인 줄은 끝까지 고정.
      weekSegments = _splitHiddenSegments(weekSegments);
      segmentsByWeek[weekKey] = weekSegments;
    }

    // 날짜별 이벤트 & 오버플로우 계산
    for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final day = days[dayIndex];
      final weekStart = days[dayIndex - dayIndex % 7];
      final dayCol = dayIndex % 7;
      final key = _dateKey(day);

      final dayEvents = events.where((e) => e.occursOnDay(day)).toList()
        ..sort((a, b) {
          final slotA = _slotForDay(
            segmentsByWeek,
            a.id,
            weekStart,
            dayCol,
          );
          final slotB = _slotForDay(
            segmentsByWeek,
            b.id,
            weekStart,
            dayCol,
          );
          return slotA.compareTo(slotB);
        });

      eventsByDay[key] = dayEvents;
      final hiddenCount = dayEvents
          .where(
            (event) =>
                _slotForDay(
                  segmentsByWeek,
                  event.id,
                  weekStart,
                  dayCol,
                ) >=
                maxVisibleEvents,
          )
          .length;
      if (hiddenCount > 0) {
        overflowByDay[key] = hiddenCount;
      }
    }

    return CalendarEventIndex(
      eventsByDay: eventsByDay,
      segmentsByWeek: segmentsByWeek,
      overflowByDay: overflowByDay,
    );
  }

  static bool _canUseSlot(
    List<int> dayIndices,
    int slot,
    List<Set<int>> usedSlots,
  ) {
    for (final dayIndex in dayIndices) {
      if (usedSlots[dayIndex].contains(slot)) {
        return false;
      }
    }
    return true;
  }

  /// 슬롯 3 이상(숨김)인 구간만 나눠 빈 줄을 재사용한다
  static List<CalendarWeekEventSegment> _splitHiddenSegments(
    List<CalendarWeekEventSegment> segments,
  ) {
    final occupancy = List.generate(7, (_) => <int>{});
    for (final segment in segments) {
      for (var col = segment.startCol; col <= segment.endCol; col++) {
        occupancy[col].add(segment.slot);
      }
    }

    final result = <CalendarWeekEventSegment>[];
    for (final segment in segments) {
      if (segment.slot < maxVisibleEvents) {
        result.add(segment);
        continue;
      }
      result.addAll(_splitSegmentByAvailability(segment, occupancy));
    }
    return result;
  }

  static List<CalendarWeekEventSegment> _splitSegmentByAvailability(
    CalendarWeekEventSegment segment,
    List<Set<int>> occupancy,
  ) {
    for (var col = segment.startCol; col <= segment.endCol; col++) {
      occupancy[col].remove(segment.slot);
    }

    final parts = <CalendarWeekEventSegment>[];
    var startCol = segment.startCol;

    while (startCol <= segment.endCol) {
      final slot = _lowestSlotAt(startCol, occupancy);
      var endCol = startCol;

      while (endCol + 1 <= segment.endCol) {
        final nextCol = endCol + 1;
        // 현재 슬롯이 다음 날에 막히면 무조건 끊는다.
        if (occupancy[nextCol].contains(slot)) {
          break;
        }
        // 아직 숨김 상태인데 다음 날 보이는 줄이 열리면, 거기서 "등장"하도록 끊는다.
        if (slot >= maxVisibleEvents &&
            _lowestSlotAt(nextCol, occupancy) < maxVisibleEvents) {
          break;
        }
        // 보이는 줄은 더 낮은 줄이 열려도 그대로 유지 (점프 방지).
        endCol++;
      }

      for (var col = startCol; col <= endCol; col++) {
        occupancy[col].add(slot);
      }

      parts.add(
        CalendarWeekEventSegment(
          event: segment.event,
          startCol: startCol,
          endCol: endCol,
          slot: slot,
        ),
      );

      startCol = endCol + 1;
    }

    return parts;
  }

  static int _lowestSlotAt(int dayCol, List<Set<int>> occupancy) {
    var slot = 0;
    while (occupancy[dayCol].contains(slot)) {
      slot++;
    }
    return slot;
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static int _slotForDay(
    Map<String, List<CalendarWeekEventSegment>> segmentsByWeek,
    String eventId,
    DateTime weekStart,
    int dayCol,
  ) {
    for (final segment in segmentsByWeek[_dateKey(weekStart)] ?? []) {
      if (segment.event.id != eventId) continue;
      if (dayCol >= segment.startCol && dayCol <= segment.endCol) {
        return segment.slot;
      }
    }
    return 999;
  }

  /// 특정 날짜의 이벤트 조회 O(1)
  List<CalendarEvent> getEventsForDay(DateTime day) {
    return eventsByDay[_dateKey(day)] ?? [];
  }

  /// 특정 날짜의 오버플로우 카운트 조회 O(1)
  int getOverflowCount(DateTime day) {
    return overflowByDay[_dateKey(day)] ?? 0;
  }

  /// 주의 이벤트 구간 목록
  List<CalendarWeekEventSegment> getSegmentsForWeek(DateTime weekStart) {
    return segmentsByWeek[_dateKey(weekStart)] ?? [];
  }

  /// 특정 날짜 열에서 이벤트 슬롯 조회
  int getSlotForDay(String eventId, DateTime weekStart, int dayCol) {
    return _slotForDay(segmentsByWeek, eventId, weekStart, dayCol);
  }
}

class _PendingWeekSegment {
  const _PendingWeekSegment({
    required this.event,
    required this.dayIndices,
    required this.startCol,
    required this.endCol,
  });

  final CalendarEvent event;
  final List<int> dayIndices;
  final int startCol;
  final int endCol;
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
