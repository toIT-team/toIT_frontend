import '../constants/api_constants.dart';

/// `toit://` 커스텀 스킴 딥링크 (FCM·iOS MethodChannel 공통)
///
/// 백엔드 FCM 페이로드 예:
/// `data: { "url": "toit://schedule?id=42" }`,
/// `data: { "url": "toit://feedback?tab=history" }` 또는 `link` 키 동일 형식
class ToitDeepLink {
  ToitDeepLink._();

  static const String folderHost = 'folder';
  static const String scheduleHost = 'schedule';
  static const String feedbackHost = 'feedback';

  /// FCM `data` 맵에서 딥링크 문자열을 꺼낼 때 사용하는 키 (둘 중 하나)
  static const String fcmDataUrlKey = 'url';
  static const String fcmDataLinkKey = 'link';
  static const String fcmDataNotificationIdKey = 'notificationId';
  static const String fcmDataNotificationIdAltKey = 'notification_id';
  static const String fcmDataIdKey = 'id';

  /// `toit://` 가 아니면 null
  static String? extractUrlFromFcmData(Map<String, dynamic> data) {
    final raw = data[fcmDataUrlKey] ?? data[fcmDataLinkKey];
    if (raw == null) return null;
    final url = raw is String ? raw : raw.toString();
    final prefix = '${ApiConstants.authCallbackScheme}://';
    if (!url.startsWith(prefix)) return null;
    return url;
  }

  /// FCM `data` 맵에서 알림 ID를 꺼낸다. (없거나 파싱 실패 시 null)
  static int? extractNotificationIdFromFcmData(Map<String, dynamic> data) {
    final raw =
        data[fcmDataNotificationIdKey] ??
        data[fcmDataNotificationIdAltKey] ??
        data[fcmDataIdKey];
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    final parsed = int.tryParse(raw.toString().trim());
    return parsed;
  }

  /// 예: `toit://schedule?id=42`
  static int? parseScheduleId(String urlString) {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return null;
    if (uri.scheme != ApiConstants.authCallbackScheme) return null;
    if (uri.host != scheduleHost) return null;
    return int.tryParse(uri.queryParameters['id'] ?? '');
  }

  /// 예: `toit://feedback?tab=history`
  /// - `write` 탭: 0
  /// - 기본/`history` 탭: 1
  static int? parseFeedbackTabIndex(String urlString) {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return null;
    if (uri.scheme != ApiConstants.authCallbackScheme) return null;
    if (uri.host != feedbackHost) return null;
    final tab = (uri.queryParameters['tab'] ?? '').toLowerCase();
    return tab == 'write' ? 0 : 1;
  }
}
