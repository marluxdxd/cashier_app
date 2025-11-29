// import 'package:cashier_app/home/viewModel/product.dart';
// import 'package:cashier_app/home/viewModel/sale.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';


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
//       version: 5,
//       onCreate: _createDB,
//       onUpgrade: _onUpgrade,
//     );
//   }

//   // Create ALL required tables
//   Future _createDB(Database db, int version) async {
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
//   }

//   // Auto-upgrade if tables do not exist
// Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
//   // Upgrade to version 3 logic (keep your old upgrade if needed)
//   if (oldVersion < 3) {
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS products (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT,
//         price INTEGER,
//         qty INTEGER DEFAULT 0
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS sales (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         productName TEXT,
//         qty INTEGER,
//         price INTEGER,
//         total INTEGER,
//         date TEXT
//       )
//     ''');
//   }

//   // Upgrade to version 4: add new column 'otherqty'
//   if (oldVersion < 4) {
//     await db.execute('''
//       ALTER TABLE products ADD COLUMN otherqty INTEGER DEFAULT 0
//     ''');
//   }

//    // Upgrade to version 5: add promo column
//   if (oldVersion < 5) {
//     await db.execute('''
//       ALTER TABLE products ADD COLUMN promo INTEGER DEFAULT 0
//     ''');
//   }
// }


//   Future close() async {
//     final db = await instance.database;
//     db.close();
//   }

//   // Insert a product
//   Future<int> insertProduct(Product product) async {
//     final db = await instance.database;
//     return await db.insert('products', {
//       'name': product.name,
//       'price': product.price.toInt(),
//       'qty': product.qty,
//       'otherqty': product.otherqty,
//       'promo': product.promo ? 1 : 0, // NEW
//     });
//   }

//   // Fetch all products
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
//         promo: (row['promo'] as int? ?? 0) == 1, // NEW
//       );
//     }).toList();
//   }

  

//   // Update product
//   Future<void> updateProduct(Product product) async {
//     final db = await instance.database;
//     await db.update(
//       'products',
//       {
//         'name': product.name,
//         'price': product.price.toInt(),
//         'qty': product.qty,
//       },
//       where: 'id = ?',
//       whereArgs: [product.id],
//     );
//   }

//   // Delete product
//   Future<void> deleteProduct(int productId) async {
//     final db = await instance.database;
//     await db.delete(
//       'products',
//       where: 'id = ?',
//       whereArgs: [productId],
//     );
//   }

//   // DELETE a sale transaction
// Future<int> deleteSale(int id) async {
//   final db = await instance.database;
//   return await db.delete(
//     'sales',
//     where: 'id = ?',
//     whereArgs: [id],
//   );
// }


//   Future<void> seedDefaultProducts() async {}



// Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
//     final db = await AppDB.instance.database;
    
//     final result = await db.query(
//       'sales',
//       where: 'date BETWEEN ? AND ?',
//       whereArgs: [start.toIso8601String(), end.toIso8601String()],
//       orderBy: 'date ASC',
//     );

//     return result.map((row) => Sale.fromMap(row)).toList();
//   }

//   // ... other SaleService methods



// }
