import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/attachment_upload_utils.dart';
import '../models/dto/attachment_confirm_dto.dart';
import '../models/dto/attachment_presign_dto.dart';

class UploadBenchmarkSample {
  final int totalRequestMs;

  const UploadBenchmarkSample({required this.totalRequestMs});
}

class UploadBenchmarkService {
  final ApiClient _apiClient;

  UploadBenchmarkService({required ApiClient apiClient})
      : _apiClient = apiClient;

  static final _s3Dio = Dio();

  // ────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────

  /// presign → S3 PUT 병렬 → confirm 플로우를 반복 측정
  Future<String> runImageBatchBenchmark({
    required List<int> foldersIdList,
    required List<({List<int> bytes, String fileName})> images,
    String textContent = '',
    int iterations = 20,
  }) async {
    final n = images.length;

    final bytesList = images
        .map((img) => img.bytes is Uint8List
            ? img.bytes as Uint8List
            : Uint8List.fromList(img.bytes))
        .toList();
    final fileNames = images.map((img) => img.fileName).toList();
    final contentTypes = fileNames.map(resolveContentType).toList();

    final samples = <({
      int presignMs,
      List<int> perS3Ms,
      int confirmMs,
      int totalMs,
    })>[];

    for (int i = 0; i < iterations; i++) {
      final totalSw = Stopwatch()..start();
      try {
        // 1. presign
        final presignSw = Stopwatch()..start();
        final presignResp = await _apiClient.post<dynamic>(
          ApiConstants.attachmentsPresignEndpoint,
          data: PresignRequestDto(
            foldersIdList: foldersIdList,
            attachmentsType: 'IMAGE',
            textContent: textContent,
            files: [
              for (int j = 0; j < n; j++)
                PresignFileDto(
                  contentType: contentTypes[j],
                  fileName: fileNames[j],
                  fileSize: bytesList[j].length,
                ),
            ],
          ).toJson(),
        );
        final presignMs = presignSw.elapsedMilliseconds;

        final rawData = presignResp.data;
        if (rawData is! List || rawData.length != n) continue;
        final presignedList = rawData
            .whereType<Map<String, dynamic>>()
            .map(PresignResponseDto.fromJson)
            .toList();
        if (presignedList.length != n) continue;

        // 2. S3 PUT 병렬
        final s3Results = await Future.wait([
          for (int j = 0; j < n; j++)
            () async {
              final sw = Stopwatch()..start();
              await _s3Dio.put(
                presignedList[j].uploadUrl,
                data: Stream<List<int>>.fromIterable([bytesList[j]]),
                options: Options(
                  headers: {
                    Headers.contentTypeHeader: contentTypes[j],
                    Headers.contentLengthHeader: bytesList[j].length,
                  },
                  contentType: contentTypes[j],
                  responseType: ResponseType.plain,
                ),
              );
              return sw.elapsedMilliseconds;
            }(),
        ]);

        // 3. confirm
        final confirmSw = Stopwatch()..start();
        await _apiClient.post<dynamic>(
          ApiConstants.attachmentsConfirmEndpoint,
          data: ConfirmRequestDto(
            foldersIdList: foldersIdList,
            attachmentsType: 'IMAGE',
            textContent: textContent,
            files: [
              for (int j = 0; j < n; j++)
                ConfirmFileDto(
                  objectKey: presignedList[j].objectKey,
                  fileName: fileNames[j],
                  fileSize: bytesList[j].length,
                  contentType: contentTypes[j],
                ),
            ],
          ).toJson(),
        );
        final confirmMs = confirmSw.elapsedMilliseconds;

        samples.add((
          presignMs: presignMs,
          perS3Ms: s3Results,
          confirmMs: confirmMs,
          totalMs: totalSw.elapsedMilliseconds,
        ));
      } catch (_) {
        continue;
      }
    }

    return _buildBatchReport(n, iterations, samples);
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
  // Private
  // ────────────────────────────────────────────────

  Future<UploadBenchmarkSample?> _measure(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final sw = Stopwatch()..start();
      await request();
      sw.stop();
      return UploadBenchmarkSample(totalRequestMs: sw.elapsedMilliseconds);
    } catch (_) {
      return null;
    }
  }

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
    List<({int presignMs, List<int> perS3Ms, int confirmMs, int totalMs})> samples,
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
      final s3 = s.perS3Ms
          .asMap()
          .entries
          .map((e) => 'img${e.key + 1}=${e.value}ms')
          .join('  ');
      buf.writeln('$idx  presign=${s.presignMs}ms  $s3  confirm=${s.confirmMs}ms  total=${s.totalMs}ms');
    }

    buf.writeln('──────────────────────────────────────────────────────');
    _appendStats(buf, 'presign   ', samples.map((s) => s.presignMs).toList());
    for (int i = 0; i < imageCount; i++) {
      _appendStats(buf, 'img${i + 1}       ', samples.map((s) => s.perS3Ms[i]).toList());
    }
    _appendStats(buf, 'confirm   ', samples.map((s) => s.confirmMs).toList());
    _appendStats(buf, 'total     ', samples.map((s) => s.totalMs).toList());
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
