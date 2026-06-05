import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/pending_save_item.dart';

class PendingUploadDb {
  static Database? _db;
  static const int _dbVersion = 2;

  Future<Database> get _database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'pending_uploads.db'),
      version: _dbVersion,
      onCreate: (db, _) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateToV2(db);
        }
      },
    );
  }

  /// v1 → v2: type·링크 컬럼 추가.
  /// 이전 마이그레이션이 중간에 실패하면 컬럼만 있고 version은 v1인
  /// 상태가 될 수 있어, 존재 여부를 확인한 뒤 추가한다.
  Future<void> _migrateToV2(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(pending_uploads)');
    final names = columns.map((c) => c['name'] as String).toSet();

    if (!names.contains('type')) {
      await db.execute(
        "ALTER TABLE pending_uploads ADD COLUMN type TEXT NOT NULL DEFAULT 'image'",
      );
    }
    if (!names.contains('links_url')) {
      await db.execute(
        'ALTER TABLE pending_uploads ADD COLUMN links_url TEXT',
      );
    }
    if (!names.contains('links_name')) {
      await db.execute(
        'ALTER TABLE pending_uploads ADD COLUMN links_name TEXT',
      );
    }
    if (!names.contains('links_thumbnail')) {
      await db.execute(
        'ALTER TABLE pending_uploads ADD COLUMN links_thumbnail TEXT',
      );
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE pending_uploads (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        folder_id INTEGER NOT NULL,
        text_content TEXT NOT NULL,
        status TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        links_url TEXT,
        links_name TEXT,
        links_thumbnail TEXT
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
  }

  Future<void> insert(PendingSaveItem item) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.insert('pending_uploads', {
        'id': item.id,
        'type': item.type.name,
        'folder_id': item.folderId,
        'text_content': item.textContent,
        'status': item.status.name,
        'retry_count': item.retryCount,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'links_url': item.linksUrl,
        'links_name': item.linksName,
        'links_thumbnail': item.linksThumbnail,
      });
      for (final blob in item.blobs) {
        await txn.insert('pending_upload_images', {
          'upload_id': item.id,
          'file_name': blob.fileName,
          'bytes': blob.bytes,
        });
      }
    });
  }

  Future<void> updateStatus(
    String id,
    PendingSaveStatus status,
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

  Future<List<PendingSaveItem>> loadAll() async {
    final db = await _database;
    final rows = await db.query('pending_uploads', orderBy: 'created_at ASC');
    final result = <PendingSaveItem>[];

    for (final row in rows) {
      final blobRows = await db.query(
        'pending_upload_images',
        where: 'upload_id = ?',
        whereArgs: [row['id']],
      );
      result.add(_rowToItem(row, blobRows));
    }
    return result;
  }

  PendingSaveItem _rowToItem(
    Map<String, Object?> row,
    List<Map<String, Object?>> blobRows,
  ) {
    final typeName = row['type'] as String? ?? PendingSaveType.image.name;
    return PendingSaveItem(
      id: row['id'] as String,
      type: PendingSaveType.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => PendingSaveType.image,
      ),
      folderId: row['folder_id'] as int,
      textContent: row['text_content'] as String,
      status: PendingSaveStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => PendingSaveStatus.uploading,
      ),
      retryCount: row['retry_count'] as int,
      linksUrl: row['links_url'] as String?,
      linksName: row['links_name'] as String?,
      linksThumbnail: row['links_thumbnail'] as String?,
      blobs: blobRows
          .map(
            (img) => PendingBlobItem(
              bytes: img['bytes'] as Uint8List,
              fileName: img['file_name'] as String,
            ),
          )
          .toList(),
    );
  }
}
