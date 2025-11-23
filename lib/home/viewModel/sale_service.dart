import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/sale.dart';

class SaleService {
  Future<int> insertSale(Sale sale) async {
    final db = await AppDB.instance.database;
    return await db.insert('sales', sale.toMap());
  }

  Future<List<Sale>> getSales() async {
  final db = await AppDB.instance.database;

  try {
    final result = await db.query('sales');

    return result.map((json) => Sale(
      id: json['id'] as int?,
      productName: json['productName'] as String,
      qty: json['qty'] as int,
      price: json['price'] as int,
      total: json['total'] as int,
      date: json['date'] as String,
    )).toList();
  } catch (e) {
    print("getSales() error: $e");
    return []; // return empty list to avoid crash
  }
}

  Future<List<Sale>> getSalesByDay(DateTime day) async {
  final db = await AppDB.instance.database;

  String start = DateTime(day.year, day.month, day.day).toIso8601String();
  String end = DateTime(day.year, day.month, day.day, 23, 59, 59).toIso8601String();

  final result = await db.query(
    'sales',
    where: 'date BETWEEN ? AND ?',
    whereArgs: [start, end],
  );

  return result.map((json) => Sale(
    id: json['id'] as int?,
    productName: json['productName'] as String,
    qty: json['qty'] as int,
    price: json['price'] as int,
    total: json['total'] as int,
    date: json['date'] as String,
  )).toList();
}

Future<List<Sale>> getSalesByWeek(DateTime date) async {
  final db = await AppDB.instance.database;

  DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
  DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

  final result = await db.query(
    'sales',
    where: 'date BETWEEN ? AND ?',
    whereArgs: [
      startOfWeek.toIso8601String(),
      endOfWeek.toIso8601String(),
    ],
  );

  return result.map((json) => Sale(
    id: json['id'] as int?,
    productName: json['productName'] as String,
    qty: json['qty'] as int,
    price: json['price'] as int,
    total: json['total'] as int,
    date: json['date'] as String,
  )).toList();
}

Future<List<Sale>> getSalesByMonth(DateTime date) async {
  final db = await AppDB.instance.database;

  DateTime start = DateTime(date.year, date.month, 1);
  DateTime end = DateTime(date.year, date.month + 1, 0);

  final result = await db.query(
    'sales',
    where: 'date BETWEEN ? AND ?',
    whereArgs: [
      start.toIso8601String(),
      end.toIso8601String(),
    ],
  );

  return result.map((json) => Sale(
    id: json['id'] as int?,
    productName: json['productName'] as String,
    qty: json['qty'] as int,
    price: json['price'] as int,
    total: json['total'] as int,
    date: json['date'] as String,
  )).toList();
}

Future<void> clearAllSales() async {
  final db = await AppDB.instance.database;
  await db.delete('sales');
}

}
