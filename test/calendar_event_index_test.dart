import 'package:flutter_test/flutter_test.dart';
import 'package:toit/controllers/calendar_controller.dart';
import 'package:toit/core/utils/calendar_utils.dart';
import 'package:toit/models/calendar/calendar_event.dart';

CalendarEvent _event({
  required String id,
  required String startAt,
  required String endAt,
}) {
  return CalendarEvent(
    id: id,
    title: id,
    startAt: startAt,
    endAt: endAt,
  );
}

void main() {
  group('CalendarEventIndex.splitContiguousDayIndices', () {
    test('인접하지 않은 열은 별도 구간으로 분리한다', () {
      expect(
        CalendarEventIndex.splitContiguousDayIndices([0, 2, 3, 4, 5, 6]),
        [
          [0],
          [2, 3, 4, 5, 6],
        ],
      );
    });
  });

  group('CalendarEventIndex.build', () {
    test('월요일에 끝난 슬롯 2를 화요일 일정이 재사용한다', () {
      // 2025-06-08(일) ~ 2025-06-15(일) 주
      const month = '2025-06-01';
      final focusedMonth = DateTime.parse(month);
      final days = CalendarUtils.getDaysInMonth(focusedMonth);
      final weekStart = DateTime.parse('2025-06-08');
      const tuesdayCol = 2;

      final events = [
        _event(id: 'ea', startAt: '2025-06-08', endAt: '2025-06-14'),
        _event(id: 'eb', startAt: '2025-06-08', endAt: '2025-06-14'),
        _event(id: 'e3', startAt: '2025-06-08', endAt: '2025-06-09'),
        _event(id: 'e4', startAt: '2025-06-10', endAt: '2025-06-15'),
      ];

      final index = CalendarEventIndex.build(focusedMonth, events);

      expect(index.getSlotForDay('e3', weekStart, 1), 2);
      expect(
        index.getSlotForDay('e4', weekStart, tuesdayCol),
        2,
        reason: 'e3가 월요일에 끝나도 화~토 구간은 슬롯 2 재사용',
      );
    });

    test('숨겨졌던 일정이 빈 줄이 생기면 그 줄로 등장하고 점프하지 않는다', () {
      // 2026-05-03(일)~09(토) 주 — 스크린샷과 동일 패턴
      // 시작일: blue/pink/green = 5/1, purple = 5/2 → 우선순위 blue,pink,green,purple
      final focusedMonth = DateTime.parse('2026-05-01');
      final weekStart = DateTime.parse('2026-05-03');

      final events = [
        _event(id: 'blue', startAt: '2026-05-01', endAt: '2026-05-31'),
        _event(id: 'pink', startAt: '2026-05-01', endAt: '2026-05-08'),
        _event(id: 'green', startAt: '2026-05-01', endAt: '2026-05-04'),
        _event(id: 'purple', startAt: '2026-05-02', endAt: '2026-05-31'),
      ];

      final index = CalendarEventIndex.build(focusedMonth, events);

      // blue(0) pink(1) green(2) 가 5/3~5/4 점유 → 보라는 그 구간 숨김(슬롯 3)
      expect(index.getSlotForDay('purple', weekStart, 0), 3);
      // 5/5(화)부터 초록이 끝나 슬롯 2가 비면 보라가 그 줄로 등장
      expect(index.getSlotForDay('purple', weekStart, 2), 2);
      // 5/9(토) 분홍이 끝나 슬롯 1이 비어도, 이미 보이는 보라는 슬롯 2 유지(점프 금지)
      expect(
        index.getSlotForDay('purple', weekStart, 6),
        2,
        reason: '보이는 줄은 더 낮은 줄이 열려도 점프하지 않는다',
      );
    });

    test('늦게 시작한 일정이 기존 일정의 슬롯을 밀어내지 않는다', () {
      // 2026-05-10(일)~16(토) 주, 13일에 새 일정 생성
      final focusedMonth = DateTime.parse('2026-05-01');
      final weekStart = DateTime.parse('2026-05-10');

      final events = [
        _event(id: 'blue', startAt: '2026-05-01', endAt: '2026-05-31'),
        _event(id: 'newbie', startAt: '2026-05-13', endAt: '2026-05-13'),
      ];

      final index = CalendarEventIndex.build(focusedMonth, events);

      expect(
        index.getSlotForDay('blue', weekStart, 0),
        0,
        reason: '먼저 시작한 파랑이 슬롯 0 유지',
      );
      expect(
        index.getSlotForDay('newbie', weekStart, 3),
        greaterThan(0),
        reason: '늦게 시작한 새 일정은 슬롯 0을 빼앗지 않는다',
      );
    });

    test('같은 일정 구성이 유지되면 슬롯도 안정적이다', () {
      final focusedMonth = DateTime.parse('2026-05-01');
      final week1 = DateTime.parse('2026-05-03');
      final week2 = DateTime.parse('2026-05-10');

      final events = [
        _event(id: 'blue', startAt: '2026-05-03', endAt: '2026-05-31'),
        _event(id: 'purple', startAt: '2026-05-04', endAt: '2026-05-31'),
      ];

      final index = CalendarEventIndex.build(focusedMonth, events);

      expect(index.getSlotForDay('blue', week1, 0), 0);
      expect(index.getSlotForDay('blue', week2, 0), 0);
      expect(index.getSlotForDay('purple', week1, 1), 1);
      expect(index.getSlotForDay('purple', week2, 0), 1);
    });

    test('위 슬롯을 막던 일정이 끝나면 다음 주에 위로 올라온다', () {
      // 1주차: green(짧음)이 슬롯1 점유로 purple이 슬롯2로 등장
      // 2주차: green 종료 → purple은 슬롯1로 올라와야 함 (빈 줄 방지)
      final focusedMonth = DateTime.parse('2026-05-01');
      final week2 = DateTime.parse('2026-05-10');

      final events = [
        _event(id: 'blue', startAt: '2026-05-01', endAt: '2026-05-31'),
        _event(id: 'green', startAt: '2026-05-01', endAt: '2026-05-08'),
        _event(id: 'pink', startAt: '2026-05-01', endAt: '2026-05-08'),
        _event(id: 'purple', startAt: '2026-05-02', endAt: '2026-05-31'),
      ];

      final index = CalendarEventIndex.build(focusedMonth, events);

      expect(
        index.getSlotForDay('purple', week2, 0),
        1,
        reason: 'green/pink 종료 후 2주차에서 purple은 슬롯 1로 압축',
      );
    });
  });
}

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
