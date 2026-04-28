/// POST /attachments/confirm 요청 (S3 PUT 완료 후 DB 저장 확정)
class ConfirmRequestDto {
  const ConfirmRequestDto({
    required this.foldersIdList,
    required this.attachmentsType,
    required this.files,
    this.textContent,
  });

  final List<int> foldersIdList;
  final String attachmentsType;
  final List<ConfirmFileDto> files;
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

/// /attachments/confirm 의 files 배열 항목
class ConfirmFileDto {
  const ConfirmFileDto({
    required this.objectKey,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    this.width,
    this.height,
  });

  final String objectKey;
  final String fileName;
  final String contentType;
  final int fileSize;
  final int? width;
  final int? height;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'objectKey': objectKey,
      'fileName': fileName,
      'contentType': contentType,
      'fileSize': fileSize,
    };
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    return map;
  }
}

/// POST /attachments/confirm 응답 항목
class ConfirmResponseItem {
  const ConfirmResponseItem({
    required this.attachmentsId,
    required this.presignedUrl,
    this.fileName,
    this.contentType,
    this.fileSize,
  });

  final int attachmentsId;
  final String presignedUrl;
  final String? fileName;
  final String? contentType;
  final int? fileSize;

  factory ConfirmResponseItem.fromJson(Map<String, dynamic> json) {
    return ConfirmResponseItem(
      attachmentsId: (json['attachmentsId'] as num?)?.toInt() ?? 0,
      presignedUrl: json['presignedUrl'] as String? ?? '',
      fileName: json['fileName'] as String?,
      contentType: json['contentType'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
    );
  }
}
