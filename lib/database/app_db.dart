import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDB {
  static final AppDB instance = AppDB._init();
  static Database? _database;

  AppDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cashier.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT,
        qty INTEGER,
        price INTEGER,
        total INTEGER,
        date TEXT
      )
    ''');

      // ✅ New products table
  await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      price INTEGER
    )
  ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
