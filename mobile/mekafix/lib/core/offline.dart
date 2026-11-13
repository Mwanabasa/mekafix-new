import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class OfflineStore {
  OfflineStore._();
  static final OfflineStore instance = OfflineStore._();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'mekafix.db'),
      version: 1,
      onCreate: (database, _) async {
        await database.execute(
          'CREATE TABLE mechanic_cache (id INTEGER PRIMARY KEY, payload TEXT, cached_at TEXT)',
        );
        await database.execute(
          'CREATE TABLE pending_actions (id INTEGER PRIMARY KEY AUTOINCREMENT, kind TEXT, payload TEXT, created_at TEXT)',
        );
      },
    );
    return _db!;
  }

  Future<void> cacheMechanics(List<Map<String, dynamic>> items) async {
    if (kIsWeb) return;
    final database = await db;
    final batch = database.batch();
    await database.delete('mechanic_cache');
    for (final item in items) {
      batch.insert('mechanic_cache', {
        'id': item['id'],
        'payload': jsonEncode(item),
        'cached_at': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> readMechanics() async {
    if (kIsWeb) return [];
    final rows = await (await db).query('mechanic_cache', orderBy: 'id ASC');
    return rows
        .map((row) =>
            jsonDecode(row['payload'] as String) as Map<String, dynamic>)
        .toList();
  }

  Future<void> enqueue(String kind, Map<String, dynamic> payload) async {
    if (kIsWeb) return;
    await (await db).insert('pending_actions', {
      'kind': kind,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> pending() async {
    if (kIsWeb) return [];
    return (await db).query('pending_actions', orderBy: 'id ASC');
  }

  Future<void> removePending(int id) async {
    if (kIsWeb) return;
    await (await db)
        .delete('pending_actions', where: 'id = ?', whereArgs: [id]);
  }
}
