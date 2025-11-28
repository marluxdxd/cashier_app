import 'package:flutter/material.dart';

class CustomerCashField extends StatelessWidget {
  final TextEditingController controller;
  final int totalBill;
  final bool transactionSaved;
  final VoidCallback saveTransaction;

  // NEW: accept focus node
  final FocusNode? focusNode;

  const CustomerCashField({
    super.key,
    required this.controller,
    required this.totalBill,
    required this.transactionSaved,
    required this.saveTransaction,
    this.focusNode, // NEW
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,               // NEW
      autofocus: true,                    // NEW
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "Customer Cash",
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        // refresh UI
        (context as Element).markNeedsBuild();

        int customerCash = int.tryParse(value) ?? 0;

        if (totalBill == 0) return; // no products, do nothing

        if (customerCash < totalBill) {
          print("Cash is not enough yet.");
          return;
        }

        if (!transactionSaved) {
          saveTransaction(); // auto save
        }
      },
    );
  }
}
