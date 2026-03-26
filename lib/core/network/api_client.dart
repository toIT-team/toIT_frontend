import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../constants/api_constants.dart';

/// Dio 기반 API 클라이언트
class ApiClient {
  late final Dio _dio;
  AuthService? _authService;
  VoidCallback? _onForceLogout;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: {'accept': '*/*'},
      ),
    );

    // 로깅 인터셉터 (디버그용)
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  /// 인증 인터셉터 활성화
  /// main.dart 초기화 시점에 호출하여 Bearer 토큰 첨부 + 401 재발급 처리
  void enableAuth({
    required AuthService authService,
    required VoidCallback onForceLogout,
  }) {
    _authService = authService;
    _onForceLogout = onForceLogout;
    _dio.interceptors.add(_AuthInterceptor(this));
  }

  /// GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  /// POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  /// PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters);
  }

  /// PATCH 요청
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.patch<T>(path, data: data, queryParameters: queryParameters);
  }

  /// DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters);
  }
}

/// ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// 인증 인터셉터
/// - 요청마다 Authorization: Bearer 헤더 추가
/// - 401 응답 시 refreshToken으로 재발급 후 재시도
/// - 재발급도 실패하면 강제 로그아웃
class _AuthInterceptor extends Interceptor {
  final ApiClient _client;
  bool _isRefreshing = false;

  _AuthInterceptor(this._client);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authService = _client._authService;
    if (authService == null) return handler.next(options);

    final token = await authService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // 재발급 API 자체가 401이면 무한 루프 방지
    final path = err.requestOptions.path;
    if (path == ApiConstants.reissueEndpoint) {
      _client._onForceLogout?.call();
      return handler.next(err);
    }

    if (_isRefreshing) return handler.next(err);
    _isRefreshing = true;

    try {
      final authService = _client._authService;
      if (authService == null) return handler.next(err);

      final newToken = await authService.reissueAccessToken();
      _isRefreshing = false;

      if (newToken == null) {
        _client._onForceLogout?.call();
        return handler.next(err);
      }

      // 원본 요청을 새 토큰으로 재시도
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newToken';
      final response = await _client._dio.fetch(options);
      handler.resolve(response);
    } catch (e) {
      _isRefreshing = false;
      _client._onForceLogout?.call();
      handler.next(err);
    }
  }
}
