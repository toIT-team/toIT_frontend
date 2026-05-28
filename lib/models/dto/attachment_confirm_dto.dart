/// POST /attachments/confirm 요청 DTO
class ConfirmRequestDto {
  final List<int> foldersIdList;
  final String attachmentsType;
  final String textContent;
  final List<ConfirmFileDto> files;

  const ConfirmRequestDto({
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

class ConfirmFileDto {
  final String objectKey;
  final String fileName;
  final int fileSize;
  final String contentType;
  final int? width;
  final int? height;
  final ConfirmCompressedDto? compressed;

  const ConfirmFileDto({
    required this.objectKey,
    required this.fileName,
    required this.fileSize,
    required this.contentType,
    this.width,
    this.height,
    this.compressed,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'objectKey': objectKey,
      'fileName': fileName,
      'fileSize': fileSize,
      'contentType': contentType,
    };
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    if (compressed != null) map['compressed'] = compressed!.toJson();
    return map;
  }
}

class ConfirmCompressedDto {
  final String objectKey;
  final int fileSize;
  final int? width;
  final int? height;

  const ConfirmCompressedDto({
    required this.objectKey,
    required this.fileSize,
    this.width,
    this.height,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'objectKey': objectKey,
      'fileSize': fileSize,
    };
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    return map;
  }
}
