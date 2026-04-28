const int maxUploadSizeBytes = 10 * 1024 * 1024;

const Set<String> allowedFileExtensions = {
  'pdf',
  'doc',
  'docx',
  'xlxs',
  'xlsx',
  'pptx',
  'ppt',
  'txt',
  'hwp',
  'hwpx',
  'zip',
};

const Set<String> allowedImageExtensions = {
  'jpg',
  'jpeg',
  'png',
  'webp',
  'gif',
  'heic',
  'heif',
};

String extractNormalizedExtension(String fileName) {
  final normalizedName = fileName.trim().toLowerCase();
  final dotIndex = normalizedName.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == normalizedName.length - 1) {
    return '';
  }
  return normalizedName.substring(dotIndex + 1);
}

String? validateFileSectionUpload({
  required String fileName,
  required int fileSizeBytes,
}) {
  final extension = extractNormalizedExtension(fileName);
  if (extension.isEmpty) {
    return '허용되지 않은 파일 형식입니다.';
  }
  if (allowedImageExtensions.contains(extension)) {
    return '이 확장자는 이미지 부분에 저장해주세요.';
  }
  if (!allowedFileExtensions.contains(extension)) {
    return '허용되지 않은 파일 형식입니다.';
  }
  if (fileSizeBytes > maxUploadSizeBytes) {
    return '파일 및 이미지는 10MB 이하만 업로드할 수 있습니다.';
  }
  return null;
}

String? validateImageSectionUpload({
  required String fileName,
  required int fileSizeBytes,
}) {
  final extension = extractNormalizedExtension(fileName);
  if (extension.isEmpty) {
    return '허용되지 않은 파일 형식입니다.';
  }
  if (!allowedImageExtensions.contains(extension)) {
    return '이 확장자는 파일에서 저장해주세요.';
  }
  if (fileSizeBytes > maxUploadSizeBytes) {
    return '파일 및 이미지는 10MB 이하만 업로드할 수 있습니다.';
  }
  return null;
}
