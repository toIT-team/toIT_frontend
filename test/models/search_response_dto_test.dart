import 'package:flutter_test/flutter_test.dart';
import 'package:poj_todo/models/dto/search_response_dto.dart';

void main() {
  group('SearchResponseDto', () {
    test('통합 검색 JSON에서 신규 필드 파싱', () {
      final dto = SearchResponseDto.fromJson(<String, dynamic>{
        'folders': [],
        'schedules': [],
        'links': [
          <String, dynamic>{
            'linksId': 1,
            'foldersId': 2,
            'usersId': 3,
            'linksName': '예시',
            'linksUrl': 'https://example.com',
            'linksThumbnail': '',
            'textContent': '',
            'createdAt': '2026-04-19T13:42:23.999Z',
            'foldersName': '업무',
            'dayOfWeek': '토',
          },
        ],
        'texts': [
          <String, dynamic>{
            'textsId': 4,
            'usersId': 3,
            'foldersId': 2,
            'textContent': '메모',
            'createdAt': '2026-04-19T13:42:23.999Z',
            'foldersName': '업무',
            'dayOfWeek': '토',
          },
        ],
        'files': [
          <String, dynamic>{
            'attachmentsId': 5,
            'usersId': 3,
            'foldersId': 2,
            'attachmentsType': 'IMAGE',
            'objectKey': 'k',
            'presignedUrl': 'https://x',
            'attachmentsExtension': 'png',
            'attachmentsSize': '1.5',
            'fileName': 'a.png',
            'createdAt': '2026-04-19T13:42:23.999Z',
            'foldersName': '업무',
            'dayOfWeek': '토',
          },
        ],
      });

      expect(dto.links.single.foldersName, '업무');
      expect(dto.links.single.dayOfWeek, '토');
      expect(dto.texts.single.foldersName, '업무');
      expect(dto.files.single.attachmentsSize, closeTo(1.5, 0.001));
      expect(dto.files.single.attachmentsType, 'IMAGE');
      expect(dto.files.single.foldersName, '업무');
    });
  });
}
