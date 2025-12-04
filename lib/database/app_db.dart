import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/home/viewModel/sale.dart';
import 'package:cashier_app/services/sync/sync_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

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
      version: 8,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price INTEGER,
        qty INTEGER DEFAULT 0,
        otherqty INTEGER DEFAULT 0,
        promo INTEGER DEFAULT 0,
        pending INTEGER DEFAULT 0,   -- 0 = synced, 1 = needs upload
        deleted INTEGER DEFAULT 0,    -- 0 = active, 1 = deleted locally (soft delete)
        pending_delete INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT,
        qty INTEGER,
        price INTEGER,
        total INTEGER,
        promoDiscount INTEGER DEFAULT 0,
        date TEXT,
        pending INTEGER DEFAULT 0,
        deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin'
    });

    // Auto sync after create
    // SyncService.instance.syncAll();
  }

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

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE products ADD COLUMN otherqty INTEGER DEFAULT 0');
    }

    if (oldVersion < 5) {
      await db.execute('ALTER TABLE products ADD COLUMN promo INTEGER DEFAULT 0');
    }

    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT,
          role TEXT
        )
      ''');

      // In _onUpgrade (for older versions)
if (oldVersion < 7) {
  // Add missing columns safely - wrap in try/catch because SQLite will throw if column already exists
  try {
    await db.execute('ALTER TABLE products ADD COLUMN pending INTEGER DEFAULT 0');
  } catch (_) {}
  try {
    await db.execute('ALTER TABLE products ADD COLUMN deleted INTEGER DEFAULT 0');
  } catch (_) {}
  try {
    await db.execute('ALTER TABLE sales ADD COLUMN pending INTEGER DEFAULT 0');
  } catch (_) {}
  try {
    await db.execute('ALTER TABLE sales ADD COLUMN deleted INTEGER DEFAULT 0');
  } catch (_) {}
}

      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));

      if (count == 0) {
        await db.insert('users', {
          'username': 'admin',
          'password': 'admin123',
          'role': 'admin'
        });
      }
    }

    // Auto sync on upgrade
    // SyncService.instance.syncAll();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // ----------------- CRUD METHODS -------------------

  // Products
  Future<int> insertProduct(Product product) async {
  final db = await instance.database;
  final id = await db.insert('products', {
    'name': product.name,
    'price': product.price.toInt(),
    'qty': product.qty,
    'otherqty': product.otherqty,
    'promo': product.promo ? 1 : 0,
    'pending': 1,
    'deleted': 0,
  });
  // optionally trigger immediate sync: SyncService.instance.syncAll();
  return id;
}


  Future<List<Product>> fetchProducts() async {
    final db = await instance.database;
    final result = await db.query('products');

    return result.map((row) {
      return Product(
        id: row['id'] as int?,
        name: row['name'] as String,
        price: (row['price'] as int).toDouble(),
        qty: row['qty'] as int,
        otherqty: row['otherqty'] as int,
        promo: (row['promo'] as int? ?? 0) == 1,
      );
    }).toList();
  }

  Future<void> updateProduct(Product product) async {
  final db = await instance.database;
  await db.update(
    'products',
    {
      'name': product.name,
      'price': product.price.toInt(),
      'qty': product.qty,
      'otherqty': product.otherqty,
      'promo': product.promo ? 1 : 0,
      'pending': 1, // mark changed
    },
    where: 'id = ?',
    whereArgs: [product.id],
  );
}

Future<void> updateSale(Sale sale) async {
  final db = await instance.database;
  await db.update(
    'sales',
    {
      'productName': sale.productName,
      'qty': sale.qty,
      'price': sale.price,
      'total': sale.total,
      'promoDiscount': sale.promoDiscount ?? 0,
      'date': sale.date,
      'pending': sale.pending ?? 0,  // Sale model must include pending
      'deleted': sale.deleted ?? 0,
    },
    where: 'id = ?',
    whereArgs: [sale.id],
  );
}

Future<void> softDeleteProduct(int productId) async {
  final db = await instance.database;
  await db.update(
    'products',
    {'deleted': 1, 'pending': 1},
    where: 'id = ?',
    whereArgs: [productId],
  );
}



Future<void> seedDefaultProducts() async {
  // No default products inserted
  print("No default products seeded");
}


  // Delete product locally and mark as pending for sync
Future<void> deleteProduct(int productId) async {
  final db = await instance.database;

  // Mark as pending delete (2) instead of removing immediately
  await db.update(
    'products',
    {'pending': 2}, // 2 = pending delete
    where: 'id = ?',
    whereArgs: [productId],
  );

    // SyncService.instance.syncAll();
  }

  // Sales
  Future<int> insertSale(Sale sale) async {
  final db = await instance.database;
  final id = await db.insert('sales', {
    'productName': sale.productName,
    'qty': sale.qty,
    'price': sale.price,
    'total': sale.total,
    'promoDiscount': sale.promoDiscount ?? 0,
    'date': sale.date,
    'pending': 1,
    'deleted': 0,
  });
  return id;
}


  Future<List<Sale>> fetchAllSales() async {
    final db = await instance.database;
    final result = await db.query('sales');

    return result.map((row) => Sale.fromMap(row)).toList();
  }

  Future<int> deleteSale(int id) async {
    final db = await instance.database;

    final result = await db.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );

    // SyncService.instance.syncAll();
    return result;
  }

  /// ✅ Get sales filtered by date range
  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final db = await instance.database;

    final result = await db.query(
      'sales',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );

    return result.map((row) => Sale.fromMap(row)).toList();
  }

  // Users
  Future<int> insertUser(String username, String password, String role) async {
    final db = await instance.database;

    final id = await db.insert('users', {
      'username': username,
      'password': password,
      'role': role
    });

    // SyncService.instance.syncAll();
    return id;
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<String?> getUserRole(String username) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty ? result.first['role'] as String : null;
  }
}
