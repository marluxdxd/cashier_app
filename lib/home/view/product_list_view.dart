import 'package:flutter/material.dart';
import 'package:cashier_app/database/app_db.dart';  // AppDB for fetching data
import 'package:cashier_app/home/viewModel/product.dart';  // Product class

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // Fetch products from DB
  void loadProducts() async {
    final productsFromDB = await AppDB.instance.fetchProducts();
    setState(() {
      products = productsFromDB;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Products"),
      ),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())  // Show loader while fetching
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return ListTile(
                  title: Text(product.name),  // Display product name
                  subtitle: Text('Price: ₱${product.price.toString()}'),
                  trailing: Text('ID: ${product.id ?? '-'}'),
                );
              },
            ),
    );
  }
}
