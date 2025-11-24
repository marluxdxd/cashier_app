import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/discount_minus_one.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/home/viewModel/row.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class ProductManual extends StatefulWidget {
  const ProductManual({super.key});

  @override
  State<ProductManual> createState() => _ProductManualState();
}

class _ProductManualState extends State<ProductManual> {
  List<Product> dbProducts = [];

  // local row holder
  RowData row = RowData(
    qty: 0,
    discountType: "none",
  );

  @override
  void initState() {
    super.initState();
    loadProducts(); 
  }

  Future<void> loadProducts() async {
  final products = await AppDB.instance.fetchProducts();

  setState(() {
    dbProducts = products;
  });
}

  int calculateTotal(RowData row) {
    if (row.product == null) return 0;

    int qty = row.qty;
    int price = row.product!.price.toInt();

    if (row.discountType == "minus1") {
      int result = DiscountMinusOne.apply(qty, price);
      if (result == -1) return 0; // invalid qty (must be 3)
      return result;
    }

    return qty * price;
  }

  @override
  Widget build(BuildContext context) {
    int total = calculateTotal(row);

    return AlertDialog(
      title: Text("BUY 3PCS DISCOUNT 1 PESO", style: TextStyle(fontSize: 12)),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QTY dropdown
            DropdownButton<int>(
              isExpanded: true,
              hint: Text("Select Qty"),
              value: row.qty == 0 ? null : row.qty,
              items: List.generate(10, (index) {
                int number = index + 1;
                return DropdownMenuItem(
                  value: number,
                  child: Text(number.toString()),
                );
              }),
              onChanged: (value) {
                setState(() {
                  row.qty = value ?? 0;
                });
              },
            ),

            SizedBox(height: 10),

            // Product dropdown
         DropdownSearch<Product>(
              items: dbProducts, // list of products
              itemAsString: (p) => p.name, // display product name
            
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: "Select ",
                  border: OutlineInputBorder(),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true, // enable search
                searchFieldProps: TextFieldProps(
                  autofocus: true, // focus the search box immediately
                  decoration: InputDecoration(
                    hintText: 'Search product...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                itemBuilder: (context, item, isSelected) {
                  return ListTile(title: Text(item.name));
                },
              ),
            ),

            SizedBox(height: 10),

            // Discount dropdown
            DropdownButton<String>(
              value: row.discountType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: "none",
                  child: Text("No Discount"),
                ),
                DropdownMenuItem(
                  value: "minus1",
                  child: Text("DISCOUNT -1 (Qty must be 3)"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  row.discountType = value!;
                });
              },
            ),

            SizedBox(height: 10),

            // Show error if qty not allowed
            if (row.discountType == "minus1" && row.qty != 3)
              Text(
                "Qty must be exactly 3 for this discount!",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),

            SizedBox(height: 15),

            // Total
            Text(
              "TOTAL: ₱$total",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, row); // return row values
          },
          child: Text("Save"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Close"),
        ),
      ],
    );
  }
}
