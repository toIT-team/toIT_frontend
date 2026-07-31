import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toit/controllers/event_form_controller.dart';
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
  });
}
