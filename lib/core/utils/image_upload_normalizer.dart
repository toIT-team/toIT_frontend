import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'attachment_upload_utils.dart';

class ImageUploadPayload {
  final Uint8List bytes;
  final String fileName;
  final String contentType;
  final int fileSize;
  final int? width;
  final int? height;

  const ImageUploadPayload({
    required this.bytes,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.width,
    required this.height,
  });
}

ImageUploadPayload normalizeImageForUpload({
  required List<int> bytes,
  required String fileName,
}) {
  final sourceBytes = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final fallback = ImageUploadPayload(
    bytes: sourceBytes,
    fileName: fileName,
    contentType: resolveContentType(fileName),
    fileSize: sourceBytes.length,
    width: null,
    height: null,
  );

  final decoded = img.decodeImage(sourceBytes);
  if (decoded == null) return fallback;

  final hasOrientation = decoded.exif.imageIfd.hasOrientation;
  final orientation = decoded.exif.imageIfd.orientation;
  if (!hasOrientation || orientation == null || orientation == 1) {
    return ImageUploadPayload(
      bytes: sourceBytes,
      fileName: fileName,
      contentType: resolveContentType(fileName),
      fileSize: sourceBytes.length,
      width: decoded.width,
      height: decoded.height,
    );
  }

  final baked = img.bakeOrientation(decoded);
  final normalizedBytes = Uint8List.fromList(img.encodeJpg(baked, quality: 95));
  final normalizedFileName = _replaceExtension(fileName, 'jpg');

  return ImageUploadPayload(
    bytes: normalizedBytes,
    fileName: normalizedFileName,
    contentType: 'image/jpeg',
    fileSize: normalizedBytes.length,
    width: baked.width,
    height: baked.height,
  );
}

String _replaceExtension(String fileName, String extension) {
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex <= 0) return '$fileName.$extension';
  return '${fileName.substring(0, dotIndex)}.$extension';
}
