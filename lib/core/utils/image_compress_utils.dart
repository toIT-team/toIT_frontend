import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// 업로드 전 이미지 압축 및 변환
/// - HEIC/HEIF → JPEG 변환
/// - JPEG/PNG/WEBP → quality 80, 최대 1920px 압축
/// - 그 외 → 원본 반환
Future<({List<int> bytes, String fileName})> compressImageForUpload(
  List<int> bytes,
  String fileName,
) async {
  final ext = fileName.split('.').last.toLowerCase();

  final bool isHeic = ext == 'heic' || ext == 'heif';
  final CompressFormat? format = switch (ext) {
    'jpg' || 'jpeg' => CompressFormat.jpeg,
    'png' => CompressFormat.png,
    'webp' => CompressFormat.webp,
    'heic' || 'heif' => CompressFormat.jpeg,
    _ => null,
  };

  if (format == null) {
    debugPrint('[압축] $fileName — 지원하지 않는 형식($ext), 원본 반환 (${bytes.length} bytes)');
    return (bytes: bytes, fileName: fileName);
  }

  final src = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final sw = Stopwatch()..start();
  final result = await FlutterImageCompress.compressWithList(
    src,
    minWidth: 1920,
    minHeight: 1920,
    quality: 80,
    format: format,
  );

  final outBytes = result ?? bytes;
  final outName = isHeic
      ? '${fileName.substring(0, fileName.lastIndexOf('.'))}.jpg'
      : fileName;

  debugPrint(
    '[압축] $fileName → $outName  '
    '${bytes.length}B → ${outBytes.length}B  '
    '(${((1 - outBytes.length / bytes.length) * 100).toStringAsFixed(1)}% 감소)  '
    '${sw.elapsedMilliseconds}ms',
  );

  return (bytes: outBytes, fileName: outName);
}
