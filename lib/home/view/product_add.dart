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
  bool promo = false; // default ON
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

                      // // 📤 Read the qty stored in controller
                      // ElevatedButton(
                      //   onPressed: () {
                      //     int otherqty = int.tryParse(qty1Controller.text) ?? 0;
                      //     print("Qty is: $otherqty");
                      //   },
                      //   child: Text("Get Qty"),
                      // ),

                      ElevatedButton(
                        onPressed: () async {
                          final products = await AppDB.instance.fetchProducts();
                          for (var p in products) {
                            print(
                              "${p.name} | ${p.qty} | ${p.otherqty} | ${p.price} | ${p.promo}",
                            );
                          }
                        },
                        child: Text("Print Products"),
                      ),
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
              decoration: InputDecoration(labelText: 'Price'),
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
