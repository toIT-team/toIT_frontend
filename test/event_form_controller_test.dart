import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toit/controllers/event_form_controller.dart';
import 'package:toit/core/constants/alarm_constants.dart';
import 'package:toit/core/constants/event_color_tokens.dart';
import 'package:toit/models/schedule/schedule_response.dart';

void main() {
  group('EventFormController', () {
    test('상세 응답의 일정 색상을 수정 폼에 반영한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(eventFormProvider.notifier)
          .initWithScheduleDetail(
            const ScheduleDetailResponse(
              schedulesId: 42,
              title: '기존 일정',
              startDate: '2026-07-29',
              endDate: '2026-07-29',
              appColor: 'purple500',
            ),
          );

      expect(
        container.read(eventFormProvider).appColorToken,
        EventColorToken.purple500,
      );
    });

    test('같은 날짜에서 시작 시간과 종료 시간이 같아도 유효하다', () {
      final state = EventFormState(
        title: '동시 일정',
        startDate: DateTime(2026, 7, 31),
        endDate: DateTime(2026, 7, 31),
        startTime: '09:00',
        endTime: '09:00',
        timeSetting: true,
      );

      expect(state.isDateTimeRangeValid, isTrue);
    });

    test('시작 시간을 설정하면 종료 시간도 같은 시간으로 맞춘다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(eventFormProvider.notifier);
      controller.toggleTimeSetting(true);
      controller.updateStartTime('14:30');

      final state = container.read(eventFormProvider);
      expect(state.startTime, '14:30');
      expect(state.endTime, '14:30');
    });

    test('알림 직접 설정은 최대 1주 전으로 제한한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(eventFormProvider.notifier).updateAlarm(60 * 24 * 30);

      expect(
        container.read(eventFormProvider).alarmMinutes,
        AlarmUtils.maxOffsetMinutes,
      );
    });

    test('상세 응답의 긴 알림 값도 최대 1주 전으로 보정한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(eventFormProvider.notifier)
          .initWithScheduleDetail(
            const ScheduleDetailResponse(
              schedulesId: 42,
              title: '기존 일정',
              startDate: '2026-07-29',
              endDate: '2026-07-29',
              alarmState: true,
              alarmOffsetMinutes: 60 * 24 * 30,
            ),
          );

      expect(
        container.read(eventFormProvider).alarmMinutes,
        AlarmUtils.maxOffsetMinutes,
      );
    });
  });
}
