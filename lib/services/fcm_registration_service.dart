import 'dart:developer' show log;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

// TODO(FCM-콘솔정리): 릴리스 전 삭제 — 아래 logFcm*·_logFcm* 및 호출부·dart:developer log
void logFcmTokenSnapshot(String context, String? token) {
  final text = (token == null || token.isEmpty)
      ? '[FCM] 토큰 수신 ($context): 없음'
      : '[FCM] 토큰 수신 ($context): $token';
  debugPrint(text);
  log(text, name: 'FCM');
}

void _logFcmPostStart(String path, String token) {
  final text = '[FCM] POST 요청 시작 $path fcmToken=$token';
  debugPrint(text);
  log(text, name: 'FCM');
}

void _logFcmPostSuccess(String path) {
  const text = '[FCM] POST 요청 완료';
  debugPrint('$text $path');
  log('$text $path', name: 'FCM');
}

void _logFcmPostFailure(String path, Object e, StackTrace st) {
  final text = '[FCM] POST 요청 실패 $path: $e';
  debugPrint('$text\n$st');
  log(text, name: 'FCM', error: e, stackTrace: st);
}

/// 로그인된 세션에서만 호출한다. 사용자 식별은 [ApiClient]의
/// `Authorization: Bearer`로 처리된다.
///
/// [promptForPermission]이 true이면 OS 알림 권한 요청을 시도할 수 있다.
/// 로그인 직후·세션 복구에는 true, 토큰 갱신·앱 포그라운드 복귀에는 false가
/// 일반적이다.
class FcmRegistrationService {
  FcmRegistrationService(this._apiClient);

  final ApiClient _apiClient;

  static const String _fcmTokenKey = 'fcmToken';
  static const int _apnsTokenRetryCount = 8;
  static const Duration _apnsTokenRetryDelay = Duration(milliseconds: 300);

  /// 알림이 허용된 경우에만 [POST /fcm]으로 토큰을 등록한다.
  ///
  /// [fcmToken]이 있으면 `getToken()`을 생략한다 (`onTokenRefresh` 등).
  Future<void> syncServerRegistration({
    bool promptForPermission = true,
    String? fcmToken,
  }) async {
    try {
      final NotificationSettings settings;
      if (promptForPermission) {
        settings = await FirebaseMessaging.instance.requestPermission();
      } else {
        settings =
            await FirebaseMessaging.instance.getNotificationSettings();
      }
      if (!_isPushAllowed(settings.authorizationStatus)) {
        // TODO(FCM-콘솔정리): 릴리스 전 삭제
        debugPrint(
          '[FcmRegistration] 알림 미허용, 서버 등록 생략',
        );
        return;
      }
      await _postFcmToken(fcmToken);
    } catch (e, st) {
      // TODO(FCM-콘솔정리): 릴리스 전 삭제
      debugPrint('[FcmRegistration] 서버 FCM 등록 실패: $e\n$st');
    }
  }

  static bool _isPushAllowed(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<void> _postFcmToken(String? fcmToken) async {
    final token = fcmToken ?? await _resolveFcmToken();
    logFcmTokenSnapshot(
      fcmToken != null ? 'onTokenRefresh·전달' : 'getToken()',
      token,
    );
    if (token == null || token.isEmpty) {
      const msg = '[FCM] 토큰 없음 — POST 생략';
      // TODO(FCM-콘솔정리): 릴리스 전 삭제
      debugPrint(msg);
      log(msg, name: 'FCM');
      return;
    }
    final path = ApiConstants.fcmEndpoint;
    _logFcmPostStart(path, token);
    try {
      await _apiClient.post<void>(
        path,
        data: <String, dynamic>{_fcmTokenKey: token},
      );
      _logFcmPostSuccess(path);
    } catch (e, st) {
      _logFcmPostFailure(path, e, st);
    }
  }

  Future<String?> _resolveFcmToken() async {
    if (_isApplePlatform) {
      await _waitUntilApnsTokenReady();
    }
    return FirebaseMessaging.instance.getToken();
  }

  bool get _isApplePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> _waitUntilApnsTokenReady() async {
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null && apnsToken.isNotEmpty) {
      return;
    }
    for (var i = 0; i < _apnsTokenRetryCount; i++) {
      await Future<void>.delayed(_apnsTokenRetryDelay);
      final retriedToken = await FirebaseMessaging.instance.getAPNSToken();
      if (retriedToken != null && retriedToken.isNotEmpty) {
        return;
      }
    }
  }
}

/// [FcmRegistrationService] Provider
final fcmRegistrationServiceProvider =
    Provider<FcmRegistrationService>((ref) {
  return FcmRegistrationService(ref.watch(apiClientProvider));
});
