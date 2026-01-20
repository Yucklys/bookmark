import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/constants/app_constants.dart';

@singleton
class AppDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String path = join(appDocDir.path, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create files table
    await db.execute('''
      CREATE TABLE ${AppConstants.filesTable} (
        id TEXT PRIMARY KEY,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        mime_type TEXT,
        file_size INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        gemini_analysis TEXT,
        tags TEXT,
        description TEXT,
        thumbnail_path TEXT
      )
    ''');

    // Create search_cache table
    await db.execute('''
      CREATE TABLE ${AppConstants.searchCacheTable} (
        id TEXT PRIMARY KEY,
        query TEXT NOT NULL,
        results TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_files_created_at
      ON ${AppConstants.filesTable}(created_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_files_file_type
      ON ${AppConstants.filesTable}(file_type)
    ''');

    await db.execute('''
      CREATE INDEX idx_files_tags
      ON ${AppConstants.filesTable}(tags)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here when version changes
    // For now, we're at version 1, so no migrations needed
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Helper method to clear all data (useful for testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(AppConstants.filesTable);
    await db.delete(AppConstants.searchCacheTable);
  }
}
