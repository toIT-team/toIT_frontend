import 'dart:io';

import 'package:flutter/services.dart';

import '../core/constants/api_constants.dart';

class PlatformTokenStore {
  static const MethodChannel _channel = MethodChannel('com.toit/token');

  const PlatformTokenStore();

  bool get _isSupported => Platform.isIOS || Platform.isAndroid;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int userId,
    String? baseUrl,
  }) async {
    if (!_isSupported) return;
    await _channel.invokeMethod('syncToken', {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'baseUrl': baseUrl ?? ApiConstants.baseUrl,
    });
  }

  Future<String?> getAccessToken() async {
    if (!_isSupported) return null;
    return _channel.invokeMethod<String>('getAccessToken');
  }

  Future<String?> getRefreshToken() async {
    if (!_isSupported) return null;
    return _channel.invokeMethod<String>('getRefreshToken');
  }

  Future<bool> hasTokens() async {
    if (!_isSupported) return false;
    return await _channel.invokeMethod<bool>('hasTokens') ?? false;
  }

  Future<void> clearTokens() async {
    if (!_isSupported) return;
    await _channel.invokeMethod('clearToken');
  }
}
