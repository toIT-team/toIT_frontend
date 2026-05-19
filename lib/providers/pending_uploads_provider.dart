import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/pending_upload_db.dart';
import '../models/pending_image_upload.dart';
import '../repositories/home_repository.dart';

const _maxRetries = 2;

final pendingUploadDbProvider = Provider<PendingUploadDb>((ref) => PendingUploadDb());

class PendingUploadsNotifier extends Notifier<List<PendingImageUpload>> {
  @override
  List<PendingImageUpload> build() => [];

  PendingUploadDb get _db => ref.read(pendingUploadDbProvider);

  /// 앱 시작 시 DB에서 미완료 항목 복구
  Future<void> restoreFromDb() async {
    final saved = await _db.loadAll();
    if (saved.isEmpty) return;

    state = saved;

    for (final upload in saved) {
      if (upload.status == PendingUploadStatus.uploading) {
        // 앱 종료 전 진행 중이었던 항목 → 재시도
        await _upload(upload);
      }
      // failed 항목은 UI에 재시도 버튼으로 노출
    }
  }

  Future<void> add({
    required int folderId,
    required String textContent,
    required List<({List<int> bytes, String fileName})> images,
  }) async {
    final id = '${DateTime.now().microsecondsSinceEpoch}';
    final items = images
        .map((img) => PendingImageItem(
              bytes: img.bytes is Uint8List
                  ? img.bytes as Uint8List
                  : Uint8List.fromList(img.bytes),
              fileName: img.fileName,
            ))
        .toList();

    final upload = PendingImageUpload(
      id: id,
      folderId: folderId,
      textContent: textContent,
      items: items,
    );

    // DB에 먼저 저장 (앱 종료 대비) - 업로드는 비동기로 시작
    await _db.insert(upload);
    state = [...state, upload];
    unawaited(_upload(upload));
  }

  Future<void> retry(String id) async {
    final upload = state.where((u) => u.id == id).firstOrNull;
    if (upload == null) return;

    final updated = upload.copyWith(
      status: PendingUploadStatus.uploading,
      retryCount: 0,
    );
    _updateState(updated);
    await _db.updateStatus(id, PendingUploadStatus.uploading, 0);
    await _upload(state.firstWhere((u) => u.id == id));
  }

  Future<void> _upload(PendingImageUpload upload) async {
    final repository = ref.read(homeRepositoryProvider);

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        await repository.createImages(
          foldersIdList: [upload.folderId],
          textContent: upload.textContent,
          images: upload.items
              .map((item) => (bytes: item.bytes as List<int>, fileName: item.fileName))
              .toList(),
        );
        // 성공: DB + 메모리에서 제거
        await _db.delete(upload.id);
        _remove(upload.id);
        ref.invalidate(pageItemsProvider(upload.folderId));
        return;
      } catch (_) {
        if (attempt < _maxRetries) continue;
        // 최대 재시도 초과: failed 상태로 전환
        final failed = upload.copyWith(
          status: PendingUploadStatus.failed,
          retryCount: attempt,
        );
        _updateState(failed);
        await _db.updateStatus(upload.id, PendingUploadStatus.failed, attempt);
      }
    }
  }

  void _updateState(PendingImageUpload updated) {
    state = [
      for (final u in state)
        if (u.id == updated.id) updated else u,
    ];
  }

  void _remove(String id) {
    state = state.where((u) => u.id != id).toList();
  }
}

final pendingUploadsProvider =
    NotifierProvider<PendingUploadsNotifier, List<PendingImageUpload>>(
  PendingUploadsNotifier.new,
);
