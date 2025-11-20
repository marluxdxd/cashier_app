// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:cashier_app/data/row_data.dart';
// import '../home/viewModel/product.dart';



// class DBHelper {
//   static final DBHelper _instance = DBHelper._internal();
//   factory DBHelper() => _instance;
//   DBHelper._internal();

//   static Database? _db;

//   Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await _initDB();
//     return _db!;
//   }

//   Future<Database> _initDB() async {
//     String path = join(await getDatabasesPath(), 'cashier.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE orders(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             qty INTEGER,
//             productName TEXT,
//             price REAL,
//             date TEXT
//           )
//         ''');
//       },
//     );
//   }

//   // Insert a RowData into DB
//   Future<int> insertRow(RowData row) async {
//     final db = await database;
//     return await db.insert('orders', {
//       'qty': row.qty,
//       'productName': row.product?.name,
//       'price': row.product?.price,
//       'date': row.date.toIso8601String(),
//     });
//   }

//   // Get all rows from DB as List<RowData>
//   Future<List<RowData>> getRows() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('orders');

//     return List.generate(maps.length, (i) {
//       return RowData(
//         qty: maps[i]['qty'] ?? 0,
//         product: maps[i]['productName'] != null
//             ? Product(
//                 name: maps[i]['productName'],
//                 price: (maps[i]['price'] as num).toDouble(),
//               )
//             : null,
//         date: maps[i]['date'] != null
//             ? DateTime.parse(maps[i]['date'])
//             : DateTime.now(),
//       );
//     });
//   }

//   // Delete all rows
//   Future<void> clearAll() async {
//     final db = await database;
//     await db.delete('orders');
//   }
// }
