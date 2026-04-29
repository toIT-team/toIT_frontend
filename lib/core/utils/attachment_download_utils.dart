import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class AttachmentDownloadResult {
  const AttachmentDownloadResult({
    required this.savedPath,
    required this.fileName,
  });

  final String savedPath;
  final String fileName;
}

/// 다운로드 실패 사유를 호출자가 분기할 수 있도록 분류한다.
enum AttachmentDownloadErrorKind {
  emptyUrl,
  emptyFile,
  network,
  unknown,
}

class AttachmentDownloadException implements Exception {
  const AttachmentDownloadException(this.kind, {this.statusCode, this.cause});

  final AttachmentDownloadErrorKind kind;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() =>
      'AttachmentDownloadException(kind: $kind, status: $statusCode, cause: $cause)';
}

/// 갤러리 저장 권한 요청 결과. 거부와 영구거부를 구분한다.
enum MediaPermissionResult { granted, denied, permanentlyDenied }

/// 갤러리 저장 결과. 권한 거부와 단순 실패를 구분한다.
enum GallerySaveResult {
  success,
  permissionDenied,
  permissionPermanentlyDenied,
  failed,
}

String sanitizeDownloadFileName(String fileName) {
  final trimmed = fileName.trim();
  if (trimmed.isEmpty) return 'downloaded_file';
  return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
}

/// 갤러리·플러그인이 MIME을 알 수 있도록 알려진 확장자를 붙인다.
String ensureDownloadFileNameHasExtension(
  String safeFileName,
  String attachmentsExtension,
) {
  final lower = safeFileName.toLowerCase();
  const known = <String>[
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.gif',
    '.heic',
    '.bmp',
    '.pdf',
    '.zip',
  ];
  if (known.any(lower.endsWith)) return safeFileName;

  var ext = attachmentsExtension.trim().replaceAll('.', '').toLowerCase();
  if (ext.isEmpty) ext = 'jpg';
  final base = safeFileName.endsWith('.')
      ? safeFileName.substring(0, safeFileName.length - 1)
      : safeFileName;
  return '$base.$ext';
}

Future<AttachmentDownloadResult> downloadAttachmentFromPresignedUrl({
  required String presignedUrl,
  required String fileName,
  String attachmentsExtension = '',
}) async {
  if (presignedUrl.trim().isEmpty) {
    throw const AttachmentDownloadException(
      AttachmentDownloadErrorKind.emptyUrl,
    );
  }

  final safeBase = sanitizeDownloadFileName(fileName);
  final safeFileName = ensureDownloadFileNameHasExtension(
    safeBase,
    attachmentsExtension,
  );
  // path_provider의 iOS 구현은 objective_c FFI를 쓰는데, 일부 시뮬레이터에서
  // 프레임워크 로드가 실패한다. 임시 디렉터리는 dart:io만으로 충분하다.
  final uniquePrefix = DateTime.now().millisecondsSinceEpoch.toString();
  final savePath = p.join(
    Directory.systemTemp.path,
    '${uniquePrefix}_$safeFileName',
  );

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
      followRedirects: true,
      validateStatus: (status) =>
          status != null && status >= 200 && status < 400,
      headers: <String, dynamic>{},
    ),
  );

  try {
    await dio.download(presignedUrl, savePath);
  } on DioException catch (e, st) {
    // debugPrint(
      // '[download] dio error: ${e.message} status=${e.response?.statusCode}',
    // );
    // debugPrint('$st');
    throw AttachmentDownloadException(
      AttachmentDownloadErrorKind.network,
      statusCode: e.response?.statusCode,
      cause: e,
    );
  } catch (e, st) {
    // debugPrint('[download] unknown error: $e');
    // debugPrint('$st');
    throw AttachmentDownloadException(
      AttachmentDownloadErrorKind.unknown,
      cause: e,
    );
  }

  final file = File(savePath);
  if (!await file.exists() || (await file.length()) == 0) {
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
    throw const AttachmentDownloadException(
      AttachmentDownloadErrorKind.emptyFile,
    );
  }

  return AttachmentDownloadResult(savedPath: savePath, fileName: safeFileName);
}

Future<GallerySaveResult> saveDownloadedMediaToGallery({
  required String filePath,
}) async {
  final permission = await _requestMediaWritePermission();
  switch (permission) {
    case MediaPermissionResult.denied:
      return GallerySaveResult.permissionDenied;
    case MediaPermissionResult.permanentlyDenied:
      return GallerySaveResult.permissionPermanentlyDenied;
    case MediaPermissionResult.granted:
      break;
  }

  try {
    final result = await ImageGallerySaver.saveFile(
      filePath,
      isReturnPathOfIOS: true,
    );
    if (result is Map) {
      final success = result['isSuccess'];
      if (success is bool && success) return GallerySaveResult.success;
      final filePathValue = result['filePath'] ?? result['savedFilePath'];
      if (filePathValue != null && filePathValue.toString().isNotEmpty) {
        return GallerySaveResult.success;
      }
    }
    return GallerySaveResult.failed;
  } catch (e, st) {
    // debugPrint('[gallery] ImageGallerySaver 실패: $e');
    // debugPrint('$st');
    return GallerySaveResult.failed;
  }
}

Future<MediaPermissionResult> _requestMediaWritePermission() async {
  if (Platform.isIOS) {
    return _requestIosPhotoLibraryPermission();
  }
  if (Platform.isAndroid) {
    return _requestAndroidGalleryWritePermission();
  }
  return MediaPermissionResult.granted;
}

/// iOS는 갤러리 선택과 동일한 \"전체 사진 접근\" 권한을 사용한다.
/// (NSPhotoLibraryUsageDescription · Permission.photos)
/// 사용자가 한 번만 허용하면 선택과 저장이 모두 같은 권한으로 동작한다.
Future<MediaPermissionResult> _requestIosPhotoLibraryPermission() async {
  final status = await Permission.photos.request();
  if (status.isGranted || status.isLimited) {
    return MediaPermissionResult.granted;
  }
  if (status.isPermanentlyDenied || status.isRestricted) {
    return MediaPermissionResult.permanentlyDenied;
  }
  return MediaPermissionResult.denied;
}

/// Android는 SDK에 따라 실제 필요한 권한이 다르다.
/// - SDK 29(Android 10)+: MediaStore에 쓰기에 별도 권한 불필요
/// - SDK 28(Android 9) 이하: WRITE_EXTERNAL_STORAGE 필요
Future<MediaPermissionResult> _requestAndroidGalleryWritePermission() async {
  final storage = await Permission.storage.request();
  if (storage.isGranted) return MediaPermissionResult.granted;

  // Android 10+ 에서는 storage 미부여여도 MediaStore 쓰기가 가능하므로 시도를 허용한다.
  if (storage.isDenied || storage.isRestricted) {
    return MediaPermissionResult.granted;
  }
  if (storage.isPermanentlyDenied) {
    return MediaPermissionResult.permanentlyDenied;
  }
  return MediaPermissionResult.granted;
}
