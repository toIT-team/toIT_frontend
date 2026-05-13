import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/attachment_upload_utils.dart';
import '../core/utils/image_compress_utils.dart';
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

  // ────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────

  /// presign → S3 PUT (압축본만) → confirm 플로우를 반복 측정
  Future<String> runImageBatchBenchmark({
    required List<int> foldersIdList,
    required List<({List<int> bytes, String fileName})> images,
    String textContent = '',
    int iterations = 20,
  }) async {
    // 이터레이션마다 재압축하지 않도록 1회 준비
    final compressed = <Uint8List>[];
    final fileNames = <String>[];
    final contentTypes = <String>[];
    final compressedDims = <ImageDimensions?>[];

    for (final img in images) {
      final raw = img.bytes is Uint8List
          ? img.bytes as Uint8List
          : Uint8List.fromList(img.bytes);
      final (:bytes, :fileName) =
          await compressImageForUpload(raw, img.fileName);
      final compressedBytes =
          bytes is Uint8List ? bytes : Uint8List.fromList(bytes);

      compressed.add(compressedBytes);
      fileNames.add(fileName);
      contentTypes.add(resolveContentType(fileName));
      compressedDims.add(await readImageDimensions(compressedBytes));
    }

    final n = images.length;
    final samples =
        <({int presignMs, int s3Ms, int confirmMs, int totalMs})>[];

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
                  fileSize: compressed[j].length,
                  width: compressedDims[j]?.width,
                  height: compressedDims[j]?.height,
                ),
            ],
          ).toJson(),
        );
        presignSw.stop();

        final rawData = presignResp.data;
        if (rawData is! List || rawData.length != n) continue;
        final presignedList = rawData
            .whereType<Map<String, dynamic>>()
            .map(PresignResponseDto.fromJson)
            .toList();
        if (presignedList.length != n) continue;

        // 2. S3 PUT 병렬 (압축본만)
        final rawDio = Dio();
        final s3Sw = Stopwatch()..start();
        await Future.wait([
          for (int j = 0; j < n; j++)
            rawDio.put(
              presignedList[j].uploadUrl,
              data: Stream<List<int>>.fromIterable([compressed[j]]),
              options: Options(
                headers: {
                  Headers.contentTypeHeader: contentTypes[j],
                  Headers.contentLengthHeader: compressed[j].length,
                },
                contentType: contentTypes[j],
                responseType: ResponseType.plain,
              ),
            ),
        ]);
        s3Sw.stop();

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
                  fileSize: compressed[j].length,
                  contentType: contentTypes[j],
                  width: compressedDims[j]?.width,
                  height: compressedDims[j]?.height,
                ),
            ],
          ).toJson(),
        );
        confirmSw.stop();
        totalSw.stop();

        samples.add((
          presignMs: presignSw.elapsedMilliseconds,
          s3Ms: s3Sw.elapsedMilliseconds,
          confirmMs: confirmSw.elapsedMilliseconds,
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
  // Private: 단일 측정
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
    List<({int presignMs, int s3Ms, int confirmMs, int totalMs})> samples,
  ) {
    final buf = StringBuffer();
    final n = samples.length;

    buf.writeln('══════════════════════════════════════════════════════');
    buf.writeln(
        '  이미지 업로드 벤치마크  (${imageCount}장 × ${iterations}회)  성공: $n');
    buf.writeln('══════════════════════════════════════════════════════');

    final w = iterations.toString().length;
    for (int i = 0; i < n; i++) {
      final s = samples[i];
      final idx = '[${(i + 1).toString().padLeft(w, '0')}/$iterations]';
      buf.writeln(
        '$idx  presign=${s.presignMs}ms  s3=${s.s3Ms}ms  confirm=${s.confirmMs}ms  total=${s.totalMs}ms',
      );
    }

    if (n == 0) {
      buf.write('유효한 샘플 없음');
      return buf.toString();
    }

    buf.writeln('──────────────────────────────────────────────────────');
    _appendStats(buf, 'presign ', samples.map((s) => s.presignMs).toList());
    _appendStats(buf, 's3      ', samples.map((s) => s.s3Ms).toList());
    _appendStats(buf, 'confirm ', samples.map((s) => s.confirmMs).toList());
    _appendStats(buf, 'total   ', samples.map((s) => s.totalMs).toList());
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
