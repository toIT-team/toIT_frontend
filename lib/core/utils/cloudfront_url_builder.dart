import '../constants/api_constants.dart';

/// CloudFront 이미지 URL 생성 유틸
///
/// 서버는 objectKey만 내려주고, Flutter가 화면 크기에 맞춰 URL을 생성한다.
/// 캐시 효율을 위해 허용된 width(400/800/1200)만 사용한다.

/// 화면 표시 너비를 허용된 리사이즈 width로 매핑한다.
int selectImageWidth(double displayWidth) {
  if (displayWidth <= 400) return 400;
  if (displayWidth <= 800) return 800;
  return 1200;
}

/// 리사이즈 이미지 URL 생성
/// 예: https://{cdn}/resize/400/users/2/images/abc.jpg
String buildResizeImageUrl({
  required String objectKey,
  required double displayWidth,
}) {
  final width = selectImageWidth(displayWidth);
  return '${ApiConstants.cdnBaseUrl}/resize/$width/$objectKey';
}

/// 원본 이미지/파일 URL 생성 (다운로드·공유용)
/// 예: https://{cdn}/users/2/images/abc.jpg
String buildOriginalUrl(String objectKey) {
  return '${ApiConstants.cdnBaseUrl}/$objectKey';
}
