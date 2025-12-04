import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../database/app_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cashier_app/services/sync/sync_queue.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  Timer? _timer;
  bool _isSyncing = false;

  SyncService._init();

  final supabase = Supabase.instance.client;
  final _queue = SyncQueue.instance; // 👈 ADD THIS


//Delete both sqflite and supabase
  Future<void> deleteSaleBoth(int id) async {
    final db = await AppDB.instance.database;

    // 1️⃣ Delete locally
    await db.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );

    // 2️⃣ Delete in Supabase
    if (await _isOnline()) {
      try {
        _queue.add(() async {
  await supabase.from('sales').delete().eq('id', id);
});

        print("Deleted in Supabase");
      } catch (e) {
        print("Supabase delete failed: $e");
      }
    } else {
      print("Offline → cannot delete from Supabase");
    }
  }

  // 🔽 KEEP THIS — needed by deleteSaleBoth()
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }



  

  // --------------------------
  // START AUTO-SYNC
  // --------------------------
  void startAutoSync({int intervalSeconds = 30}) {
  // 1️⃣ Periodic sync
  _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
    if (await _isOnline()) {
      await syncAll();
    }
  });

  // 2️⃣ Listen for connectivity changes
  Connectivity().onConnectivityChanged.listen((status) async {
    if (status != ConnectivityResult.none) {
      await syncAll();
    }
  });

  print("AUTO SYNC STARTED ⏱️");
}


  // --------------------------
  // SYNC EVERYTHING
  // --------------------------
 Future<void> syncAll() async {
  if (_isSyncing) return;
  _isSyncing = true;

  try {
    // 1️⃣ Upload local changes to cloud first
    await syncProductsUpload();
    await syncSalesUpload();
    await syncUsersUpload();

    // 2️⃣ Download cloud changes to local (optional, ensures cloud changes are reflected)
    await syncProductsDownload();
    await syncSalesDownload();
    await syncUsersDownload();

    print("SYNC COMPLETE ✅");
  } catch (e) {
    print("SYNC ERROR → $e");
  }

  _isSyncing = false;
}


  // --------------------------
  // UPLOAD FROM LOCAL → CLOUD
  // --------------------------
  Future<void> syncProductsUpload() async {
    final db = await AppDB.instance.database;
    final rows = await db.query('products');

    for (var row in rows) {
      await supabase.from('products').upsert({
        'id': row['id'],
        'name': row['name'],
        'price': row['price'],
        'qty': row['qty'],
        'otherqty': row['otherqty'],
        'promo': row['promo'] == 1,
      });
    }
  }

  Future<void> syncSalesUpload() async {
    final db = await AppDB.instance.database;
    final rows = await db.query('sales');

    for (var row in rows) {
      await supabase.from('sales').upsert({
        'id': row['id'],
        'productname': row['productName'], // match Supabase
        'qty': row['qty'],
        'price': row['price'],
        'total': row['total'],
        'promodiscount': row['promoDiscount'],
        'date': row['date'],
      });
    }
  }

  Future<void> syncUsersUpload() async {
    final db = await AppDB.instance.database;
    final rows = await db.query('users');

    for (var row in rows) {
      await supabase.from('users').upsert({
        'id': row['id'],
        'username': row['username'],
        'password': row['password'],
        'role': row['role'],
      });
    }
  }

  // --------------------------
  // DOWNLOAD FROM CLOUD → LOCAL
  // --------------------------
  Future<void> syncProductsDownload() async {
    final db = await AppDB.instance.database;

    final cloud = await supabase.from('products').select();

    for (var item in cloud) {
      await db.insert('products', {
        'id': item['id'],
        'name': item['name'],
        'price': item['price'],
        'qty': item['qty'],
        'otherqty': item['otherqty'],
        'promo': item['promo'] ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> syncSalesDownload() async {
    final db = await AppDB.instance.database;

    final cloud = await supabase.from('sales').select();

    for (var item in cloud) {
      await db.insert('sales', {
        'id': item['id'],
        'productname': item['productname'], // match local SQLite
        'qty': item['qty'],
        'price': item['price'],
        'total': item['total'],
        'promodiscount': item['promodiscount'],
        'date': item['date'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> syncUsersDownload() async {
    final db = await AppDB.instance.database;

    final cloud = await supabase.from('users').select();

    for (var item in cloud) {
      await db.insert('users', {
        'id': item['id'],
        'username': item['username'],
        'password': item['password'],
        'role': item['role'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
