import 'package:flutter_test/flutter_test.dart';
import 'package:toit/core/constants/api_constants.dart';

void main() {
  test('usersAlarmSettingEndpoint is PATCH alarm setting path', () {
    expect(ApiConstants.usersAlarmSettingEndpoint, '/users/alarmSetting');
  });
}
