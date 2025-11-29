import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home/viewModel/sale.dart';
import '../home/viewModel/product.dart';
import '../database/app_db.dart';
import 'package:sqflite/sqflite.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  Timer? _timer;
  bool _isSyncing = false;

  SyncService._init();

  final supabase = Supabase.instance.client;

  // --------------------------
  // START AUTO-SYNC
  // --------------------------
  void startAutoSync() {
    // Sync every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 30), (_) {
      syncAll();
    });

    // Listen to internet connection
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        syncAll();
      }
    });

    print("AUTO SYNC STARTED");
  }

  // --------------------------
  // SYNC EVERYTHING
  // --------------------------
  Future<void> syncAll() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      await syncProductsUpload();
      await syncSalesUpload();
      await syncUsersUpload();

      await syncProductsDownload();
      await syncSalesDownload();
      await syncUsersDownload();

      print("SYNC COMPLETE");
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
        'productName': row['productName'],
        'qty': row['qty'],
        'price': row['price'],
        'total': row['total'],
        'promoDiscount': row['promoDiscount'],
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
        'productName': item['productName'],
        'qty': item['qty'],
        'price': item['price'],
        'total': item['total'],
        'promoDiscount': item['promoDiscount'],
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
