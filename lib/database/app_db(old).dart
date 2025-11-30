// import 'package:cashier_app/home/viewModel/product.dart';
// import 'package:cashier_app/home/viewModel/sale.dart';
// import 'package:cashier_app/services/sync/sync_service.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'dart:async';

// class AppDB {
//   static final AppDB instance = AppDB._init();
//   static Database? _database;

//   AppDB._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('cashier.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);

//     return await openDatabase(
//       path,
//       version: 7,
//       onCreate: _createDB,
//       onUpgrade: _onUpgrade,
//     );
//   }

//   Future _createDB(Database db, int version) async {
//     // Create tables
//     await db.execute('''
//       CREATE TABLE products (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT,
//         price INTEGER,
//         qty INTEGER DEFAULT 0,
//         otherqty INTEGER DEFAULT 0,
//         promo INTEGER DEFAULT 0
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE sales (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         productName TEXT,
//         qty INTEGER,
//         price INTEGER,
//         total INTEGER,
//         promoDiscount INTEGER DEFAULT 0,
//         date TEXT
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE users (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         username TEXT UNIQUE,
//         password TEXT,
//         role TEXT
//       )
//     ''');

//     // Insert default admin user
//     await db.insert('users', {
//       'username': 'admin',
//       'password': 'admin123',
//       'role': 'admin'
//     });

//     // Auto sync after create
//     SyncService.instance.syncAll();
//   }

//   Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     if (oldVersion < 3) {
//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS products (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           name TEXT,
//           price INTEGER,
//           qty INTEGER DEFAULT 0
//         )
//       ''');

//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS sales (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           productName TEXT,
//           qty INTEGER,
//           price INTEGER,
//           total INTEGER,
//           date TEXT
//         )
//       ''');
//     }

//     if (oldVersion < 4) {
//       await db.execute('ALTER TABLE products ADD COLUMN otherqty INTEGER DEFAULT 0');
//     }

//     if (oldVersion < 5) {
//       await db.execute('ALTER TABLE products ADD COLUMN promo INTEGER DEFAULT 0');
//     }

//     if (oldVersion < 6) {
//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS users (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           username TEXT UNIQUE,
//           password TEXT,
//           role TEXT
//         )
//       ''');

//       final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));

//       if (count == 0) {
//         await db.insert('users', {
//           'username': 'admin',
//           'password': 'admin123',
//           'role': 'admin'
//         });
//       }
//     }

//     // Auto sync on upgrade
//     SyncService.instance.syncAll();
//   }

//   Future close() async {
//     final db = await instance.database;
//     db.close();
//   }

//   // ----------------- CRUD METHODS -------------------

//   // Products
//   Future<int> insertProduct(Product product) async {
//     final db = await instance.database;

//     final id = await db.insert('products', {
//       'name': product.name,
//       'price': product.price.toInt(),
//       'qty': product.qty,
//       'otherqty': product.otherqty,
//       'promo': product.promo ? 1 : 0,
//     });

//     SyncService.instance.syncAll();
//     return id;
//   }

//   Future<List<Product>> fetchProducts() async {
//     final db = await instance.database;
//     final result = await db.query('products');

//     return result.map((row) {
//       return Product(
//         id: row['id'] as int?,
//         name: row['name'] as String,
//         price: (row['price'] as int).toDouble(),
//         qty: row['qty'] as int,
//         otherqty: row['otherqty'] as int,
//         promo: (row['promo'] as int? ?? 0) == 1,
//       );
//     }).toList();
//   }

//   Future<void> updateProduct(Product product) async {
//     final db = await instance.database;

//     await db.update(
//       'products',
//       {
//         'name': product.name,
//         'price': product.price.toInt(),
//         'qty': product.qty,
//         'otherqty': product.otherqty,
//         'promo': product.promo ? 1 : 0,
//       },
//       where: 'id = ?',
//       whereArgs: [product.id],
//     );

//     SyncService.instance.syncAll();
//   }

//   Future<void> seedDefaultProducts() async {
//   final db = await instance.database;

//   final count = Sqflite.firstIntValue(
//       await db.rawQuery('SELECT COUNT(*) FROM products'));

//   // If table already has products, don't add again
//   if (count != null && count > 0) return;

//   // Insert default sample products
//   await db.insert('products', {
//     'name': 'Coke',
//     'price': 25,
//     'qty': 50,
//     'otherqty': 0,
//     'promo': 0,
//   });

//   await db.insert('products', {
//     'name': 'Piattos',
//     'price': 20,
//     'qty': 40,
//     'otherqty': 0,
//     'promo': 0,
//   });

//   print("DEFAULT PRODUCTS SEEDED");
// }


//   Future<void> deleteProduct(int productId) async {
//     final db = await instance.database;

//     await db.delete(
//       'products',
//       where: 'id = ?',
//       whereArgs: [productId],
//     );

//     SyncService.instance.syncAll();
//   }

//   // Sales
//   Future<int> insertSale(Sale sale) async {
//     final db = await instance.database;

//     final id = await db.insert('sales', {
//       'productName': sale.productName,
//       'qty': sale.qty,
//       'price': sale.price,
//       'total': sale.total,
//       'promoDiscount': sale.promoDiscount ?? 0,
//       'date': sale.date,
//     });

//     SyncService.instance.syncAll();
//     return id;
//   }

//   Future<List<Sale>> fetchAllSales() async {
//     final db = await instance.database;
//     final result = await db.query('sales');

//     return result.map((row) => Sale.fromMap(row)).toList();
//   }

//   Future<int> deleteSale(int id) async {
//     final db = await instance.database;

//     final result = await db.delete(
//       'sales',
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     SyncService.instance.syncAll();
//     return result;
//   }

//   /// ✅ Get sales filtered by date range
//   Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
//     final db = await instance.database;

//     final result = await db.query(
//       'sales',
//       where: 'date BETWEEN ? AND ?',
//       whereArgs: [start.toIso8601String(), end.toIso8601String()],
//       orderBy: 'date ASC',
//     );

//     return result.map((row) => Sale.fromMap(row)).toList();
//   }

//   // Users
//   Future<int> insertUser(String username, String password, String role) async {
//     final db = await instance.database;

//     final id = await db.insert('users', {
//       'username': username,
//       'password': password,
//       'role': role
//     });

//     SyncService.instance.syncAll();
//     return id;
//   }

//   Future<Map<String, dynamic>?> login(String username, String password) async {
//     final db = await instance.database;

//     final result = await db.query(
//       'users',
//       where: 'username = ? AND password = ?',
//       whereArgs: [username, password],
//     );

//     return result.isNotEmpty ? result.first : null;
//   }

//   Future<String?> getUserRole(String username) async {
//     final db = await instance.database;

//     final result = await db.query(
//       'users',
//       where: 'username = ?',
//       whereArgs: [username],
//     );

//     return result.isNotEmpty ? result.first['role'] as String : null;
//   }
// }
