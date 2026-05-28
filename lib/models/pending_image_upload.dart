import 'dart:typed_data';

enum PendingUploadStatus { uploading, failed }

class PendingImageItem {
  final Uint8List bytes;
  final String fileName;

  const PendingImageItem({required this.bytes, required this.fileName});
}

class PendingImageUpload {
  final String id;
  final int folderId;
  final String textContent;
  final List<PendingImageItem> items;
  final PendingUploadStatus status;
  final int retryCount;

  const PendingImageUpload({
    required this.id,
    required this.folderId,
    required this.textContent,
    required this.items,
    this.status = PendingUploadStatus.uploading,
    this.retryCount = 0,
  });

  PendingImageUpload copyWith({
    PendingUploadStatus? status,
    int? retryCount,
  }) {
    return PendingImageUpload(
      id: id,
      folderId: folderId,
      textContent: textContent,
      items: items,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
