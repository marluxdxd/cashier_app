import 'package:cashier_app/database/product_service.dart';
import 'package:cashier_app/home/viewModel/product_service.dart';
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
   int? selectedPromo; // null initially
  // 📦 This box will store our qty value
  TextEditingController qtyController = TextEditingController();
  TextEditingController qty1Controller = TextEditingController();

  void addProduct() async {
  if (_formKey.currentState!.validate()) {
    final product = Product(
      name: nameController.text,
      price: double.tryParse(priceController.text) ?? 0,
      qty: int.tryParse(qtyController.text) ?? 0,
      otherqty: int.tryParse(qty1Controller.text) ?? 0,
      promo: promo,
    );

    // SAVE LOCAL + SUPABASE
    await ProductService().insertProductBoth(product);

    // Notify parent
    widget.onProductAdded?.call();

    // Reset fields
    nameController.clear();
    priceController.clear();
    qtyController.clear();
    qty1Controller.clear();
    retainPriceController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product added and synced when online!')),
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
            

// Inside your widget:


// Optional: s  how a colored icon next to the radio
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    GestureDetector(
      onTap: () {
        setState(() {
          promo = !promo;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '-1',
            style: TextStyle(fontSize: 10),
          ),
          Icon(
            promo ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18, // small size
          ),
          Text(
            '-1',
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    ),
  ],
),
                SizedBox(width: 10), // spacing
                Expanded(
                  child: Column(
                    children: [
                      // 📝 User types here, controller stores the value
                      TextFormField(
                        controller: qty1Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Enter number'),
                      ),
 Text(
              'Note: if you check promo will be activate(leave a blank if none)',
              style: TextStyle(fontSize: 10, color: Colors.grey),
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
