import 'package:cashier_app/home/viewModel/product_service.dart';

class Product {
  int? id;
  int qty;
  int otherqty;
  String name;
  double price;
  double retainprice;
  bool promo;
  int? fixedQty;
  bool promoApplied;
int pending; // 0 or 1


  Product({
    this.id,
    this.qty = 0,
    this.otherqty = 0,
    required this.name,
    required this.price,
    this.retainprice = 0,
    this.promo = false,
    this.fixedQty,
    this.promoApplied = false,
    this.pending = 0,

  });

  double get total => qty * price;
  double get totals => otherqty * price;

  /// Reduce stock + sync local + Supabase
  Future<void> reduceStock(int soldQty) async {
    if (qty <= 0) throw Exception("$name: No stock");
    if (soldQty > qty) throw Exception("$name: Not enough stock");

    qty -= soldQty;
    pending = 1; // mark as changed

    if (id != null) {
      await ProductService().updateProductBoth(this);
    }
  }

  /// Add stock + sync local + Supabase
  Future<void> addStock(int addedQty) async {
    if (addedQty <= 0) return;

    qty += addedQty;
    pending = 1; // mark as changed

    if (id != null) {
      await ProductService().updateProductBoth(this);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
