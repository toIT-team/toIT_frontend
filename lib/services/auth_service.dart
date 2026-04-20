import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../core/constants/api_constants.dart';

/// 보안 저장소 키
const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';

/// 소셜 로그인(OAuth 콜백) 결과
enum AuthCallbackResult { success, cancelled, failed, needsSignup, deletedUser }

/// 콜백 파싱 결과
class AuthCallbackData {
  final AuthCallbackResult result;
  final String? accessToken;
  final String? refreshToken;
  final String? errorCode;
  final String? restoreToken;

  const AuthCallbackData({
    required this.result,
    this.accessToken,
    this.refreshToken,
    this.errorCode,
    this.restoreToken,
  });
}

/// 인증 관련 로직을 담당하는 서비스
/// - 소셜 로그인 (flutter_web_auth_2, 백엔드 OAuth → toit 콜백)
/// - 토큰 보안 저장 / 조회 / 삭제
/// - 액세스 토큰 재발급
class AuthService {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  static const _tokenChannel = MethodChannel(
    'com.example.pojTodo/token',
  );

  AuthService({FlutterSecureStorage? storage, Dio? dio})
    : _storage = storage ?? const FlutterSecureStorage(),
      _dio =
          dio ??
          (Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(
                milliseconds: ApiConstants.connectTimeout,
              ),
              receiveTimeout: const Duration(
                milliseconds: ApiConstants.receiveTimeout,
              ),
            ),
          )..interceptors.add(
              LogInterceptor(
                requestHeader: true,
                requestBody: true,
                responseHeader: false,
                responseBody: true,
              ),
            ));

  // ─── 토큰 저장소 ───

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
    await _syncTokenToAppGroup(accessToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    final hasAccessToken = accessToken != null && accessToken.isNotEmpty;
    final hasRefreshToken = refreshToken != null && refreshToken.isNotEmpty;

    // 토큰 쌍이 어긋난 상태(access만 있거나 refresh만 있는 경우)는
    // 앱 시작 시 authenticated로 오판되어 401 루프를 만들 수 있다.
    if (hasAccessToken != hasRefreshToken) {
      debugPrint(
        '[AuthService] 토큰 쌍 불일치 감지(access=$hasAccessToken, refresh=$hasRefreshToken) → 토큰 정리',
      );
      await clearTokens();
      return false;
    }

    return hasAccessToken && hasRefreshToken;
  }

  /// 앱 시작 시 기존 토큰을 App Group에 1회 동기화
  Future<void> syncExistingTokenToAppGroup() async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      await _syncTokenToAppGroup(token);
    }
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
    ]);
    await _clearTokenFromAppGroup();
  }

  // ─── iOS App Group 토큰 동기화 (Share Extension용) ───

  Future<void> _syncTokenToAppGroup(String accessToken) async {
    if (!Platform.isIOS) return;
    try {
      final userId = await getUserIdFromToken();
      debugPrint(
        '[AuthService] App Group 동기화 시도 - '
        'token: ${accessToken.substring(0, 10)}..., '
        'userId: $userId, '
        'baseUrl: ${ApiConstants.baseUrl}',
      );
      final result = await _tokenChannel.invokeMethod(
        'syncToken',
        {
          'accessToken': accessToken,
          'userId': userId ?? 0,
          'baseUrl': ApiConstants.baseUrl,
        },
      );
      debugPrint(
        '[AuthService] App Group 동기화 결과: $result',
      );
    } catch (e) {
      debugPrint(
        '[AuthService] App Group 토큰 동기화 실패: $e',
      );
    }
  }

  Future<void> _clearTokenFromAppGroup() async {
    if (!Platform.isIOS) return;
    try {
      await _tokenChannel.invokeMethod('clearToken');
    } catch (e) {
      debugPrint(
        '[AuthService] App Group 토큰 삭제 실패: $e',
      );
    }
  }

  // ─── 소셜 로그인 (백엔드 OAuth, 콜백 규약 동일) ───

  /// 브라우저로 백엔드 OAuth URL을 열고 `toit://auth/callback` 결과를 파싱
  Future<AuthCallbackData> _loginWithBackendOAuth({
    required String endpoint,
    required String logLabel,
  }) async {
    final loginUrl = '${ApiConstants.baseUrl}$endpoint';
    debugPrint('[AuthService] $logLabel 로그인 시작: $loginUrl');

    final resultUrl = await FlutterWebAuth2.authenticate(
      url: loginUrl,
      callbackUrlScheme: ApiConstants.authCallbackScheme,
    );

    debugPrint('[AuthService] 콜백 수신: $resultUrl');
    return _parseCallback(resultUrl);
  }

  Future<AuthCallbackData> loginWithKakao() => _loginWithBackendOAuth(
    endpoint: ApiConstants.kakaoLoginEndpoint,
    logLabel: '카카오',
  );

  Future<AuthCallbackData> loginWithApple() => _loginWithBackendOAuth(
    endpoint: ApiConstants.appleLoginEndpoint,
    logLabel: '애플',
  );

  /// 콜백 URL 파싱
  AuthCallbackData _parseCallback(String url) {
    final uri = Uri.parse(url);
    final resultStr = uri.queryParameters['result'] ?? '';
    final accessToken = uri.queryParameters['accessToken'];
    final refreshToken = uri.queryParameters['refreshToken'];
    final errorCode = uri.queryParameters['errorCode'];
    final restoreToken = uri.queryParameters['restoreToken'];

    debugPrint('[AuthService] 콜백 파싱 결과:');
    debugPrint('  result: $resultStr');
    debugPrint(
      '  accessToken: ${accessToken != null ? '${accessToken.substring(0, 20)}...' : 'null'}',
    );
    debugPrint(
      '  refreshToken: ${refreshToken != null ? '${refreshToken.substring(0, 20)}...' : 'null'}',
    );
    debugPrint('  errorCode: $errorCode');
    debugPrint(
      '  restoreToken: ${restoreToken != null ? '${restoreToken.substring(0, restoreToken.length > 12 ? 12 : restoreToken.length)}...' : 'null'}',
    );
    debugPrint('  전체 쿼리: ${uri.queryParameters}');
    if (accessToken != null && accessToken.isNotEmpty) {
      _debugPrintJwtPayload(token: accessToken, label: 'callback accessToken');
    }

    final result = switch (resultStr) {
      'success' => AuthCallbackResult.success,
      'cancelled' => AuthCallbackResult.cancelled,
      'needs_signup' => AuthCallbackResult.needsSignup,
      'deleted_user' => AuthCallbackResult.deletedUser,
      _ => AuthCallbackResult.failed,
    };

    return AuthCallbackData(
      result: result,
      accessToken: accessToken,
      refreshToken: refreshToken,
      errorCode: errorCode,
      restoreToken: restoreToken,
    );
  }

  /// 저장된 토큰의 payload를 콘솔에 출력 (디버그용)
  Future<void> printStoredUserInfo() async {
    final accessToken = await getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('[AuthService] 저장된 accessToken이 없습니다.');
      return;
    }
    _debugPrintJwtPayload(token: accessToken, label: 'stored accessToken');
  }

  /// accessToken에서 userId(sub) 추출
  Future<int?> getUserIdFromToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;
    final payload = _tryDecodeJwtPayload(accessToken);
    if (payload == null) return null;
    final sub = payload['sub'];
    if (sub == null) return null;
    return int.tryParse(sub.toString());
  }

  /// accessToken에서 사용자 닉네임 추출
  /// - nickname 클레임 우선
  /// - 없으면 name 클레임 fallback
  Future<String?> getNicknameFromToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;
    final payload = _tryDecodeJwtPayload(accessToken);
    if (payload == null) return null;

    final nickname = payload['nickname']?.toString().trim();
    if (nickname != null && nickname.isNotEmpty) {
      return nickname;
    }

    final name = payload['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    return null;
  }

  Map<String, dynamic>? _tryDecodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is Map<String, dynamic>) return payload;
      return null;
    } catch (_) {
      return null;
    }
  }

  void _debugPrintJwtPayload({required String token, required String label}) {
    final payload = _tryDecodeJwtPayload(token);
    if (payload == null) {
      debugPrint('[AuthService] $label payload decode 실패');
      return;
    }

    debugPrint('[AuthService] $label payload: $payload');
    debugPrint(
      '[AuthService] $label claims'
      ' sub=${payload['sub']}'
      ' nickname=${payload['nickname']}'
      ' name=${payload['name']}'
      ' email=${payload['email']}',
    );
  }

  // ─── 토큰 재발급 ───

  /// refreshToken으로 새 accessToken을 받아 저장한다.
  ///
  /// - 응답에 새 refreshToken이 포함된 경우(rotation) 함께 갱신 저장
  /// - reissue 요청은 인증 인터셉터가 적용되지 않은 별도 Dio 사용 → 무한 루프 방지
  /// - 성공: 새 accessToken 반환
  /// - 실패(저장된 refreshToken 없음 / 4xx / 응답 누락): null 반환
  ///   (호출자가 force logout 등 후속 처리)
  Future<String?> reissueAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('[AuthService][REISSUE] ❌ refreshToken 없음 → 재발급 불가');
      return null;
    }

    final reissueUrl = '${ApiConstants.baseUrl}${ApiConstants.reissueEndpoint}';
    final maskedRt = _maskToken(refreshToken);
    debugPrint('[AuthService][REISSUE] ▶ POST $reissueUrl');
    debugPrint('[AuthService][REISSUE]   body: {"refreshToken": "$maskedRt"}');

    try {
      final response = await _dio.post(
        ApiConstants.reissueEndpoint,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      debugPrint(
        '[AuthService][REISSUE] ◀ status=${response.statusCode}'
        ' body=${response.data}',
      );

      final data = response.data;
      if (data is! Map) {
        debugPrint(
          '[AuthService][REISSUE] ❌ 응답이 Map 형식이 아님 → 백엔드 명세 확인 필요',
        );
        return null;
      }

      final newAccessToken = data['accessToken'] as String?;
      if (newAccessToken == null || newAccessToken.isEmpty) {
        debugPrint(
          '[AuthService][REISSUE] ❌ 응답에 accessToken 키 없음/비어있음 → 키명: ${data.keys.toList()}',
        );
        return null;
      }

      final newRefreshToken = data['refreshToken'] as String?;

      await _storage.write(key: _kAccessToken, value: newAccessToken);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _storage.write(key: _kRefreshToken, value: newRefreshToken);
        debugPrint('[AuthService][REISSUE] ✓ refreshToken rotation 적용');
      }

      await _syncTokenToAppGroup(newAccessToken);
      debugPrint('[AuthService][REISSUE] ✓ accessToken 재발급 성공');
      return newAccessToken;
    } on DioException catch (e) {
      debugPrint('[AuthService][REISSUE] ❌ DioException');
      debugPrint('[AuthService][REISSUE]   type: ${e.type}');
      debugPrint('[AuthService][REISSUE]   status: ${e.response?.statusCode}');
      debugPrint('[AuthService][REISSUE]   responseBody: ${e.response?.data}');
      debugPrint('[AuthService][REISSUE]   message: ${e.message}');
      return null;
    } catch (e, st) {
      debugPrint('[AuthService][REISSUE] ❌ 예외: $e\n$st');
      return null;
    }
  }

  /// 토큰을 로그에 안전하게 출력하기 위한 마스킹 (앞 8자만 표시)
  String _maskToken(String token) {
    if (token.length <= 8) return '${token.substring(0, token.length)}...';
    return '${token.substring(0, 8)}...(len=${token.length})';
  }

  /// 탈퇴 사용자 계정 복구
  /// restoreToken으로 복구 후 access/refresh 토큰을 반환
  Future<AuthCallbackData?> restoreDeletedAccount({
    required String restoreToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.restoreAccountEndpoint,
        queryParameters: {'restoreToken': restoreToken},
      );

      final accessToken = response.data['accessToken'] as String?;
      final refreshToken = response.data['refreshToken'] as String?;
      if (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        return null;
      }

      return AuthCallbackData(
        result: AuthCallbackResult.success,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      debugPrint('[AuthService] 계정 복구 실패: ${e.message}');
      return null;
    }
  }
}

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
