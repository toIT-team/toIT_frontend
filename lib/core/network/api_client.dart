import 'dart:async';

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
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// 내부 Dio 인스턴스 (인증 인터셉터 포함)
  /// SearchApiClient, ScheduleApiClient 등에서 공유하기 위한 getter
  Dio get dio => _dio;
}

/// ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// 인증 인터셉터
///
/// 책임:
/// 1. 모든 요청에 `Authorization: Bearer <accessToken>` 헤더 첨부
/// 2. 401 응답 시 refreshToken으로 access 토큰 재발급 후 원본 요청 재시도
/// 3. 재발급 실패 / 재시도도 401 이면 강제 로그아웃
///
/// 동시성 처리 (Single-Flight Pattern):
/// - 동시에 여러 요청이 401을 받아도 reissue 호출은 단 1회만 수행
/// - 진행 중인 reissue가 있으면 모든 후속 요청은 같은 Completer를 await
/// - reissue 도중 새로 출발하는 요청도 onRequest에서 Completer를 await 하여
///   stale token으로 보내지 않도록 보장
///
/// 무한 루프 방지:
/// - reissue 자체는 별도 Dio (AuthService 내부) 사용 → 인터셉터 미적용
/// - extra['__retried__'] 플래그로 동일 요청을 두 번 이상 재시도하지 않음
class _AuthInterceptor extends Interceptor {
  static const String _retriedExtraKey = '__retried_after_refresh__';

  final ApiClient _client;

  /// 진행 중인 토큰 재발급 작업.
  /// null 이면 idle, non-null 이면 refresh 진행 중이며 결과(String? newAccessToken)를 await 가능.
  Completer<String?>? _refreshCompleter;

  _AuthInterceptor(this._client);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authService = _client._authService;
    if (authService == null) return handler.next(options);

    // 진행 중인 refresh 가 있으면 그 결과를 기다린 뒤 토큰을 첨부한다.
    // 이렇게 하지 않으면 refresh 도중 출발한 요청은 stale token 으로 401을 받게 됨.
    final inFlight = _refreshCompleter;
    if (inFlight != null) {
      final refreshed = await inFlight.future;
      if (refreshed != null && refreshed.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $refreshed';
        return handler.next(options);
      }
      // refresh 실패한 경우엔 그냥 진행 (어차피 force logout 으로 정리됨)
    }

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
    final response = err.response;
    if (response?.statusCode != 401) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;

    // 이미 한 번 재시도한 요청이 또 401 → refresh 토큰 자체가 무효
    final alreadyRetried = requestOptions.extra[_retriedExtraKey] == true;
    if (alreadyRetried) {
      _client._onForceLogout?.call();
      return handler.next(err);
    }

    final newAccessToken = await _refreshAccessTokenSingleFlight();

    if (newAccessToken == null || newAccessToken.isEmpty) {
      _client._onForceLogout?.call();
      return handler.next(err);
    }

    try {
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      requestOptions.extra[_retriedExtraKey] = true;

      final retried = await _client._dio.fetch(requestOptions);
      handler.resolve(retried);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (retryError, stackTrace) {
      handler.next(
        DioException(
          requestOptions: requestOptions,
          error: retryError,
          stackTrace: stackTrace,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  /// 동시에 여러 요청이 호출해도 실제 reissue 는 단 1회만 실행되고
  /// 모든 호출자는 동일한 Future 결과(새 accessToken 혹은 null)를 공유한다.
  Future<String?> _refreshAccessTokenSingleFlight() async {
    final inFlight = _refreshCompleter;
    if (inFlight != null) {
      return inFlight.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final authService = _client._authService;
      if (authService == null) {
        completer.complete(null);
      } else {
        final newToken = await authService.reissueAccessToken();
        completer.complete(newToken);
      }
    } catch (e, st) {
      debugPrint('[_AuthInterceptor] reissue 예외: $e\n$st');
      completer.complete(null);
    } finally {
      _refreshCompleter = null;
    }

    return completer.future;
  }
}
