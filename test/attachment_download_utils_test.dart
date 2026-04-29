import 'package:flutter_test/flutter_test.dart';
import 'package:toit/core/utils/attachment_download_utils.dart';

void main() {
  group('normalizeAttachmentExtensionField', () {
    test('MIME text/plain → txt', () {
      expect(normalizeAttachmentExtensionField('text/plain'), 'txt');
    });

    test('빈 문자열', () {
      expect(normalizeAttachmentExtensionField(''), '');
      expect(normalizeAttachmentExtensionField('   '), '');
    });
  });

  group('ensureDownloadFileNameHasExtension', () {
    test('이미 .txt 인 파일명은 MIME을 덧붙이지 않는다', () {
      expect(
        ensureDownloadFileNameHasExtension('매크.txt', 'text/plain'),
        '매크.txt',
      );
    });

    test('확장자 없을 때 text/plain → .txt', () {
      expect(
        ensureDownloadFileNameHasExtension('memo', 'text/plain'),
        'memo.txt',
      );
    });
  });
}
