import 'package:flutter_test/flutter_test.dart';
import 'package:poj_todo/models/dto/notifications_page_response_dto.dart';

void main() {
  group('NotificationsPageResponseDto', () {
    test('notifications 배열을 파싱하고 알 수 없는 type은 건너뛴다', () {
      final dto = NotificationsPageResponseDto.fromJson(<String, dynamic>{
        'notifications': <dynamic>[
          <String, dynamic>{
            'notificationId': 1,
            'title': '일정 알림',
            'type': 'SCHEDULE',
            'deeplink': 'toit://schedule?id=9',
            'isRead': false,
          },
          <String, dynamic>{
            'notificationId': 2,
            'title': '무시',
            'type': 'UNKNOWN',
            'deeplink': '',
            'isRead': true,
          },
          <String, dynamic>{
            'notificationId': 3,
            'title': '공지',
            'type': 'NOTICE',
            'deeplink': 'https://example.com/n',
            'isRead': true,
          },
        ],
      });

      expect(dto.notifications.length, 2);
      expect(dto.notifications[0].type, NotificationType.schedule);
      expect(dto.notifications[0].isRead, isFalse);
      expect(dto.notifications[1].type, NotificationType.notice);
    });

    test('notifications 키가 없으면 빈 목록', () {
      final dto = NotificationsPageResponseDto.fromJson(<String, dynamic>{});
      expect(dto.notifications, isEmpty);
    });
  });

  group('NotificationType', () {
    test('tryParseApi는 FEEDBACK_REPLY를 반환한다', () {
      expect(
        NotificationType.tryParseApi('FEEDBACK_REPLY'),
        NotificationType.feedbackReply,
      );
    });
  });
}
