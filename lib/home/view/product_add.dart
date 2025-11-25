import 'package:flutter/material.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/database/app_db.dart';

class AddProduct extends StatefulWidget {
  final VoidCallback? onProductAdded;

  const AddProduct({super.key, this.onProductAdded});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  TextEditingController retainPriceController = TextEditingController();
  bool promo = false; // default ON
  int test = 0;
  // 📦 This box will store our qty value
  TextEditingController qtyController = TextEditingController();
  TextEditingController qty1Controller = TextEditingController();

  void addProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: nameController.text,
        price: double.tryParse(priceController.text) ?? 0,
        qty: int.tryParse(qtyController.text) ?? 0, // ✅ Save qty
        otherqty: int.tryParse(qty1Controller.text) ?? 0, // ✅ Save qty
        promo: promo, // ✅ set from IconButton
        
      );

      // Insert product into database
      await AppDB.instance.insertProduct(product);

      // 🔔 Notify parent to refresh immediately
      if (widget.onProductAdded != null) {
        widget.onProductAdded!();
      }

      // ✅ Clear fields to add next product
      nameController.clear();

      priceController.clear();
      qtyController.clear();
      qty1Controller.clear();
      retainPriceController.clear();

      qtyController.text = "";
      qty1Controller.text = "";

      // ✅ Optional: Focus back to the name field
      FocusScope.of(context).requestFocus(FocusNode());

      // Show a small SnackBar or message for confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added! You can add another.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Product'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.local_offer,
                    color: promo ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      promo = !promo; // toggle on/off
                    });
                  },
                ),
                SizedBox(width: 10), // spacing
                Expanded(
                  child: Column(
                    children: [
                      // 📝 User types here, controller stores the value
                      TextFormField(
                        controller: qty1Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Other Qty'),
                      ),
 Text(
              'ex, Buy 3: Stick-O Price 2 = 5',
              style: TextStyle(fontSize: 11.5, color: Colors.grey),
            ),
          
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     // 1️⃣ Get user input safely
                      //     int step =
                      //         int.tryParse(qty1Controller.text) ??
                      //         2; // default 1
                      //     if (step <= 0) step = 2; // prevent infinite loop

                      //     // 2️⃣ Fetch products from DB
                      //     final products = await AppDB.instance.fetchProducts();

                      //     // 3️⃣ Loop through products and calculate multiples
                      //     for (var p in products) {
                      //       if (p.promo) {
                      //         print("Calculated multiples for ${p.name}:");
                      //         for (int i = step; i <= 20; i += step) {
                      //           print(
                      //             "${p.name} | ${p.qty} | ${p.otherqty} | ${p.price} | ${p.promo} | ${i}",
                      //           );
                      //         }
                      //       }
                      //     }
                      //   },
                      //   child: Text("Debug Console"),
                      // ),
                    ],
                  ),
                ),
              ],
            ),

            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a product name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Sale Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
               TextFormField(
  controller: retainPriceController,
  decoration: InputDecoration(labelText: 'Retain Price'),
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    if (double.tryParse(value) == null) {
      return 'Enter a valid number';
    }
    return null;
  },
),

            SizedBox(height: 20),
            Text(
              'Note: After adding, you can add another product immediately.',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: addProduct, child: Text('Add')),
      ],
    );
  }
}
