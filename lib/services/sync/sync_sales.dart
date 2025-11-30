import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../database/app_db.dart';

class SalesSync {
  final supabase = Supabase.instance.client;

  Future<void> upload() async {
    final db = await AppDB.instance.database;
    final rows = await db.query('sales');

    for (var row in rows) {
      await supabase.from('sales').upsert({
        'id': row['id'],
        'product_name': row['productName'],
        'qty': row['qty'],
        'price': row['price'],
        'total': row['total'],
        'promo_discount': row['promoDiscount'],
        'date': row['date'],
      });
    }
  }

  Future<void> download() async {
    final db = await AppDB.instance.database;
    final data = await supabase.from('sales').select('*');

    for (var item in data) {
      await db.insert('sales', {
        'id': item['id'],
        'productName': item['product_name'],
        'qty': item['qty'],
        'price': item['price'],
        'total': item['total'],
        'promoDiscount': item['promo_discount'],
        'date': item['date'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
