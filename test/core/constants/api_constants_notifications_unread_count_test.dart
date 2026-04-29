import 'package:flutter_test/flutter_test.dart';
import 'package:toit/core/constants/api_constants.dart';

void main() {
  test('notificationsUnreadCountEndpoint is unread count path', () {
    expect(
      ApiConstants.notificationsUnreadCountEndpoint,
      '/api/notifications/unread-count',
    );
  });
}
