import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/calendar_utils.dart';
import '../models/calendar/calendar_event.dart';

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
  factory CalendarEventIndex.empty() => CalendarEventIndex(
        eventsByDay: {},
        eventSlots: {},
        overflowByDay: {},
      );

  /// 월 단위로 이벤트 인덱스 생성
  factory CalendarEventIndex.build(
    DateTime month,
    List<CalendarEvent> events,
  ) {
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
  @override
  CalendarState build() {
    final now = DateTime.now();
    return CalendarState(
      focusedMonth: DateTime(now.year, now.month, 1),
      selectedDate: now,
      events: _generateSampleEvents(),
    );
  }

  /// 이전 달로 이동
  void goToPreviousMonth() {
    state = state.copyWith(
      focusedMonth: DateTime(
        state.focusedMonth.year,
        state.focusedMonth.month - 1,
        1,
      ),
    );
  }

  /// 다음 달로 이동
  void goToNextMonth() {
    state = state.copyWith(
      focusedMonth: DateTime(
        state.focusedMonth.year,
        state.focusedMonth.month + 1,
        1,
      ),
    );
  }

  /// 특정 월로 이동
  void goToMonth(DateTime month) {
    state = state.copyWith(
      focusedMonth: DateTime(month.year, month.month, 1),
    );
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

  /// 샘플 일정 생성 (데모용)
  List<CalendarEvent> _generateSampleEvents() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // 날짜 문자열 생성 헬퍼
    String formatDate(int y, int m, int d) =>
        '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

    return [
      // 시간 설정된 일정 (단일 날짜)
      CalendarEvent(
        id: '1',
        usersId: 1,
        title: '팀 미팅',
        startAt: formatDate(year, month, 22),
        endAt: formatDate(year, month, 22),
        startTime: '14:00',
        endTime: '16:00',
        timeSetting: true,
        createdAt: DateTime(year, month, 22, 14, 30),
        color: AppTheme.eventColors[0],
      ),
      // 시간 미설정 일정 (여러 날)
      CalendarEvent(
        id: '2',
        usersId: 1,
        title: '1월 휴가',
        startAt: formatDate(year, month, 10),
        endAt: formatDate(year, month, 12),
        timeSetting: false,
        createdAt: DateTime(year, month, 1, 9, 0),
        color: AppTheme.eventColors[1],
      ),
      // 체력관리
      CalendarEvent(
        id: '3',
        usersId: 1,
        title: '체력관...',
        startAt: formatDate(year, month, 1),
        endAt: formatDate(year, month, 1),
        timeSetting: false,
        createdAt: DateTime(year, month, 1),
        color: AppTheme.eventColors[1],
      ),
      // 시각디자인 (여러 날)
      CalendarEvent(
        id: '4',
        usersId: 1,
        title: '시각디자인...',
        startAt: formatDate(year, month, 9),
        endAt: formatDate(year, month, 13),
        timeSetting: false,
        createdAt: DateTime(year, month, 8),
        color: AppTheme.eventColors[1],
      ),
      // 임상실습
      CalendarEvent(
        id: '5',
        usersId: 1,
        title: '임상실...',
        startAt: formatDate(year, month, 9),
        endAt: formatDate(year, month, 9),
        startTime: '09:00',
        endTime: '12:00',
        timeSetting: true,
        createdAt: DateTime(year, month, 8),
        color: AppTheme.eventColors[2],
      ),
      // 임상실습 2
      CalendarEvent(
        id: '6',
        usersId: 1,
        title: '임상실...',
        startAt: formatDate(year, month, 10),
        endAt: formatDate(year, month, 10),
        startTime: '09:00',
        endTime: '12:00',
        timeSetting: true,
        createdAt: DateTime(year, month, 8),
        color: AppTheme.eventColors[2],
      ),
      // UX 방법론
      CalendarEvent(
        id: '7',
        usersId: 1,
        title: 'ux 방...',
        startAt: formatDate(year, month, 11),
        endAt: formatDate(year, month, 11),
        timeSetting: false,
        createdAt: DateTime(year, month, 10),
        color: AppTheme.eventColors[2],
      ),
      // 물리치료학 (여러 날)
      CalendarEvent(
        id: '8',
        usersId: 1,
        title: '물리치료학',
        startAt: formatDate(year, month, 11),
        endAt: formatDate(year, month, 13),
        timeSetting: false,
        createdAt: DateTime(year, month, 10),
        color: AppTheme.eventColors[0],
      ),
      // 미용실
      CalendarEvent(
        id: '9',
        usersId: 1,
        title: '미용실',
        startAt: formatDate(year, month, 10),
        endAt: formatDate(year, month, 10),
        startTime: '15:00',
        endTime: '17:00',
        timeSetting: true,
        createdAt: DateTime(year, month, 9),
        color: AppTheme.eventColors[2],
      ),
      // 물리치료학 2 (여러 날)
      CalendarEvent(
        id: '10',
        usersId: 1,
        title: '물리치료학',
        startAt: formatDate(year, month, 14),
        endAt: formatDate(year, month, 17),
        timeSetting: false,
        createdAt: DateTime(year, month, 13),
        color: AppTheme.eventColors[0],
      ),
      // 크리스마스 파티
      CalendarEvent(
        id: '11',
        usersId: 1,
        title: '크리스...',
        startAt: formatDate(year, month, 25),
        endAt: formatDate(year, month, 25),
        startTime: '18:00',
        endTime: '22:00',
        timeSetting: true,
        createdAt: DateTime(year, month, 20),
        color: AppTheme.eventColors[2],
      ),
    ];
  }
}

/// 캘린더 Provider
final calendarProvider =
    NotifierProvider<CalendarController, CalendarState>(CalendarController.new);

/// 선택된 날짜 Provider (셀 단위 리빌드 최적화용)
final selectedDateProvider = Provider<DateTime?>((ref) {
  return ref.watch(calendarProvider.select((s) => s.selectedDate));
});

/// 이벤트 목록 Provider (이벤트 변경 시에만 리빌드)
final eventsProvider = Provider<List<CalendarEvent>>((ref) {
  return ref.watch(calendarProvider.select((s) => s.events));
});

/// 월별 이벤트 인덱스 Provider (Family - 월별로 캐시됨)
final eventIndexFamilyProvider =
    Provider.family<CalendarEventIndex, String>((ref, monthKey) {
  final events = ref.watch(eventsProvider);
  final parts = monthKey.split('-');
  final month = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
  return CalendarEventIndex.build(month, events);
});

/// 월 키 생성 헬퍼
String getMonthKey(DateTime month) =>
    '${month.year}-${month.month.toString().padLeft(2, '0')}';
