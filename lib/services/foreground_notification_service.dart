import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef ForegroundNotificationTapHandler =
    void Function(Map<String, dynamic> data);

class ForegroundNotificationService {
  ForegroundNotificationService();

  static const String _channelId = 'toit_foreground_notifications';
  static const String _channelName = 'toIT notifications';
  static const String _channelDescription =
      'Notifications received while toIT is open.';
  static const String _notificationIcon = 'ic_stat_notification';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;
  bool _isInitialized = false;

  Future<void> initialize({
    required ForegroundNotificationTapHandler onTap,
  }) async {
    if (!_isAndroid) return;
    if (_isInitialized) return;
    final pendingInitialization = _initializing;
    if (pendingInitialization != null) {
      await pendingInitialization;
      return;
    }

    _initializing = _initializeAndroid(onTap);
    try {
      await _initializing;
      _isInitialized = true;
    } finally {
      _initializing = null;
    }
  }

  Future<void> show(RemoteMessage message) async {
    if (!_isAndroid) return;
    if (!_isInitialized) {
      await _initializing;
      if (!_isInitialized) return;
    }

    final title = _resolveTitle(message);
    final body = _resolveBody(message);
    if (title == null && body == null) return;

    await _plugin.show(
      id: _resolveNotificationId(message),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: _notificationIcon,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<Map<String, dynamic>?> consumeLaunchPayload() async {
    if (!_isAndroid) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    final didLaunchFromNotification =
        details?.didNotificationLaunchApp ?? false;
    if (!didLaunchFromNotification) return null;
    return _decodePayload(details?.notificationResponse?.payload);
  }

  Future<void> _initializeAndroid(
    ForegroundNotificationTapHandler onTap,
  ) async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(_notificationIcon),
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final data = _decodePayload(response.payload);
        if (data == null) return;
        onTap(data);
      },
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
  }

  Map<String, dynamic>? _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return null;
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    } catch (_) {
      return null;
    }
  }

  String? _resolveTitle(RemoteMessage message) {
    final notificationTitle = message.notification?.title?.trim();
    if (notificationTitle != null && notificationTitle.isNotEmpty) {
      return notificationTitle;
    }
    return _resolveDataText(message.data, const ['title']);
  }

  String? _resolveBody(RemoteMessage message) {
    final notificationBody = message.notification?.body?.trim();
    if (notificationBody != null && notificationBody.isNotEmpty) {
      return notificationBody;
    }
    return _resolveDataText(message.data, const ['body', 'message', 'content']);
  }

  String? _resolveDataText(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final raw = data[key];
      if (raw == null) continue;
      final text = raw.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  int _resolveNotificationId(RemoteMessage message) {
    final parsedId = int.tryParse(message.messageId ?? '');
    if (parsedId != null) return parsedId;
    return Random().nextInt(1 << 31);
  }

  bool get _isAndroid {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }
}
