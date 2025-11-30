import 'dart:io';
import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/sale.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleService {
  final supabase = Supabase.instance.client;

  

  // INSERT SALE (local + remote)
  Future<int> insertSale(Sale sale) async {
    final db = await AppDB.instance.database;

    // 1️⃣ Insert locally
    final id = await db.insert('sales', sale.toMap());

    // 2️⃣ Try to sync with Supabase if online
    if (await _isOnline()) {
      try {
        await supabase.from('sales').upsert([
          {
            'id': id,
            'productname': sale.productName,
            'qty': sale.qty,
            'price': sale.price,
            'total': sale.total,
            'promoDiscount': sale.promoDiscount,
            'date': sale.date,
          }
        ]);
      } catch (e) {
        print("Supabase upsert failed for sale id $id: $e");
      }
    }

    return id;
  }

  // GET ALL SALES
  Future<List<Sale>> getSales() async {
    try {
      final db = await AppDB.instance.database;
      final result = await db.query('sales');
      return result.map((json) => Sale.fromMap(json)).toList();
    } catch (e) {
      print("getSales() error: $e");
      return [];
    }
  }

  // GET SALES BY DAY
  Future<List<Sale>> getSalesByDay(DateTime day) async {
    try {
      final db = await AppDB.instance.database;
      final start = DateTime(day.year, day.month, day.day).toIso8601String();
      final end = DateTime(day.year, day.month, day.day, 23, 59, 59).toIso8601String();

      final result = await db.query(
        'sales',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [start, end],
      );

      return result.map((json) => Sale.fromMap(json)).toList();
    } catch (e) {
      print("getSalesByDay() error: $e");
      return [];
    }
  }

  // GET SALES BY WEEK
  Future<List<Sale>> getSalesByWeek(DateTime date) async {
    try {
      final db = await AppDB.instance.database;
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final result = await db.query(
        'sales',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startOfWeek.toIso8601String(), endOfWeek.toIso8601String()],
      );

      return result.map((json) => Sale.fromMap(json)).toList();
    } catch (e) {
      print("getSalesByWeek() error: $e");
      return [];
    }
  }

  // GET SALES BY MONTH
  Future<List<Sale>> getSalesByMonth(DateTime date) async {
    try {
      final db = await AppDB.instance.database;
      final start = DateTime(date.year, date.month, 1);
      final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

      final result = await db.query(
        'sales',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
      );

      return result.map((json) => Sale.fromMap(json)).toList();
    } catch (e) {
      print("getSalesByMonth() error: $e");
      return [];
    }
  }

  // CLEAR ALL SALES
  Future<void> clearAllSales() async {
    try {
      final db = await AppDB.instance.database;
      await db.delete('sales');
    } catch (e) {
      print("clearAllSales() error: $e");
    }
  }

  // HELPER: Check if device is online
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
