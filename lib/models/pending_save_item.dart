import 'dart:typed_data';

/// 보관함에 저장 대기 중인 자료 타입.
enum PendingSaveType { image, link, note, file }

/// pending 큐 항목 상태.
enum PendingSaveStatus { uploading, failed }

/// 이미지·파일 등 바이너리 첨부.
class PendingBlobItem {
  final Uint8List bytes;
  final String fileName;

  const PendingBlobItem({required this.bytes, required this.fileName});
}

/// 로컬 DB에 보관 후 백그라운드로 전송하는 pending 항목.
class PendingSaveItem {
  final String id;
  final PendingSaveType type;
  final int folderId;

  /// 노트 본문, 링크 설명, 이미지·파일 메모 등.
  final String textContent;
  final PendingSaveStatus status;
  final int retryCount;

  /// 링크 전용 필드 (type == link 일 때만 사용).
  final String? linksUrl;
  final String? linksName;
  final String? linksThumbnail;

  /// 이미지·파일 바이너리 (type == image | file).
  final List<PendingBlobItem> blobs;

  const PendingSaveItem({
    required this.id,
    required this.type,
    required this.folderId,
    required this.textContent,
    this.status = PendingSaveStatus.uploading,
    this.retryCount = 0,
    this.linksUrl,
    this.linksName,
    this.linksThumbnail,
    this.blobs = const [],
  });

  PendingSaveItem copyWith({
    PendingSaveStatus? status,
    int? retryCount,
  }) {
    return PendingSaveItem(
      id: id,
      type: type,
      folderId: folderId,
      textContent: textContent,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      linksUrl: linksUrl,
      linksName: linksName,
      linksThumbnail: linksThumbnail,
      blobs: blobs,
    );
  }

  /// 이미지 탭 pending UI 호환용.
  List<PendingBlobItem> get items => blobs;
}

/// 기존 코드 호환 alias.
typedef PendingUploadStatus = PendingSaveStatus;
typedef PendingImageItem = PendingBlobItem;
typedef PendingImageUpload = PendingSaveItem;
