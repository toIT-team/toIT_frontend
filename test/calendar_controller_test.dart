import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toit/controllers/calendar_controller.dart';
import 'package:toit/core/utils/calendar_utils.dart';
import 'package:toit/models/calendar/calendar_event.dart';
import 'package:toit/services/schedule_api_client.dart';

class _StubScheduleApiClient extends ScheduleApiClient {
  _StubScheduleApiClient(this.eventsByMonth);

  final Map<String, List<CalendarEvent>> eventsByMonth;
  int searchCallCount = 0;

  @override
  Future<List<CalendarEvent>> searchSchedules({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    searchCallCount++;
    for (final entry in eventsByMonth.entries) {
      final parts = entry.key.split('-');
      final month = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      final days = CalendarUtils.getDaysInMonth(month);
      if (days.first == startDate && days.last == endDate) {
        return entry.value;
      }
    }
    return const <CalendarEvent>[];
  }
}

CalendarEvent _event({
  required String id,
  required String startAt,
  required String endAt,
}) {
  return CalendarEvent(id: id, title: id, startAt: startAt, endAt: endAt);
}

void main() {
  group('CalendarController cache updates', () {
    test('삭제한 일정은 같은 달 캐시 히트 후에도 다시 나타나지 않는다', () async {
      final targetMonth = DateTime(2026, 7);
      final deleted = _event(
        id: '42',
        startAt: '2026-07-15',
        endAt: '2026-07-15',
      );
      final kept = _event(id: '7', startAt: '2026-07-16', endAt: '2026-07-16');
      final apiClient = _StubScheduleApiClient({
        '2026-07': [deleted, kept],
      });
      final container = ProviderContainer(
        overrides: [scheduleApiClientProvider.overrideWithValue(apiClient)],
      );
      addTearDown(container.dispose);

      final controller = container.read(calendarProvider.notifier);
      await controller.loadEvents(targetMonth);
      expect(container.read(calendarProvider).events, [deleted, kept]);

      controller.removeEvent(deleted.id);
      expect(container.read(calendarProvider).events, [kept]);

      final callsAfterDelete = apiClient.searchCallCount;
      await controller.loadEvents(targetMonth);
      expect(container.read(calendarProvider).events, [kept]);
      expect(apiClient.searchCallCount, callsAfterDelete);
    });

    test('수정한 일정은 같은 달 캐시에도 반영된다', () async {
      final targetMonth = DateTime(2026, 7);
      final original = _event(
        id: '42',
        startAt: '2026-07-15',
        endAt: '2026-07-15',
      );
      final updated = original.copyWith(title: 'updated title');
      final apiClient = _StubScheduleApiClient({
        '2026-07': [original],
      });
      final container = ProviderContainer(
        overrides: [scheduleApiClientProvider.overrideWithValue(apiClient)],
      );
      addTearDown(container.dispose);

      final controller = container.read(calendarProvider.notifier);
      await controller.loadEvents(targetMonth);

      controller.updateEvent(updated);
      expect(
        container.read(calendarProvider).events.single.title,
        'updated title',
      );

      final callsAfterUpdate = apiClient.searchCallCount;
      await controller.loadEvents(targetMonth);
      expect(
        container.read(calendarProvider).events.single.title,
        'updated title',
      );
      expect(apiClient.searchCallCount, callsAfterUpdate);
    });

    test('포커스 월이 바뀌어도 캐시된 다른 월 인덱스는 해당 월 일정으로 만든다', () async {
      final julyEvent = _event(
        id: 'july',
        startAt: '2026-07-15',
        endAt: '2026-07-15',
      );
      final augustEvent = _event(
        id: 'august',
        startAt: '2026-08-15',
        endAt: '2026-08-15',
      );
      final apiClient = _StubScheduleApiClient({
        '2026-07': [julyEvent],
        '2026-08': [augustEvent],
      });
      final container = ProviderContainer(
        overrides: [scheduleApiClientProvider.overrideWithValue(apiClient)],
      );
      addTearDown(container.dispose);

      final controller = container.read(calendarProvider.notifier);
      await controller.loadEvents(DateTime(2026, 7));
      await controller.loadEvents(DateTime(2026, 8));

      final julyIndex = container.read(eventIndexFamilyProvider('2026-07'));
      final augustIndex = container.read(eventIndexFamilyProvider('2026-08'));

      expect(julyIndex.getEventsForDay(DateTime(2026, 7, 15)), [julyEvent]);
      expect(augustIndex.getEventsForDay(DateTime(2026, 8, 15)), [augustEvent]);
    });
  });
}
