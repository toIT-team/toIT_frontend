import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/pending_image_upload.dart';

class PendingUploadDb {
  static Database? _db;

  Future<Database> get _database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'pending_uploads.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE pending_uploads (
            id TEXT PRIMARY KEY,
            folder_id INTEGER NOT NULL,
            text_content TEXT NOT NULL,
            status TEXT NOT NULL,
            retry_count INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_upload_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            upload_id TEXT NOT NULL,
            file_name TEXT NOT NULL,
            bytes BLOB NOT NULL,
            FOREIGN KEY (upload_id) REFERENCES pending_uploads(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<void> insert(PendingImageUpload upload) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.insert('pending_uploads', {
        'id': upload.id,
        'folder_id': upload.folderId,
        'text_content': upload.textContent,
        'status': upload.status.name,
        'retry_count': upload.retryCount,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      for (final item in upload.items) {
        await txn.insert('pending_upload_images', {
          'upload_id': upload.id,
          'file_name': item.fileName,
          'bytes': item.bytes,
        });
      }
    });
  }

  Future<void> updateStatus(
    String id,
    PendingUploadStatus status,
    int retryCount,
  ) async {
    final db = await _database;
    await db.update(
      'pending_uploads',
      {'status': status.name, 'retry_count': retryCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _database;
    await db.delete('pending_uploads', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PendingImageUpload>> loadAll() async {
    final db = await _database;
    final rows = await db.query('pending_uploads', orderBy: 'created_at ASC');
    final result = <PendingImageUpload>[];

    for (final row in rows) {
      final imageRows = await db.query(
        'pending_upload_images',
        where: 'upload_id = ?',
        whereArgs: [row['id']],
      );
      result.add(PendingImageUpload(
        id: row['id'] as String,
        folderId: row['folder_id'] as int,
        textContent: row['text_content'] as String,
        status: PendingUploadStatus.values.firstWhere(
          (s) => s.name == row['status'],
          orElse: () => PendingUploadStatus.uploading,
        ),
        retryCount: row['retry_count'] as int,
        items: imageRows
            .map((img) => PendingImageItem(
                  bytes: img['bytes'] as Uint8List,
                  fileName: img['file_name'] as String,
                ))
            .toList(),
      ));
    }
    return result;
  }
}
