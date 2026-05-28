import 'package:flutter_test/flutter_test.dart';
import 'package:toit/core/deep_link/toit_deep_link.dart';

void main() {
  group('ToitDeepLink.parseScheduleId', () {
    test('쿼리 id를 정수로 반환한다', () {
      expect(ToitDeepLink.parseScheduleId('toit://schedule?id=42'), 42);
    });

    test('id가 없으면 null', () {
      expect(ToitDeepLink.parseScheduleId('toit://schedule'), isNull);
    });

    test('호스트가 다르면 null', () {
      expect(ToitDeepLink.parseScheduleId('toit://folder?id=1'), isNull);
    });
  });

  group('ToitDeepLink.extractUrlFromFcmData', () {
    test('url 키에서 toit 링크 추출', () {
      expect(
        ToitDeepLink.extractUrlFromFcmData({'url': 'toit://schedule?id=7'}),
        'toit://schedule?id=7',
      );
    });

    test('link 키 폴백', () {
      expect(
        ToitDeepLink.extractUrlFromFcmData({'link': 'toit://schedule?id=8'}),
        'toit://schedule?id=8',
      );
    });

    test('toit가 아니면 null', () {
      expect(
        ToitDeepLink.extractUrlFromFcmData({'url': 'https://example.com/x'}),
        isNull,
      );
    });
  });
}
