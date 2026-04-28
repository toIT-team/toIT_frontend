import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

/// 서버가 응답 바디에 포함하는 처리 시간 분해값
class UploadTimings {
  final int receiveMs;
  final int s3Ms;
  final int presignMs;

  const UploadTimings({
    required this.receiveMs,
    required this.s3Ms,
    required this.presignMs,
  });
}

/// 단일 업로드 측정 결과
class UploadBenchmarkSample {
  final int totalRequestMs;
  final UploadTimings? serverTimings;
  final int? presignedUrlLoadMs;

  const UploadBenchmarkSample({
    required this.totalRequestMs,
    this.serverTimings,
    this.presignedUrlLoadMs,
  });
}

/// 이미지/파일 업로드 성능 벤치마크
///
/// 사용 예:
/// ```dart
/// final svc = UploadBenchmarkService(apiClient: ref.read(apiClientProvider));
/// await svc.runImageBenchmark(
///   foldersIdList: [1],
///   imageBytes: bytes,
///   fileName: 'test.jpg',
///   iterations: 20,
/// );
/// ```
class UploadBenchmarkService {
  final ApiClient _apiClient;

  final Dio _s3Dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  UploadBenchmarkService({required ApiClient apiClient})
      : _apiClient = apiClient;

  // ────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────

  Future<void> runImageBenchmark({
    required List<int> foldersIdList,
    required List<int> imageBytes,
    required String fileName,
    String textContent = '',
    int iterations = 20,
  }) async {
    final samples = <UploadBenchmarkSample>[];

    for (int i = 0; i < iterations; i++) {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          Uint8List.fromList(imageBytes),
          filename: fileName,
        ),
        'textContent': textContent,
      });
      final sample = await _measure(
        () => _apiClient.post<dynamic>(
          ApiConstants.attachmentsImagesEndpoint,
          queryParameters: {'foldersIdList': foldersIdList},
          data: formData,
        ),
      );
      if (sample != null) samples.add(sample);
    }

    _printReport('이미지', iterations, samples);
  }

  /// N장을 순차 업로드하는 실제 패턴을 반복 측정. 보고서 문자열을 반환한다.
  Future<String> runImageBatchBenchmark({
    required List<int> foldersIdList,
    required List<({List<int> bytes, String fileName})> images,
    String textContent = '',
    int iterations = 20,
  }) async {
    final samples = <({List<int> perImageMs, int totalMs})>[];

    for (int i = 0; i < iterations; i++) {
      final batchSw = Stopwatch()..start();
      final perImageMs = <int>[];
      var failed = false;

      for (final img in images) {
        final formData = FormData.fromMap({
          'image': MultipartFile.fromBytes(
            Uint8List.fromList(img.bytes),
            filename: img.fileName,
          ),
          'textContent': textContent,
        });
        final imgSw = Stopwatch()..start();
        try {
          await _apiClient.post<dynamic>(
            ApiConstants.attachmentsImagesEndpoint,
            queryParameters: {'foldersIdList': foldersIdList},
            data: formData,
          );
          perImageMs.add(imgSw.elapsedMilliseconds);
        } catch (_) {
          failed = true;
          break;
        }
      }

      if (!failed && perImageMs.length == images.length) {
        samples.add((perImageMs: perImageMs, totalMs: batchSw.elapsedMilliseconds));
      }
    }

    return _buildBatchReport(images.length, iterations, samples);
  }

  Future<void> runFileBenchmark({
    required List<int> foldersIdList,
    required List<int> fileBytes,
    required String fileName,
    String textContent = '',
    int iterations = 20,
  }) async {
    final samples = <UploadBenchmarkSample>[];

    for (int i = 0; i < iterations; i++) {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          Uint8List.fromList(fileBytes),
          filename: fileName,
        ),
        'textContent': textContent,
      });
      final sample = await _measure(
        () => _apiClient.post<dynamic>(
          ApiConstants.attachmentsFilesEndpoint,
          queryParameters: {'foldersIdList': foldersIdList},
          data: formData,
        ),
      );
      if (sample != null) samples.add(sample);
    }

    _printReport('파일', iterations, samples);
  }

  // ────────────────────────────────────────────────
  // Private: 단일 측정 (출력 없이 샘플만 반환)
  // ────────────────────────────────────────────────

  Future<UploadBenchmarkSample?> _measure(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final requestWatch = Stopwatch()..start();
      final response = await request();
      requestWatch.stop();
      final totalRequestMs = requestWatch.elapsedMilliseconds;

      UploadTimings? serverTimings;
      String? firstPresignedUrl;

      final body = response.data;
      if (body is Map<String, dynamic>) {
        final rawTimings = body['timings'];
        if (rawTimings is Map<String, dynamic>) {
          serverTimings = UploadTimings(
            receiveMs: _toInt(rawTimings['receiveMs']),
            s3Ms: _toInt(rawTimings['s3Ms']),
            presignMs: _toInt(rawTimings['presignMs']),
          );
        }
        final results = body['results'];
        if (results is List && results.isNotEmpty) {
          final first = results.first;
          if (first is Map<String, dynamic>) {
            firstPresignedUrl = first['presignedUrl'] as String?;
          }
        }
      }

      int? presignedUrlLoadMs;
      if (firstPresignedUrl != null && firstPresignedUrl.isNotEmpty) {
        final loadWatch = Stopwatch()..start();
        await _s3Dio.get<List<int>>(
          firstPresignedUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        loadWatch.stop();
        presignedUrlLoadMs = loadWatch.elapsedMilliseconds;
      }

      return UploadBenchmarkSample(
        totalRequestMs: totalRequestMs,
        serverTimings: serverTimings,
        presignedUrlLoadMs: presignedUrlLoadMs,
      );
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────
  // Private: 모든 결과를 한 번에 출력
  // ────────────────────────────────────────────────

  void _printReport(
    String type,
    int iterations,
    List<UploadBenchmarkSample> samples,
  ) {
    final buf = StringBuffer();
    final n = samples.length;

    buf.writeln();
    buf.writeln('══════════════════════════════════════════════════════');
    buf.writeln('  $type 업로드 벤치마크  (성공 $n / 요청 $iterations)');
    buf.writeln('══════════════════════════════════════════════════════');

    // ── 개별 샘플 ──
    final w = iterations.toString().length;
    for (int i = 0; i < n; i++) {
      final s = samples[i];
      final idx = '[${(i + 1).toString().padLeft(w, '0')}/$iterations]';
      final srv = s.serverTimings;
      final srvStr = srv != null
          ? '  recv=${srv.receiveMs}ms  s3=${srv.s3Ms}ms  presign=${srv.presignMs}ms'
          : '';
      final loadStr = s.presignedUrlLoadMs != null
          ? '  urlLoad=${s.presignedUrlLoadMs}ms'
          : '';
      buf.writeln('$idx  req=${s.totalRequestMs}ms$srvStr$loadStr');
    }

    if (n == 0) {
      buf.writeln('유효한 샘플 없음');
      debugPrint(buf.toString());
      return;
    }

    // ── 통계 ──
    buf.writeln('──────────────────────────────────────────────────────');
    _appendStats(buf, '요청(클라이언트)', samples.map((s) => s.totalRequestMs).toList());

    final withTimings = samples.where((s) => s.serverTimings != null).toList();
    if (withTimings.isNotEmpty) {
      _appendStats(buf, '[서버] receive   ', withTimings.map((s) => s.serverTimings!.receiveMs).toList());
      _appendStats(buf, '[서버] s3        ', withTimings.map((s) => s.serverTimings!.s3Ms).toList());
      _appendStats(buf, '[서버] presign   ', withTimings.map((s) => s.serverTimings!.presignMs).toList());
    }

    final withLoad = samples.where((s) => s.presignedUrlLoadMs != null).toList();
    if (withLoad.isNotEmpty) {
      _appendStats(buf, 'URL 로드         ', withLoad.map((s) => s.presignedUrlLoadMs!).toList());
    }

    buf.write('══════════════════════════════════════════════════════');

    debugPrint(buf.toString());
  }

  String _buildBatchReport(
    int imageCount,
    int iterations,
    List<({List<int> perImageMs, int totalMs})> samples,
  ) {
    final buf = StringBuffer();
    final n = samples.length;

    buf.writeln('══════════════════════════════════════════════════════');
    buf.writeln('  이미지 업로드 벤치마크  (${imageCount}장 × ${iterations}회)  성공: $n');
    buf.writeln('══════════════════════════════════════════════════════');

    final w = iterations.toString().length;
    for (int i = 0; i < n; i++) {
      final s = samples[i];
      final idx = '[${(i + 1).toString().padLeft(w, '0')}/$iterations]';
      final perImg = s.perImageMs
          .asMap()
          .entries
          .map((e) => 'img${e.key + 1}=${e.value}ms')
          .join('  ');
      buf.writeln('$idx  total=${s.totalMs}ms  $perImg');
    }

    if (n == 0) {
      buf.write('유효한 샘플 없음');
      return buf.toString();
    }

    buf.writeln('──────────────────────────────────────────────────────');
    _appendStats(buf, '전체(${imageCount}장)', samples.map((s) => s.totalMs).toList());
    for (int i = 0; i < imageCount; i++) {
      _appendStats(buf, 'img${i + 1}         ', samples.map((s) => s.perImageMs[i]).toList());
    }
    buf.write('══════════════════════════════════════════════════════');
    return buf.toString();
  }

  void _appendStats(StringBuffer buf, String label, List<int> values) {
    final sorted = List<int>.from(values)..sort();
    final p50 = _percentile(sorted, 50);
    final p95 = _percentile(sorted, 95);
    final p99 = _percentile(sorted, 99);
    buf.writeln(
      '$label  p50=${p50}ms  p95=${p95}ms  p99=${p99}ms'
      '  min=${sorted.first}ms  max=${sorted.last}ms',
    );
  }

  int _percentile(List<int> sorted, int p) {
    final idx = ((p / 100) * (sorted.length - 1)).round();
    return sorted[idx];
  }

  int _toInt(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
