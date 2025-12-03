import 'dart:io';
import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  /// ---------------- EDIT PRODUCT ----------------
  Future<void> updateProductBoth(Product product) async {
    if (product.id == null) {
      print("❌ Cannot update product with null ID");
      return;
    }

    final db = await AppDB.instance.database;

    // 1️⃣ Update locally, mark as pending if offline
    try {
      await db.update(
        'products',
        {
          'name': product.name,
          'price': product.price.toInt(),
          'qty': product.qty,
          'otherqty': product.otherqty,
          'promo': product.promo ? 1 : 0,
          'pending': 1, // mark as pending
        },
        where: 'id = ?',
        whereArgs: [product.id!],
      );
      print("✅ Updated product locally: ${product.name} (ID: ${product.id})");
    } catch (e) {
      print("❌ Failed to update product locally: $e");
    }

    // 2️⃣ Update in Supabase if online
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
        print("🌐 Updated product in Supabase: ${product.name} (ID: ${product.id})");

        // ✅ mark local as synced
        await db.update(
          'products',
          {'pending': 0},
          where: 'id = ?',
          whereArgs: [product.id!],
        );
        print("✅ Local product marked as synced: ${product.name}");
      } catch (e) {
        print("❌ Supabase update failed for product ID ${product.id}: $e");
      }
    } else {
      print("⚠ Offline → product will sync later: ${product.name}");
    }
  }

  /// ---------------- DELETE PRODUCT ----------------
  Future<void> deleteProductBoth(int productId) async {
    final db = await AppDB.instance.database;

    // 1️⃣ Delete locally
    try {
      await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
      );
      print("✅ Deleted product locally with ID $productId");
    } catch (e) {
      print("❌ Failed to delete product locally: $e");
    }

    // 2️⃣ Delete in Supabase if online
    if (await _isOnline()) {
      try {
        await supabase.from('products').delete().eq('id', productId);
        print("🌐 Deleted product in Supabase with ID $productId");
      } catch (e) {
        print("❌ Supabase delete failed for product ID $productId: $e");
      }
    } else {
      print("⚠ Offline → cannot delete product from Supabase now. Will sync later.");
    }
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
