
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
      version: 2, // Update the version to trigger onUpgrade
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // Handle database upgrade
    );
  }

  // Create the DB with the initial schema (without qty column)
  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      price INTEGER,
      qty INTEGER DEFAULT 0  -- Add the qty column here
    )''');
  }

  // Handle upgrading the DB schema when version changes
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Check if qty column exists. If not, add it.
      await db.execute('ALTER TABLE products ADD COLUMN qty INTEGER DEFAULT 0');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Insert a product into the database
  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', {
      'name': product.name,
      'price': product.price.toInt(),
      'qty': product.qty,
    });
  }

  // Fetch all products from the database
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

  // Update product in the database
  Future<void> updateProduct(Product product) async {
    final db = await instance.database;
    await db.update(
      'products',
      {
        'name': product.name,
        'price': product.price.toInt(),
        'qty': product.qty,  // Update qty here
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete product from the database
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




