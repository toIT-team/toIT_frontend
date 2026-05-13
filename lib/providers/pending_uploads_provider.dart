import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pending_image_upload.dart';
import '../repositories/home_repository.dart';

const _maxRetries = 2;

class PendingUploadsNotifier extends Notifier<List<PendingImageUpload>> {
  @override
  List<PendingImageUpload> build() => [];

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

    state = [...state, upload];
    await _upload(upload);
  }

  Future<void> retry(String id) async {
    final upload = state.where((u) => u.id == id).firstOrNull;
    if (upload == null) return;

    _update(upload.copyWith(
      status: PendingUploadStatus.uploading,
      retryCount: 0,
    ));
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
        _remove(upload.id);
        ref.invalidate(pageItemsProvider(upload.folderId));
        return;
      } catch (_) {
        if (attempt < _maxRetries) continue;
        _update(upload.copyWith(
          status: PendingUploadStatus.failed,
          retryCount: attempt,
        ));
      }
    }
  }

  void _update(PendingImageUpload updated) {
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
