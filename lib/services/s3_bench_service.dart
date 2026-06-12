import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class S3BenchItem {
  final String url;
  final String fileName;
  final int originalSizeBytes;

  const S3BenchItem({
    required this.url,
    required this.fileName,
    required this.originalSizeBytes,
  });
}

/// S3 Presigned URL 이미지 다운로드 성능 측정 서비스
/// bench/s3-compare 브랜치 전용 — 프로덕션에서는 사용하지 않는다.
class S3BenchService {
  static const int _kWarmupRuns = 5;
  static const int _kBenchmarkRuns = 100;

  final ApiClient _apiClient;

  S3BenchService(this._apiClient);

  /// bench 엔드포인트에서 이미지 목록을 가져온다.
  /// 화면 표시용으로도 쓸 수 있도록 [S3BenchItem] 리스트를 반환한다.
  Future<List<S3BenchItem>> fetchItems(int folderId) async {
    final endpoint = ApiConstants.imagesBenchS3Endpoint
        .replaceFirst('{folderId}', '$folderId');
    final Response<dynamic> resp;
    try {
      resp = await _apiClient.get(endpoint);
    } catch (e) {
      debugPrint('[S3 벤치] 엔드포인트 호출 실패: $e');
      return [];
    }

    final data = resp.data;
    if (data is! List || data.isEmpty) {
      debugPrint('[S3 벤치] 응답 없음 (data=$data)');
      return [];
    }

    final items = data
        .whereType<Map<String, dynamic>>()
        .map((e) => S3BenchItem(
              url: e['presignedUrl'] as String? ?? '',
              fileName: e['fileName'] as String? ?? '',
              originalSizeBytes:
                  ((e['attachmentsSize'] as num?) ?? 0).toInt(),
            ))
        .where((e) => e.url.isNotEmpty)
        .toList();

    debugPrint('[S3 벤치] ${items.length}개 수신');
    return items;
  }

  Future<void> run(int folderId) async {
    final items = await fetchItems(folderId);
    if (items.isEmpty) return;

    final allMs = <int>[];

    for (final item in items) {
      final origKb = (item.originalSizeBytes / 1024).toStringAsFixed(1);

      // 첫 로드 (cold)
      final firstMs = await _fetch(item.url);
      if (firstMs != null) {
        debugPrint('[S3 측정] FIRST | ${firstMs}ms | ${origKb}KB (원본) | ${item.url}');
      } else {
        debugPrint('[S3 측정] FIRST ERROR | ${item.url}');
        continue;
      }

      // 웜업
      debugPrint('[S3 웜업 시작] ${_kWarmupRuns}회 | ${item.url}');
      for (int i = 0; i < _kWarmupRuns; i++) {
        final ms = await _fetch(item.url);
        debugPrint('[S3 웜업] ${i + 1}/$_kWarmupRuns | ${ms != null ? '${ms}ms' : 'ERROR'}');
      }
      debugPrint('[S3 웜업 완료] ${item.url}');

      // 본 측정
      final urlMs = <int>[];
      debugPrint('[S3 벤치마크 시작] ${_kBenchmarkRuns}회 | ${item.url}');
      for (int i = 0; i < _kBenchmarkRuns; i++) {
        final ms = await _fetch(item.url);
        if (ms != null) {
          urlMs.add(ms);
          allMs.add(ms);
          debugPrint('[S3 벤치마크] ${i + 1}/$_kBenchmarkRuns | ${ms}ms | ${_pct(urlMs)}');
        } else {
          debugPrint('[S3 벤치마크] ${i + 1}/$_kBenchmarkRuns ERROR');
        }
      }
      debugPrint('[S3 벤치마크 완료] ${item.url} | ${_pct(urlMs)}');
    }

    if (allMs.isNotEmpty) {
      debugPrint('[S3 전체 완료] ${items.length}개 이미지 | ${_pct(allMs)}');
    }
  }

  Future<int?> _fetch(String url) async {
    // 매번 새 Dio + 캐시 무력화 헤더 → 클라이언트/OS 캐시 우회, 순수 네트워크 비용 측정
    final dio = Dio();
    try {
      final sw = Stopwatch()..start();
      await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        ),
      );
      sw.stop();
      return sw.elapsedMilliseconds;
    } catch (e) {
      debugPrint('[S3 fetch 오류] $url | $e');
      return null;
    } finally {
      dio.close();
    }
  }

  static String _pct(List<int> ms) {
    if (ms.isEmpty) return 'n=0';
    final s = [...ms]..sort();
    int p(double pct) => s[((s.length - 1) * pct).round()];
    return 'n=${s.length} p50=${p(.50)}ms p95=${p(.95)}ms p99=${p(.99)}ms';
  }
}

final s3BenchServiceProvider = Provider<S3BenchService>((ref) {
  return S3BenchService(ref.read(apiClientProvider));
});

/// 화면 표시용 — bench 엔드포인트에서 받아온 이미지 목록
final s3BenchItemsProvider =
    FutureProvider.family<List<S3BenchItem>, int>((ref, folderId) async {
  return ref.read(s3BenchServiceProvider).fetchItems(folderId);
});
