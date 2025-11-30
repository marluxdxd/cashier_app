import 'dart:io';
import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  // Supabase client instance
  final supabase = Supabase.instance.client;

  /// Code for EDIT PRODUCT FROM LOCAL DATABASE + SUPABASE

  /// DELETE PRODUCT FROM LOCAL DATABASE + SUPABASE
  Future<void> deleteProductBoth(int productId) async {
    final db = await AppDB.instance.database;

    // 1️⃣ Delete product locally
    try {
      await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
      );
      print("Deleted product locally with ID $productId");
    } catch (e) {
      print("Failed to delete product locally: $e");
    }

    // 2️⃣ Delete product in Supabase if online
    if (await _isOnline()) {
      try {
        await supabase.from('products').delete().eq('id', productId);
        print("Deleted product in Supabase with ID $productId");
      } catch (e) {
        print("Supabase delete failed for product id $productId: $e");
      }
    } else {
      print("Offline → cannot delete product from Supabase");
    }
  }

  /// UPDATE PRODUCT IN LOCAL DATABASE + SUPABASE
 Future<void> updateProductBoth(Product product) async {
  // ✅ Ensure product has an ID before updating
  if (product.id == null) {
    print("❌ Cannot update product with null ID");
    return;
  }

  final db = await AppDB.instance.database;

  // 1️⃣ Update locally
  try {
    await db.update(
      'products',
      {
        'name': product.name,
        'price': product.price.toInt(),
        'qty': product.qty,
        'otherqty': product.otherqty,
        'promo': product.promo ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [product.id!], // ✅ Use non-null assertion
    );
    print("Updated product locally with ID ${product.id}");
  } catch (e) {
    print("Failed to update product locally: $e");
  }

  // 2️⃣ Update in Supabase if online
  if (await _isOnline()) {
    try {
      await supabase.from('products').upsert([
        {
          'id': product.id!, // ✅ non-null
          'name': product.name,
          'price': product.price.toInt(), // ✅ convert double to int
          'qty': product.qty,
          'otherqty': product.otherqty,
          'promo': product.promo,
        }
      ]);
      print("Updated product in Supabase with ID ${product.id}");
    } catch (e) {
      print("Supabase update failed for product ID ${product.id}: $e");
    }
  }
}


  // HELPER: check internet connectivity
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
