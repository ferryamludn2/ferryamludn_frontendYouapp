import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('profile.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile_image (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertImagePath(String imagePath) async {
    final db = await instance.database;
    await db.delete('profile_image');
    await db.insert('profile_image', {'image_path': imagePath});
  }

  Future<void> deleteImagePath() async {
    final db = await instance.database;
    await db.delete('profile_image');
  }

  Future<String?> getImagePath() async {
    final db = await instance.database;
    final result = await db.query('profile_image', limit: 1);
    if (result.isNotEmpty) {
      return result.first['image_path'] as String?;
    }
    return null;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
