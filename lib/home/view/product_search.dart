import 'package:flutter/material.dart';
import 'package:cashier_app/database/app_db.dart'; // Import AppDB for fetching products
import 'package:cashier_app/home/viewModel/product.dart'; // Import the Product class

class SearchProduct extends StatefulWidget {
  const SearchProduct({super.key});

  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  List<Product> products = []; // List to hold all products
  List<Product> filteredProducts =
      []; // List for filtered products based on search
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts(); // Fetch products when the widget is initialized
  }

  // Fetch all products from the database
  void loadProducts() async {
    final productsFromDB = await AppDB.instance.fetchProducts();
    setState(() {
      products = productsFromDB;
      filteredProducts = products; // Initially, show all products
    });
  }

  // Filter products based on search query
  void filterProducts(String query) {
    final filtered = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredProducts = filtered; // Update filtered products
    });
  }

  // Edit product function
  void editProduct(Product product) {
    TextEditingController nameController = TextEditingController(
      text: product.name,
    );
    TextEditingController priceController = TextEditingController(
      text: product.price.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              onPressed: () {
                setState(() {
                  product.name = nameController.text;
                  product.price =
                      double.tryParse(priceController.text) ?? product.price;
                });
                AppDB.instance.updateProduct(product); // Update product in DB
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

  // Show confirmation dialog before deleting the product
  void confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you really want to delete this product?'),
          actions: [
            // Cancel button - closes the dialog without deleting
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            // Confirm button - proceeds with deletion
            TextButton(
              onPressed: () {
                deleteProduct(product.id!); // Delete the product if confirmed
                Navigator.pop(context); // Close the dialog after deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete product function - removes from both UI and DB
  void deleteProduct(int productId) {
    setState(() {
      products.removeWhere((product) => product.id == productId);
      filteredProducts.removeWhere((product) => product.id == productId);
    });

    AppDB.instance.deleteProduct(productId); // Delete from DB
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Display all products', style: TextStyle(fontSize: 10)),
      content: SizedBox(
        width: 500, // Adjust the width as needed
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
                onChanged: (value) {
                  filterProducts(value); // Filter products when search changes
                },
              ),
              SizedBox(height: 15),

              // Horizontal Scrollable Table header
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    0: IntrinsicColumnWidth(),
                    1: IntrinsicColumnWidth(), // item auto expandss
                    2: IntrinsicColumnWidth(),
                    3: IntrinsicColumnWidth(),
                    4: IntrinsicColumnWidth(),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.white),
                      children: [
                        Text('Qty'),
                        Text('Item'),
                        Text('Price'),
                        Text('Total'),
                        Text('Action'),
                      ],
                    ),
                    // Display filtered products in rows
                    ...filteredProducts.map((product) {
                      return TableRow(
                        children: [
                          Text(product.qty.toString()), // Display Quantity
                          Text(product.name), // Display Item Name
                          Text('₱${product.price}'), // Display Price
                          Text(
                            '₱${(product.qty * product.price)}',
                          ), // Display Total
                          Row(
                            mainAxisSize: MainAxisSize
                                .min, // Make sure the row doesn't take full width
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    editProduct(product), // Edit Product
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => confirmDeleteProduct(
                                  product,
                                ), // Show confirm delete dialog
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
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
