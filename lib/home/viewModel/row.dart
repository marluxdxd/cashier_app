import 'package:cashier_app/home/viewModel/product.dart';

class RowData {
  Product? product;
  int qty = 0;

  bool promoApplied = false;   // ⭐ NEW FIELD ⭐

  RowData({this.product, this.qty = 0, this.promoApplied = false});
}
