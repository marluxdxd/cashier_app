import 'package:cashier_app/home/viewModel/product.dart';
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
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Create ALL required tables
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price INTEGER,
        qty INTEGER DEFAULT 0
      )
    ''');

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
  }

  // Auto-upgrade if tables do not exist
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price INTEGER,
          qty INTEGER DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productName TEXT,
          qty INTEGER,
          price INTEGER,
          total INTEGER,
          date TEXT
        )
      ''');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Insert a product
  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', {
      'name': product.name,
      'price': product.price.toInt(),
      'qty': product.qty,
    });
  }

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    final db = await instance.database;
    final result = await db.query('products');

    return result.map((row) {
      return Product(
        id: row['id'] as int?,
        name: row['name'] as String,
        price: (row['price'] as int).toDouble(),
        qty: row['qty'] as int,
      );
    }).toList();
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    final db = await instance.database;
    await db.update(
      'products',
      {
        'name': product.name,
        'price': product.price.toInt(),
        'qty': product.qty,
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete product
  Future<void> deleteProduct(int productId) async {
    final db = await instance.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> seedDefaultProducts() async {}
}
