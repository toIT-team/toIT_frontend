/// 첨부 종류 (백엔드 enum: IMAGE / FILE)
class AttachmentsType {
  AttachmentsType._();

  static const String image = 'IMAGE';
  static const String file = 'FILE';
}

/// POST /attachments/presign 요청
class PresignRequestDto {
  const PresignRequestDto({
    required this.foldersIdList,
    required this.attachmentsType,
    required this.files,
    this.textContent,
  });

  final List<int> foldersIdList;
  final String attachmentsType;
  final List<PresignFileDto> files;
  final String? textContent;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'foldersIdList': foldersIdList,
      'attachmentsType': attachmentsType,
      'files': files.map((file) => file.toJson()).toList(),
    };
    if (textContent != null) map['textContent'] = textContent;
    return map;
  }
}

/// /attachments/presign 의 files 배열 항목
class PresignFileDto {
  const PresignFileDto({
    required this.contentType,
    required this.fileName,
    required this.fileSize,
    this.width,
    this.height,
  });

  final String contentType;
  final String fileName;
  final int fileSize;
  final int? width;
  final int? height;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'contentType': contentType,
      'fileName': fileName,
      'fileSize': fileSize,
    };
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    return map;
  }
}

/// POST /attachments/presign 응답
class PresignResponseDto {
  const PresignResponseDto({
    required this.objectKey,
    required this.uploadUrl,
    required this.expiresInSeconds,
  });

  final String objectKey;
  final String uploadUrl;
  final int expiresInSeconds;

  factory PresignResponseDto.fromJson(Map<String, dynamic> json) {
    return PresignResponseDto(
      objectKey: json['objectKey'] as String? ?? '',
      uploadUrl: json['uploadUrl'] as String? ?? '',
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 0,
    );
  }
}
