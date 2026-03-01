import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API 관련 상수 정의
class ApiConstants {
  ApiConstants._();

  /// 서버 기본 URL (.env 파일에서 읽음)
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  /// 요청 타임아웃 (밀리초)
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;

  // 임시 사용자 ID (로그인 미구현)
  static const int defaultUsersId = 2;

  // ─── 엔드포인트 ───
  static const String homePageEndpoint = '/page/home';
  static const String foldersEndpoint = '/folders';
  static const String pageItemsEndpoint = '/page/items';

  /// 자료 링크 추가 (POST)
  static const String linksEndpoint = '/links';
}
