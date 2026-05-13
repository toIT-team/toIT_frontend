import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

/// 단일 업로드 측정 결과
class UploadBenchmarkSample {
  final int totalRequestMs;

  const UploadBenchmarkSample({required this.totalRequestMs});
}

class UploadBenchmarkService {
  final ApiClient _apiClient;

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

  /// N장을 병렬 업로드하는 실제 패턴을 반복 측정. 보고서 문자열을 반환한다.
  Future<String> runImageBatchBenchmark({
    required List<int> foldersIdList,
    required List<({List<int> bytes, String fileName})> images,
    String textContent = '',
    int iterations = 20,
  }) async {
    final samples = <({List<({int uploadMs, int waitMs, int totalMs})> perImage, int totalMs})>[];

    for (int i = 0; i < iterations; i++) {
      final batchSw = Stopwatch()..start();

      final results = await Future.wait(
        images.map((img) async {
          final formData = FormData.fromMap({
            'image': MultipartFile.fromBytes(
              Uint8List.fromList(img.bytes),
              filename: img.fileName,
            ),
            'textContent': textContent,
          });
          final imgSw = Stopwatch()..start();
          int? uploadDoneMs;
          try {
            await _apiClient.post<dynamic>(
              ApiConstants.attachmentsImagesEndpoint,
              queryParameters: {'foldersIdList': foldersIdList},
              data: formData,
              onSendProgress: (sent, total) {
                if (sent == total) uploadDoneMs = imgSw.elapsedMilliseconds;
              },
            );
            final totalMs = imgSw.elapsedMilliseconds;
            final uploadMs = uploadDoneMs ?? totalMs;
            return (uploadMs: uploadMs, waitMs: totalMs - uploadMs, totalMs: totalMs) as ({int uploadMs, int waitMs, int totalMs})?;
          } catch (_) {
            return null;
          }
        }),
      );

      final totalMs = batchSw.elapsedMilliseconds;
      if (results.any((r) => r == null)) continue;

      samples.add((
        perImage: results.cast<({int uploadMs, int waitMs, int totalMs})>(),
        totalMs: totalMs,
      ));
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
  // Private: 단일 측정
  // ────────────────────────────────────────────────

  Future<UploadBenchmarkSample?> _measure(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final requestWatch = Stopwatch()..start();
      await request();
      requestWatch.stop();
      return UploadBenchmarkSample(totalRequestMs: requestWatch.elapsedMilliseconds);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────
  // Private: 보고서 출력
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

    final w = iterations.toString().length;
    for (int i = 0; i < n; i++) {
      final s = samples[i];
      final idx = '[${(i + 1).toString().padLeft(w, '0')}/$iterations]';
      buf.writeln('$idx  req=${s.totalRequestMs}ms');
    }

    if (n == 0) {
      buf.writeln('유효한 샘플 없음');
      debugPrint(buf.toString());
      return;
    }

    buf.writeln('──────────────────────────────────────────────────────');
    _appendStats(buf, '요청(클라이언트)', samples.map((s) => s.totalRequestMs).toList());
    buf.write('══════════════════════════════════════════════════════');

    debugPrint(buf.toString());
  }

  String _buildBatchReport(
    int imageCount,
    int iterations,
    List<({List<({int uploadMs, int waitMs, int totalMs})> perImage, int totalMs})> samples,
  ) {
    final buf = StringBuffer();
    final n = samples.length;

    buf.writeln('══════════════════════════════════════════════════════');
    buf.writeln('  이미지 업로드 벤치마크  (${imageCount}장 × ${iterations}회)  성공: $n');
    buf.writeln('══════════════════════════════════════════════════════');

    if (n == 0) {
      buf.write('유효한 샘플 없음');
      return buf.toString();
    }

    final w = iterations.toString().length;
    for (int i = 0; i < n; i++) {
      final s = samples[i];
      final idx = '[${(i + 1).toString().padLeft(w, '0')}/$iterations]';
      final perImg = s.perImage
          .asMap()
          .entries
          .map((e) => 'img${e.key + 1}(upload=${e.value.uploadMs}ms wait=${e.value.waitMs}ms total=${e.value.totalMs}ms)')
          .join('  ');
      buf.writeln('$idx  total=${s.totalMs}ms  $perImg');
    }

    buf.writeln('──────────────────────────────────────────────────────');
    _appendStats(buf, 'batch total  ', samples.map((s) => s.totalMs).toList());
    for (int i = 0; i < imageCount; i++) {
      _appendStats(buf, 'img${i + 1} upload  ', samples.map((s) => s.perImage[i].uploadMs).toList());
      _appendStats(buf, 'img${i + 1} wait    ', samples.map((s) => s.perImage[i].waitMs).toList());
      _appendStats(buf, 'img${i + 1} total   ', samples.map((s) => s.perImage[i].totalMs).toList());
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
}
