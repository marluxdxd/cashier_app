import 'package:cashier_app/home/viewModel/product.dart';
import 'package:flutter/material.dart';

class RowData {
  Product? product;
  int qty = 0;
  bool promoApplied;
  String discountType; // <-- ADD THIS

  // ⭐ Needed for searchable text field
  TextEditingController productController = TextEditingController();

  RowData({
    this.product,
    this.qty = 0,
    this.promoApplied = false,
    this.discountType = "none",
  });
}
