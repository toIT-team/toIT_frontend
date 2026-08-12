import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks folders changed by an external share flow.
///
/// iOS Share Extension writes the marker through App Group UserDefaults.
/// Android writes it through SharedPreferences. Flutter consumes and clears it
/// when the main app starts or returns to the foreground.
class ExternalSaveDirtyService {
  static const MethodChannel _channel = MethodChannel(
    'com.toit/external_save_dirty',
  );

  Future<void> markFolderDirty(int folderId) async {
    try {
      await _channel.invokeMethod<void>('markFolderDirty', {
        'folderId': folderId,
      });
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  Future<List<int>> consumeDirtyFolderIds() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'consumeDirtyFolderIds',
      );
      if (result == null) return const [];
      return result
          .map(_toInt)
          .whereType<int>()
          .where((id) => id > 0)
          .toSet()
          .toList();
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }

  int? _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

final externalSaveDirtyServiceProvider = Provider<ExternalSaveDirtyService>(
  (_) => ExternalSaveDirtyService(),
);
