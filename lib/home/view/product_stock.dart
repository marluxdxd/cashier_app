import 'package:flutter/material.dart';
import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/product.dart';

class ProductStock extends StatefulWidget {
  const ProductStock({super.key});

  @override
  State<ProductStock> createState() => _ProductStockState();
}

class _ProductStockState extends State<ProductStock> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() async {
    final productsFromDB = await AppDB.instance.fetchProducts();
    setState(() {
      products = productsFromDB;
      filteredProducts = products;
    });
  }

  void filterProducts(String query) {
    final filtered = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredProducts = filtered;
    });
  }

  void editQty(Product product) {
    TextEditingController qtyController =
        TextEditingController(text: product.qty.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Quantity"),
          content: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Quantity"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  product.qty = int.tryParse(qtyController.text) ?? product.qty;
                });
                AppDB.instance.updateProduct(product); // Update DB
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Stocks', style: TextStyle(fontSize: 16)),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
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
                onChanged: (value) => filterProducts(value),
              ),
              SizedBox(height: 15),

              // Table for Qty, Item, Action
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    0: IntrinsicColumnWidth(),
                    1: IntrinsicColumnWidth(),
                    2: IntrinsicColumnWidth(),
                  },
                  children: [
                    // Header row
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    // Product rows
                    ...filteredProducts.map((product) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(product.qty.toString()),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(product.name),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => editQty(product),
                              ),
                            ],
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
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}
