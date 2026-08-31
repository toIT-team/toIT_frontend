import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

/// 로그인된 세션에서만 호출한다. 사용자 식별은 [ApiClient]의
/// `Authorization: Bearer`로 처리된다.
///
/// [promptForPermission]이 true이면 OS 알림 권한 요청을 시도할 수 있다.
/// 권한이 거부되어도 FCM 기기 등록은 계속 시도한다.
class FcmRegistrationService {
  FcmRegistrationService(this._apiClient);

  final ApiClient _apiClient;

  static const int _apnsTokenRetryCount = 8;
  static const Duration _apnsTokenRetryDelay = Duration(milliseconds: 300);

  Future<void> syncServerRegistration({bool promptForPermission = true}) async {
    try {
      if (promptForPermission) {
        await _requestNotificationPermission();
      }
      await _postFcmDeviceRegistration();
    } catch (_) {}
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {
      return;
    }
  }

  Future<void> _postFcmDeviceRegistration() async {
    final registration = await _resolveFcmDeviceRegistration();
    if (registration == null) return;

    try {
      await _apiClient.post<void>(
        ApiConstants.fcmEndpoint,
        data: registration.toJson(),
      );
    } catch (_) {}
  }

  Future<FcmDeviceRegistration?> _resolveFcmDeviceRegistration() async {
    final platform = _resolveFcmPlatform();
    if (platform == null) return null;

    final token = await _resolveFcmToken();
    if (token == null || token.isEmpty) return null;

    final installationId = await FirebaseInstallations.instance.getId();
    if (installationId.isEmpty) return null;

    final osVersion = await _resolveOsVersion(platform);
    if (osVersion.isEmpty) return null;

    return FcmDeviceRegistration(
      installationId: installationId,
      fcmToken: token,
      platform: platform,
      osVersion: osVersion,
    );
  }

  Future<String?> _resolveFcmToken() async {
    if (_isApplePlatform) {
      await _waitUntilApnsTokenReady();
    }
    return FirebaseMessaging.instance.getToken();
  }

  FcmPlatform? _resolveFcmPlatform() {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => FcmPlatform.android,
      TargetPlatform.iOS => FcmPlatform.ios,
      _ => null,
    };
  }

  Future<String> _resolveOsVersion(FcmPlatform platform) async {
    final deviceInfo = DeviceInfoPlugin();
    switch (platform) {
      case FcmPlatform.android:
        final android = await deviceInfo.androidInfo;
        return android.version.release.trim();
      case FcmPlatform.ios:
        final ios = await deviceInfo.iosInfo;
        return ios.systemVersion.trim();
    }
  }

  bool get _isApplePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
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
final fcmRegistrationServiceProvider = Provider<FcmRegistrationService>((ref) {
  return FcmRegistrationService(ref.watch(apiClientProvider));
});

class FcmDeviceRegistration {
  const FcmDeviceRegistration({
    required this.installationId,
    required this.fcmToken,
    required this.platform,
    required this.osVersion,
  });

  final String installationId;
  final String fcmToken;
  final FcmPlatform platform;
  final String osVersion;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'installationId': installationId,
    'fcmToken': fcmToken,
    'platform': platform.apiValue,
    'osVersion': osVersion,
  };
}

enum FcmPlatform {
  android,
  ios;

  String get apiValue => switch (this) {
    FcmPlatform.android => 'ANDROID',
    FcmPlatform.ios => 'IOS',
  };
}
