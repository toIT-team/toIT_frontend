import 'package:flutter_test/flutter_test.dart';
import 'package:toit/models/dto/notifications_page_response_dto.dart';

void main() {
  group('NotificationsPageResponseDto', () {
    test('notifications 배열에서 유효 항목만 순서대로 파싱한다', () {
      final dto = NotificationsPageResponseDto.fromJson(<String, dynamic>{
        'notifications': <dynamic>[
          <String, dynamic>{
            'notificationId': 1,
            'title': '일정 알림',
            'type': 'SCHEDULE',
            'deeplink': 'toit://schedule?id=9',
            'sentAt': '2026-04-24T11:47:10.991Z',
            'isRead': false,
          },
          <String, dynamic>{
            'notificationId': 3,
            'title': '공지',
            'type': 'NOTICE',
            'deeplink': 'https://example.com/n',
            'sentAt': '2026-01-02T00:00:00.000Z',
            'isRead': true,
          },
        ],
      });

      expect(dto.notifications.length, 2);
      expect(dto.notifications[0].type, NotificationType.schedule);
      expect(dto.notifications[0].isRead, isFalse);
      expect(dto.notifications[0].sentAt.toUtc().year, 2026);
      expect(dto.notifications[1].type, NotificationType.notice);
    });

    test('알 수 없는 type 한 건은 건너뛰고 나머지는 유지한다', () {
      final dto = NotificationsPageResponseDto.fromJson(<String, dynamic>{
        'notifications': <dynamic>[
          <String, dynamic>{
            'notificationId': 1,
            'title': 'a',
            'type': 'SCHEDULE',
            'deeplink': '',
            'sentAt': '2026-04-24T10:00:00.000Z',
            'isRead': true,
          },
          <String, dynamic>{
            'notificationId': 99,
            'title': 'b',
            'type': 'UNKNOWN',
            'deeplink': '',
            'sentAt': '2026-04-24T11:00:00.000Z',
            'isRead': true,
          },
          <String, dynamic>{
            'notificationId': 3,
            'title': 'c',
            'type': 'NOTICE',
            'deeplink': '',
            'sentAt': '2026-04-24T12:00:00.000Z',
            'isRead': false,
          },
        ],
      });
      expect(dto.notifications.length, 2);
      expect(dto.notifications[0].notificationId, 1);
      expect(dto.notifications[1].notificationId, 3);
    });

    test('sentAt 없으면 fromJson이 FormatException', () {
      expect(
        () => NotificationItemDto.fromJson(<String, dynamic>{
          'notificationId': 0,
          'title': 't',
          'type': 'NOTICE',
          'deeplink': '',
          'isRead': true,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('sentAt 없는 항목은 페이지 파싱 시 건너뜀', () {
      final dto = NotificationsPageResponseDto.fromJson(<String, dynamic>{
        'notifications': <dynamic>[
          <String, dynamic>{
            'notificationId': 1,
            'title': '유효',
            'type': 'SCHEDULE',
            'deeplink': '',
            'sentAt': '2026-04-24T12:00:00.000Z',
            'isRead': true,
          },
          <String, dynamic>{
            'notificationId': 2,
            'title': '무효',
            'type': 'SCHEDULE',
            'deeplink': '',
            'isRead': true,
          },
        ],
      });
      expect(dto.notifications.length, 1);
      expect(dto.notifications[0].notificationId, 1);
    });

    test('notifications 키가 없으면 빈 목록', () {
      final dto = NotificationsPageResponseDto.fromJson(<String, dynamic>{});
      expect(dto.notifications, isEmpty);
    });

    test('NotificationItemDto copyWith로 isRead만 변경', () {
      final a = NotificationItemDto.fromJson(<String, dynamic>{
        'notificationId': 1,
        'title': 't',
        'type': 'NOTICE',
        'deeplink': '',
        'sentAt': '2026-04-24T10:00:00.000Z',
        'isRead': false,
      });
      final b = a.copyWith(isRead: true);
      expect(a.isRead, isFalse);
      expect(b.isRead, isTrue);
      expect(b.title, a.title);
    });
  });

  group('NotificationType', () {
    test('tryParseApi는 FEEDBACK_REPLY를 반환한다', () {
      expect(
        NotificationType.tryParseApi('FEEDBACK_REPLY'),
        NotificationType.feedbackReply,
      );
    });

    test('missingDeeplinkBodyKo는 유형별 존재하지 않음 안내', () {
      expect(NotificationType.schedule.missingDeeplinkBodyKo, contains('일정'));
      expect(
        NotificationType.feedbackReply.missingDeeplinkBodyKo,
        contains('문의'),
      );
      expect(NotificationType.notice.missingDeeplinkBodyKo, contains('공지'));
      for (final t in NotificationType.values) {
        expect(t.missingDeeplinkBodyKo, contains('존재하지 않습니다'));
      }
    });
  });
}
