
import 'package:cashier_app/home/viewModel/product_model.dart';
import 'package:sqflite/sqflite.dart';

class ProductService {
  final Database db;

  ProductService(this.db);

  // Insert a new product
  Future<int> insertProduct(ProductModel product) async {
    return await db.insert('products', product.toMap());
  }

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }
}


