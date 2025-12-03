import 'package:flutter/material.dart';
import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/home/viewModel/product_service.dart';

class SearchProduct extends StatefulWidget {
  const SearchProduct({super.key});

  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // Load products from local DB
  Future<void> loadProducts() async {
    final productsFromDB = await AppDB.instance.fetchProducts();
    setState(() {
      products = productsFromDB;
      filteredProducts = products;
    });
  }

  // Filter products by search
  void filterProducts(String query) {
    final filtered = products.where((p) {
      return p.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredProducts = filtered;
    });
  }

  // Edit product
  void editProduct(Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController =
        TextEditingController(text: product.price.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Product Price"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              product.name = nameController.text;
              product.price =
                  double.tryParse(priceController.text) ?? product.price;

              // Update local + Supabase
              await ProductService().updateProductBoth(product);

              // Refresh list
              await loadProducts();

              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // Confirm delete
  void confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text("Do you really want to delete ${product.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Delete local + Supabase
              await ProductService().deleteProductBoth(product.id!);

              // Refresh list
              await loadProducts();

              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Display all products', style: TextStyle(fontSize: 12)),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search products",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: filterProducts,
              ),
              SizedBox(height: 15),

              // Scrollable table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    0: IntrinsicColumnWidth(),
                    1: IntrinsicColumnWidth(),
                    2: IntrinsicColumnWidth(),
                    3: IntrinsicColumnWidth(),
                    4: IntrinsicColumnWidth(),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Padding(
                            padding: EdgeInsets.all(6), child: Text('Qty')),
                        Padding(
                            padding: EdgeInsets.all(6), child: Text('Item')),
                        Padding(
                            padding: EdgeInsets.all(6), child: Text('Price')),
                        Padding(
                            padding: EdgeInsets.all(6), child: Text('Total')),
                        Padding(
                            padding: EdgeInsets.all(6), child: Text('Action')),
                      ],
                    ),
                    ...filteredProducts.map((product) {
                      return TableRow(
                        children: [
                          Padding(
                              padding: EdgeInsets.all(6),
                              child: Text(product.qty.toString())),
                          Padding(
                              padding: EdgeInsets.all(6),
                              child: Text(product.name)),
                          Padding(
                              padding: EdgeInsets.all(6),
                              child: Text('₱${product.price}')),
                          Padding(
                              padding: EdgeInsets.all(6),
                              child: Text('₱${product.qty * product.price}')),
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => editProduct(product),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => confirmDeleteProduct(product),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text('Close')),
      ],
    );
  }
}
