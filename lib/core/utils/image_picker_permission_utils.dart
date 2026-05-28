import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// 갤러리에서 이미지 선택(ImagePicker) 전에 호출한다.
/// iOS는 사진 라이브러리 제한 허용(limited)도 성공으로 본다.
Future<bool> requestGalleryReadForImagePicker() async {
  if (Platform.isIOS) {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }
  if (Platform.isAndroid) {
    final photosStatus = await Permission.photos.request();
    if (photosStatus.isGranted) return true;
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }
  return true;
}

/// 카메라로 촬영(ImagePicker) 전에 호출한다.
Future<bool> requestCameraForImagePicker() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}
