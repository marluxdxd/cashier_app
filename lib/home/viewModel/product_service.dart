import 'dart:convert';
import 'dart:io';
import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/services/sync/sync_queue.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;
  final _queue = SyncQueue.instance;


  /// ---------------- ADD PRODUCT ----------------
Future<void> insertProductBoth(Product product) async {
  final db = await AppDB.instance.database;

  // Step 1: Insert locally FIRST
  final localId = await db.insert('products', {
    'name': product.name,
    'price': product.price.toInt(),
    'qty': product.qty,
    'otherqty': product.otherqty,
    'Promo': product.promo ? 1 : 0,
    'pending': 1,
    'deleted': 0,
    'pending_delete': 0,
  });

  print("🟡 Saved locally (pending): id=$localId");

  // Step 2: Queue Supabase insert
  _queue.add(() async {
    try {
      // Insert to Supabase (NO id included)
      final response = await supabase.from('products').insert({
        'name': product.name,
        'price': product.price.toInt(),
        'qty': product.qty,
        'otherqty': product.otherqty,
        'promo': product.promo,
      }).select(); // ◀ returns inserted row!

      if (response.isNotEmpty) {
        final supabaseId = response[0]['id'];

        // Step 3: Update local row with real Supabase ID
        await db.update(
          'products',
          {
            'pending': 0,
            'id': supabaseId,
          },
          where: 'id = ?',
          whereArgs: [localId],
        );

        print("✅ Synced + Updated ID: local=$localId → supabase=$supabaseId");
      }
    } catch (e) {
      print("❌ Insert sync failed: $e");
      print("⚠ Will retry later...");
    }
  });
}







  /// ---------------- EDIT PRODUCT ----------------
Future<void> updateProductBoth(Product product) async {
  if (product.id == null) return;

  final db = await AppDB.instance.database;

  // Update locally and mark pending
  await db.update(
    'products',
    {
      'name': product.name,
      'price': product.price.toInt(),
      'qty': product.qty,
      'otherqty': product.otherqty,
      'promo': product.promo ? 1 : 0,
      'pending': 1,
    },
    where: 'id = ?',
    whereArgs: [product.id!],
  );
  print("✅ Updated locally: ${product.name}");

  // Add to queue
  _queue.add(() async {
    if (await _isOnline()) {
      try {
        await supabase.from('products').upsert([
          {
            'id': product.id!,
            'name': product.name,
            'price': product.price.toInt(),
            'qty': product.qty,
            'otherqty': product.otherqty,
            'promo': product.promo,
          }
        ]);
        // mark synced
        await db.update(
          'products',
          {'pending': 0},
          where: 'id = ?',
          whereArgs: [product.id!],
        );
        print("✅ Synced product: ${product.name}");
      } catch (e) {
        print("⚠ Failed to sync product ${product.name}: $e");
      }
    } else {
      print("⚠ Offline → will retry sync for ${product.name}");
    }
  });
}

/// ---------------- DELETE PRODUCT ----------------
Future<void> deleteProductBoth(int productId) async {
  final db = await AppDB.instance.database;

  // Soft delete in local DB
  await db.update(
    'products',
    {
      'deleted': 1,    // mark as deleted locally
      'pending': 2     // mark as pending delete
    },
    where: 'id = ?',
    whereArgs: [productId],
  );

  print("🟡 Local soft delete: $productId");

  // Queue the delete for online sync
  _queue.add(() async {
    if (await _isOnline()) {
      try {
        await supabase.from('products').delete().eq('id', productId);

        // After cloud delete → remove fully from local DB
        await db.delete(
          'products',
          where: 'id = ?',
          whereArgs: [productId],
        );

        print("✅ Synced delete to Supabase: $productId");
      } catch (e) {
        print("⚠ Cloud delete failed: $e");
      }
    } else {
      print("⚠ Offline → delete will retry: $productId");
    }
  });
}




  /// ---------------- HELPER ----------------
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
