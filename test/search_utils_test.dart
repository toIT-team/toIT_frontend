import 'package:flutter_test/flutter_test.dart';
import 'package:toit/core/utils/search_utils.dart';

void main() {
  group('SearchUtils.composeSearchSubtitle', () {
    test('메타 없으면 유형 태그만 반환', () {
      expect(SearchUtils.composeSearchSubtitle(typeTag: '링크'), '링크');
    });

    test('보관함명·ISO 날짜 조합', () {
      expect(
        SearchUtils.composeSearchSubtitle(
          typeTag: '링크',
          foldersName: '업무',
          isoTimestamp: '2026-04-19T13:42:23.999Z',
        ),
        contains('링크'),
      );
      expect(
        SearchUtils.composeSearchSubtitle(
          typeTag: '링크',
          foldersName: '업무',
          isoTimestamp: '2026-04-19T13:42:23.999Z',
        ),
        contains('업무'),
      );
    });

    test('달력 날짜 문자열 사용 시 ISO보다 우선하지 않음 — iso가 있으면 iso만', () {
      expect(
        SearchUtils.composeSearchSubtitle(
          typeTag: '일정',
          foldersName: '개인',
          isoTimestamp: '2026-04-19T13:42:23.999Z',
          calendarDate: '2026-04-20',
        ),
        contains('2026'),
      );
    });
  });
}
