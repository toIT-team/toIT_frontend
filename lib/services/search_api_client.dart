import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/dto/search_response_dto.dart';

/// 통합 검색 API 클라이언트
///
/// ## 캐싱 전략
///
/// 검색 결과는 keyword에 따라 달라지며, 데이터 변동(노트/링크 추가·삭제) 시
/// stale 가능성이 있음. 권장 전략:
///
/// 1. **단순 전략 (권장)**: 캐시 없이 매 요청마다 API 호출
///    - debounce 300ms로 이미 요청 수 절감
///    - 구현 단순, 항상 최신 결과
///
/// 2. **LRU + TTL 캐시**: keyword별 최근 N개 결과 캐시
///    - Key: keyword.trim().toLowerCase()
///    - Max size: 10~15
///    - TTL: 3~5분 (동일 검색어 재검색 시 즉시 표시, 이후 백그라운드 갱신)
///
/// 3. **Stale-while-revalidate**: 캐시 hit 시 즉시 표시 + 백그라운드 재요청
///    - UX 최고, 구현 복잡
///
/// 현재는 1번으로 구현. 필요 시 SearchController에 Map 캐시 레이어 추가.
/// GET /page/search - keyword 파라미터
class SearchApiClient {
  SearchApiClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// 통합 검색
  /// [keyword] 검색어
  Future<SearchResponseDto> search({
    required String keyword,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}${ApiConstants.searchEndpoint}',
      queryParameters: {
        'keyword': keyword,
      },
    );

    if (response.data == null) {
      return const SearchResponseDto();
    }

    return SearchResponseDto.fromJson(response.data!);
  }
}

/// SearchApiClient Provider
/// ApiClient의 인증 Dio를 공유하여 Bearer 토큰 자동 첨부
final searchApiClientProvider = Provider<SearchApiClient>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SearchApiClient(dio: apiClient.dio);
});
