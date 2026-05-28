import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API 관련 상수 정의
/// baseUrl은 .env의 `API_BASE_URL`에서 로드 (git에 노출되지 않음)
class ApiConstants {
  ApiConstants._();

  /// 서버 기본 URL (`.env`의 `API_BASE_URL`, 없으면 로컬 개발 기본값)
  static String get baseUrl {
    final raw = dotenv.maybeGet('API_BASE_URL');
    final trimmed = raw?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return 'http://localhost:8080';
  }

  /// 요청 타임아웃 (밀리초)
  static const int connectTimeout = 60000;
  static const int receiveTimeout = 60000;

  // /// 개발용 고정 사용자 ID — 로그인 구현 완료로 비활성화
  // /// JWT의 sub 값으로 대체됨 (authProvider.userId)
  // static const int devUserId = 2;

  // ─── 엔드포인트 ───
  static const String homePageEndpoint = '/page/home';
  static const String foldersEndpoint = '/folders';
  static const String foldersFavoriteEndpoint = '/folders/favorite';
  static const String pageItemsEndpoint = '/page/items';
  static const String myPageEndpoint = '/page/my';
  static const String storageUsageEndpoint = '/api/storage/usage';

  /// 통합 검색 (GET /page/search)
  static const String searchEndpoint = '/page/search';

  /// 알림 목록 (GET /page/notifications)
  static const String notificationsEndpoint = '/page/notifications';

  /// 알림 읽음 (PATCH /api/notifications/{id}/read)
  static String notificationReadPath(int notificationId) =>
      '/api/notifications/$notificationId/read';

  /// 미읽음 알림 개수 (GET /api/notifications/unread-count)
  static const String notificationsUnreadCountEndpoint =
      '/api/notifications/unread-count';

  /// 자료 링크 추가 (POST)
  static const String linksEndpoint = '/links';

  /// 링크 미리보기 추출 (POST)
  static const String linksPreviewEndpoint = '/links/preview';

  /// 자료 링크 수정 (PATCH, 제목·설명)
  static const String linksUpdateEndpoint = '/links/update';

  /// 자료 텍스트(노트) 추가 (POST)
  static const String textsEndpoint = '/texts';

  /// 자료 텍스트(노트) 수정 (PATCH)
  static const String textsUpdateEndpoint = '/texts/update';

  /// 자료 파일 추가 (POST, multipart) - legacy
  static const String attachmentsFilesEndpoint = '/attachments/files';

  /// 자료 이미지 추가 (POST, multipart) - legacy
  static const String attachmentsImagesEndpoint = '/attachments/images';

  /// S3 업로드용 presigned URL 발급 (POST)
  static const String attachmentsPresignEndpoint = '/attachments/presign';

  /// S3 업로드 완료 후 DB 저장 확정 (POST)
  static const String attachmentsConfirmEndpoint = '/attachments/confirm';

  /// 자료 파일 이름 수정 (PATCH)
  static const String attachmentsUpdateEndpoint = '/attachments/update';

  /// 자료 파일/이미지 보관함 이동 (PATCH)
  static const String attachmentsEndpoint = '/attachments';
  static const String usersNameEndpoint = '/users/name';
  static const String usersWithdrawEndpoint = '/users/withdraw';

  /// 앱 전체 알림 on/off (PATCH, body: { appAlarmEnabled: bool })
  static const String usersAlarmSettingEndpoint = '/users/alarmSetting';
  static const String feedbackEndpoint = '/api/feedback';
  static const String myFeedbackEndpoint = '/api/feedback/my';

  // ─── 인증 ───

  /// 카카오 소셜 로그인 (GET → 브라우저로 열어 OAuth 진행)
  static const String kakaoLoginEndpoint = '/api/auth/kakao/login';

  static const String appleLoginEndpoint = '/api/auth/apple/login';
  static const String restoreAccountEndpoint = '/api/auth/restore';

  /// 액세스 토큰 재발급 (POST, body: { refreshToken })
  /// 응답: { accessToken: string }
  static const String reissueEndpoint = '/api/auth/reissue';

  /// FCM 기기 토큰 등록 (POST, body: { fcmToken })
  static const String fcmEndpoint = '/fcm';

  /// 앱 복귀 딥링크 스킴
  static const String authCallbackScheme = 'toit';

  /// 앱 복귀 딥링크 전체 URL
  static const String authCallbackUrl = 'toit://auth/callback';
}
