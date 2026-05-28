import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toit/core/utils/schedule_range_display_utils.dart';
import 'package:toit/models/calendar/calendar_event.dart';

void main() {
  group('ScheduleRangeDisplayUtils', () {
    test('formatKoreanClock handles HH:mm:ss', () {
      expect(
        ScheduleRangeDisplayUtils.formatKoreanClock('09:00:00'),
        '오전 9:00',
      );
      expect(
        ScheduleRangeDisplayUtils.formatKoreanClock('14:30:00'),
        '오후 2:30',
      );
    });

    test('multi-day with time uses tilde and spaces', () {
      final event = CalendarEvent(
        id: '1',
        title: 't',
        startAt: '2026-12-24',
        endAt: '2026-12-25',
        startTime: '09:00',
        endTime: '09:00',
        timeSetting: true,
        color: Colors.blue,
      );
      expect(
        ScheduleRangeDisplayUtils.formatEventRangeLine(event),
        '12월 24일(목) 오전 9:00~ 12월 25일(금) 오전 9:00',
      );
    });

    test('same day with time shows time only', () {
      final event = CalendarEvent(
        id: '1',
        title: 't',
        startAt: '2026-12-24',
        endAt: '2026-12-24',
        startTime: '09:00',
        endTime: '17:00',
        timeSetting: true,
        color: Colors.blue,
      );
      expect(
        ScheduleRangeDisplayUtils.formatEventRangeLine(event),
        '오전 9:00~ 오후 5:00',
      );
    });

    test('shows only time when end date is missing', () {
      final event = CalendarEvent(
        id: '1',
        title: 't',
        startAt: '2026-12-24',
        endAt: '',
        startTime: '09:00',
        endTime: '17:00',
        timeSetting: true,
        color: Colors.blue,
      );
      expect(
        ScheduleRangeDisplayUtils.formatEventRangeLine(event),
        '오전 9:00~ 오후 5:00',
      );
    });

    test('shows only time when end date is literal null string', () {
      final event = CalendarEvent(
        id: '1',
        title: 't',
        startAt: '2026-12-24',
        endAt: 'null',
        startTime: '09:00',
        endTime: '17:00',
        timeSetting: true,
        color: Colors.blue,
      );
      expect(
        ScheduleRangeDisplayUtils.formatEventRangeLine(event),
        '오전 9:00~ 오후 5:00',
      );
    });

    test('all-day single day', () {
      final event = CalendarEvent(
        id: '1',
        title: 't',
        startAt: '2026-12-24',
        endAt: '2026-12-24',
        timeSetting: false,
        color: Colors.blue,
      );
      expect(ScheduleRangeDisplayUtils.formatEventRangeLine(event), '하루 종일');
    });

    test('all-day multi day', () {
      final event = CalendarEvent(
        id: '1',
        title: 't',
        startAt: '2026-12-24',
        endAt: '2026-12-25',
        timeSetting: false,
        color: Colors.blue,
      );
      expect(
        ScheduleRangeDisplayUtils.formatEventRangeLine(event),
        '12월 24일(목) ~ 12월 25일(금)',
      );
    });
  });
}
