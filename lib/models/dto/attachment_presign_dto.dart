/// POST /attachments/presign 요청 DTO
class PresignRequestDto {
  final List<int> foldersIdList;
  final String attachmentsType;
  final String textContent;
  final List<PresignFileDto> files;

  const PresignRequestDto({
    required this.foldersIdList,
    required this.attachmentsType,
    required this.textContent,
    required this.files,
  });

  Map<String, dynamic> toJson() => {
        'foldersIdList': foldersIdList,
        'attachmentsType': attachmentsType,
        'textContent': textContent,
        'files': files.map((f) => f.toJson()).toList(),
      };
}

class PresignFileDto {
  final String contentType;
  final String fileName;
  final int fileSize;
  final int? width;
  final int? height;

  const PresignFileDto({
    required this.contentType,
    required this.fileName,
    required this.fileSize,
    this.width,
    this.height,
  });

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

/// POST /attachments/presign 응답 DTO (파일 1개당)
class PresignResponseDto {
  final String objectKey;
  final String uploadUrl;
  final int expiresInSeconds;

  const PresignResponseDto({
    required this.objectKey,
    required this.uploadUrl,
    required this.expiresInSeconds,
  });

  factory PresignResponseDto.fromJson(Map<String, dynamic> json) {
    return PresignResponseDto(
      objectKey: json['objectKey'] as String,
      uploadUrl: json['uploadUrl'] as String,
      expiresInSeconds: json['expiresInSeconds'] as int,
    );
  }
}
