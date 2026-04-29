import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'upload_validation_utils.dart';

/// 파일명·확장자로부터 S3 업로드용 Content-Type 추론
/// - 이미지: image/* (HEIC/HEIF는 image/heic, image/heif)
/// - 문서: application/* (PDF/DOC/DOCX/XLSX/PPT/PPTX/HWP/ZIP 등)
/// - 매칭 실패 시 application/octet-stream
String resolveContentType(String fileName) {
  final extension = extractNormalizedExtension(fileName);
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'heic':
      return 'image/heic';
    case 'heif':
      return 'image/heif';
    case 'pdf':
      return 'application/pdf';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
    case 'xlxs':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'ppt':
      return 'application/vnd.ms-powerpoint';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'txt':
      return 'text/plain';
    case 'hwp':
      return 'application/x-hwp';
    case 'hwpx':
      return 'application/haansofthwpx';
    case 'zip':
      return 'application/zip';
    default:
      return 'application/octet-stream';
  }
}

/// S3 업로드 전 이미지 압축
/// - JPEG/PNG/WEBP만 압축, HEIC·기타는 원본 반환
/// - 최대 해상도 1920px, quality 80
Future<Uint8List> compressImageForUpload(
  Uint8List bytes,
  String fileName,
) async {
  final ext = extractNormalizedExtension(fileName);
  final CompressFormat? format = switch (ext) {
    'jpg' || 'jpeg' => CompressFormat.jpeg,
    'png' => CompressFormat.png,
    'webp' => CompressFormat.webp,
    _ => null,
  };
  if (format == null) return bytes;

  try {
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 1920,
      minHeight: 1920,
      quality: 80,
      format: format,
    );
    if (compressed.length >= bytes.length) return bytes;
    // if (kDebugMode) {
      // debugPrint(
        // '[compress] ${(bytes.length / 1024).toStringAsFixed(0)}KB'
        // ' → ${(compressed.length / 1024).toStringAsFixed(0)}KB'
        // ' (${((1 - compressed.length / bytes.length) * 100).toStringAsFixed(1)}% 감소)',
      // );
    // }
    return compressed;
  } catch (e) {
    // debugPrint('[compress] failed, using original: $e');
    return bytes;
  }
}

/// 이미지 픽셀 크기 (presign 요청용 width/height)
class ImageDimensions {
  const ImageDimensions({required this.width, required this.height});

  final int width;
  final int height;
}

/// 이미지 바이트로부터 width/height 추출 (실패 시 null)
/// HEIC 등 일부 포맷은 디코딩 실패 가능 → 호출부는 null 허용 처리
Future<ImageDimensions?> readImageDimensions(Uint8List bytes) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final dimensions = ImageDimensions(
      width: image.width,
      height: image.height,
    );
    image.dispose();
    return dimensions;
  } on PlatformException catch (e) {
    // debugPrint('[readImageDimensions] PlatformException: $e');
    return null;
  } catch (e) {
    // debugPrint('[readImageDimensions] failed: $e');
    return null;
  }
}
