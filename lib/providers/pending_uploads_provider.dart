import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/pending_upload_db.dart';
import '../controllers/home_controller.dart';
import '../models/pending_save_item.dart';
import '../repositories/home_repository.dart';

const _maxRetries = 2;

final pendingUploadDbProvider = Provider<PendingUploadDb>((ref) => PendingUploadDb());

class PendingUploadsNotifier extends Notifier<List<PendingSaveItem>> {
  @override
  List<PendingSaveItem> build() => [];

  PendingUploadDb get _db => ref.read(pendingUploadDbProvider);

  /// 앱 시작 시 DB에서 미완료 항목 복구
  Future<void> restoreFromDb() async {
    final saved = await _db.loadAll();
    if (saved.isEmpty) return;

    state = saved;

    for (final item in saved) {
      if (item.status == PendingSaveStatus.uploading) {
        await _process(item);
      }
    }
  }

  Future<void> addImage({
    required int folderId,
    required String textContent,
    required List<({List<int> bytes, String fileName})> images,
  }) {
    final blobs = images
        .map(
          (img) => PendingBlobItem(
            bytes: img.bytes is Uint8List
                ? img.bytes as Uint8List
                : Uint8List.fromList(img.bytes),
            fileName: img.fileName,
          ),
        )
        .toList();
    return _enqueue(
      PendingSaveItem(
        id: _newId(),
        type: PendingSaveType.image,
        folderId: folderId,
        textContent: textContent,
        blobs: blobs,
      ),
    );
  }

  Future<void> addNote({
    required int folderId,
    required String textContent,
  }) {
    return _enqueue(
      PendingSaveItem(
        id: _newId(),
        type: PendingSaveType.note,
        folderId: folderId,
        textContent: textContent,
      ),
    );
  }

  Future<void> addLink({
    required int folderId,
    required String linksUrl,
    String? linksName,
    String? textContent,
    String? linksThumbnail,
  }) {
    return _enqueue(
      PendingSaveItem(
        id: _newId(),
        type: PendingSaveType.link,
        folderId: folderId,
        textContent: textContent ?? '',
        linksUrl: linksUrl,
        linksName: linksName,
        linksThumbnail: linksThumbnail,
      ),
    );
  }

  Future<void> addFile({
    required int folderId,
    required String textContent,
    required List<int> fileBytes,
    required String fileName,
  }) {
    final bytes = fileBytes is Uint8List
        ? fileBytes
        : Uint8List.fromList(fileBytes);
    return _enqueue(
      PendingSaveItem(
        id: _newId(),
        type: PendingSaveType.file,
        folderId: folderId,
        textContent: textContent,
        blobs: [PendingBlobItem(bytes: bytes, fileName: fileName)],
      ),
    );
  }

  /// 기존 이미지 저장 호출 호환.
  Future<void> add({
    required int folderId,
    required String textContent,
    required List<({List<int> bytes, String fileName})> images,
  }) {
    return addImage(
      folderId: folderId,
      textContent: textContent,
      images: images,
    );
  }

  Future<void> retry(String id) async {
    final item = state.where((u) => u.id == id).firstOrNull;
    if (item == null) return;

    final updated = item.copyWith(
      status: PendingSaveStatus.uploading,
      retryCount: 0,
    );
    _updateState(updated);
    await _db.updateStatus(id, PendingSaveStatus.uploading, 0);
    await _process(state.firstWhere((u) => u.id == id));
  }

  Future<void> _enqueue(PendingSaveItem item) async {
    await _db.insert(item);
    state = [...state, item];
    unawaited(_process(item));
  }

  Future<void> _process(PendingSaveItem item) async {
    final repository = ref.read(homeRepositoryProvider);

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        await _send(repository, item);
        await _db.delete(item.id);
        _remove(item.id);
        ref.invalidate(pageItemsProvider(item.folderId));
        unawaited(ref.read(homeProvider.notifier).refresh(silent: true));
        return;
      } catch (_) {
        if (attempt < _maxRetries) continue;
        final failed = item.copyWith(
          status: PendingSaveStatus.failed,
          retryCount: attempt,
        );
        _updateState(failed);
        await _db.updateStatus(item.id, PendingSaveStatus.failed, attempt);
      }
    }
  }

  Future<void> _send(HomeRepository repository, PendingSaveItem item) async {
    switch (item.type) {
      case PendingSaveType.note:
        await repository.createText(
          foldersIdList: [item.folderId],
          textContent: item.textContent,
        );
      case PendingSaveType.link:
        await repository.createLink(
          foldersIdList: [item.folderId],
          linksUrl: item.linksUrl!,
          linksName: _emptyToNull(item.linksName),
          textContent: _emptyToNull(item.textContent),
          linksThumbnail: _emptyToNull(item.linksThumbnail),
        );
      case PendingSaveType.file:
        final blob = item.blobs.first;
        await repository.createFile(
          foldersIdList: [item.folderId],
          textContent: item.textContent,
          fileBytes: blob.bytes,
          fileName: blob.fileName,
        );
      case PendingSaveType.image:
        await repository.createImages(
          foldersIdList: [item.folderId],
          textContent: item.textContent,
          images: item.blobs
              .map((b) => (bytes: b.bytes as List<int>, fileName: b.fileName))
              .toList(),
        );
    }
  }

  String? _emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}';

  void _updateState(PendingSaveItem updated) {
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
    NotifierProvider<PendingUploadsNotifier, List<PendingSaveItem>>(
  PendingUploadsNotifier.new,
);
