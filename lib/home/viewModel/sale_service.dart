import 'dart:io';
import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/sale.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashier_app/services/sync/sync_queue.dart';

class SaleService {
  final supabase = Supabase.instance.client;
  final _queue = SyncQueue.instance;

  // ---------------- INSERT SALE ----------------
  Future<int> insertSale(Sale sale) async {
    final db = await AppDB.instance.database;

    // Insert locally FIRST, mark pending
    final id = await db.insert('sales', {
      ...sale.toMap(),
      'pending': 1,       // mark as pending sync
    });

    print("🟡 Saved sale locally (pending): id=$id");

    // Queue sync to Supabase
    _queue.add(() async {
      if (await _isOnline()) {
        try {
          await supabase.from('sales').upsert([{
            'id': id,
            'productname': sale.productName,
            'qty': sale.qty,
            'price': sale.price,
            'total': sale.total,
            'promoDiscount': sale.promoDiscount,
            'date': sale.date,
          }]);

          // mark as synced locally
          await db.update(
            'sales',
            {'pending': 0},
            where: 'id = ?',
            whereArgs: [id],
          );

          print("✅ Sale synced to Supabase: id=$id");
        } catch (e) {
          print("⚠ Sale sync failed: $e");
        }
      } else {
        print("⚠ Offline → will retry syncing sale id=$id");
      }
    });

    return id;
  }

  // ---------------- CLEAR ALL SALES ----------------
  Future<void> clearAllSales() async {
    final db = await AppDB.instance.database;

    // Mark all sales as pending deletion
    await db.update('sales', {
     
    });

    print("🟡 Marked all sales as pending deletion locally");

    // Queue deletion for Supabase
    _queue.add(() async {
      if (await _isOnline()) {
        try {
          await supabase.from('sales').delete(); // deletes all rows in Supabase

          // After cloud deletion → remove fully from local DB
          await db.delete('sales');

          print("✅ All sales deleted from Supabase and local DB");
        } catch (e) {
          print("⚠ Failed to delete all sales from Supabase: $e");
        }
      } else {
        print("⚠ Offline → delete all sales will retry later");
      }
    });
  }

  // ---------------- HELPER: Check if online ----------------
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ---------------- GET SALES ----------------
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
}
