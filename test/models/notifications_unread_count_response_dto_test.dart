import 'package:flutter_test/flutter_test.dart';
import 'package:toit/models/dto/notifications_unread_count_response_dto.dart';

void main() {
  group('NotificationsUnreadCountResponseDto', () {
    test('최상위 unreadCount를 파싱한다', () {
      final dto = NotificationsUnreadCountResponseDto.fromJson(
        <String, dynamic>{'unreadCount': 7},
      );
      expect(dto.unreadCount, 7);
    });

    test('data 내부 unreadCount 문자열도 파싱한다', () {
      final dto = NotificationsUnreadCountResponseDto.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{'unreadCount': '12'},
        },
      );
      expect(dto.unreadCount, 12);
    });

    test('음수 unreadCount는 0으로 보정한다', () {
      final dto = NotificationsUnreadCountResponseDto.fromJson(
        <String, dynamic>{'unreadCount': -4},
      );
      expect(dto.unreadCount, 0);
    });
  });
}
