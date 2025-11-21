import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/database/sale_service.dart';
import 'package:cashier_app/home/view/product_form.dart';
import 'package:cashier_app/home/view/product_list_view.dart';
import 'package:cashier_app/home/view/product_search.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/home/viewModel/row.dart';
import 'package:cashier_app/data/row_data.dart';
import 'package:cashier_app/home/viewModel/sale.dart';
import 'package:cashier_app/widget/app_drawer.dart';
import 'package:flutter/material.dart';

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  Product? selectedProduct;
  int qty = 0;
  List<Product> dbProducts = [];
  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // void loadProducts() async {
  //   await AppDB.instance.seedDefaultProducts(); // Seed if empty
  //   final productsFromDB = await AppDB.instance.fetchProducts();
  //   setState(() {
  //     dbProducts = productsFromDB;
  //   });
  // }

  void loadProducts() async {
    await AppDB.instance.seedDefaultProducts();
    final productsFromDB = await AppDB.instance.fetchProducts();
    setState(() {
      dbProducts = productsFromDB;
    });
  }

  int get totalBill {
    int sum = 0;

    for (var row in rows) {
      final price = row.product?.price ?? 0; // double or int
      sum += row.qty * price.toInt();
    }

    return sum;
  }

  TextEditingController customerController = TextEditingController();

  int get change {
    int customerCash = int.tryParse(customerController.text) ?? 0;
    return customerCash - totalBill;
  }

  // ✅ PUT THE FUNCTION HERE
  void saveTransaction() async {
    final service = SaleService();

    for (var row in rows) {
      if (row.product != null && row.qty > 0) {
        final sale = Sale(
          productName: row.product!.name,
          qty: row.qty,
          price: row.product!.price.toInt(),
          total: row.qty * row.product!.price.toInt(),
          date: DateTime.now().toIso8601String(),
        );

        await service.insertSale(sale);
      }
    }

    // ⭐ Clear rows after saving
    setState(() {
      rows.clear();
      rows.add(RowData()); // Add an empty new row
      customerController.clear();
    });

    print("✔ Transaction saved & rows cleared");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 100.0, left: 10.0, right: 10.0),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
              },
              children: [
                // Header row
                TableRow(
                  children: [
                    Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),

                    Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),

                    Text(
                      'Price',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(
                      'Action',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                // Product rows
                // Dynamic Rows
                ...rows.map((row) {
                  return TableRow(
                    children: [
                      // Qty
                      DropdownButton<int>(
                        value: row.qty == 0 ? null : row.qty,
                        isExpanded: true,
                        underline: SizedBox(),
                        hint: Text("0"),
                        items: List.generate(50, (index) {
                          int number = index + 1;
                          return DropdownMenuItem(
                            value: number,
                            child: Text(number.toString()),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            row.qty = value!;
                          });
                        },
                      ),

                      // Item Dropdown (ITEM)
                    DropdownButton<Product>(
  value: row.product,  // Ensure this value matches one of the products in the items list
  isExpanded: true,
  underline: SizedBox(),
  hint: Text("Select item"),
  items: dbProducts.map((p) {
    return DropdownMenuItem<Product>(
      value: p,  // Set the value as the product instance
      child: Text(p.name),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      row.product = value;  // Ensure that the value is correctly set to the selected product
      bool isLastRow = row == rows.last;
      if (isLastRow) {
        rows.add(RowData());  // Add new empty row
      }
    });
  },
),


                      // Price
                      Text(row.product?.price.toString() ?? '0'),

                      // Total (qty × price)
                      Text((row.qty * (row.product?.price ?? 0)).toString()),

                      // DELETE BUTTON
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            rows.remove(row); // remove the row from the list
                          });
                        },
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            Text(
              'Total Bill: $totalBill',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            TextField(
              controller: customerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Customer Cash",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {}); // refresh UI whenever user types
              },
            ),

            SizedBox(height: 10),

            Text(
              "Change: $change",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveTransaction,
              child: Text("Save to Database"),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Honey Sari-Sari Store',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      // ⭐ ADD DRAWER HERE
      drawer: AppDrawer(),

      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                showDialog(
                  barrierColor: Colors.black.withOpacity(0.2),
                  context: context,
                  builder: (context) => SearchProduct(),
                );
              },
              child: Text("Search products"),
            ),
            SizedBox(height: 50),
           
            GestureDetector(
              onTap: () {
                showDialog(
                  barrierColor: Colors.black.withOpacity(0.2),
                  context: context,
                  builder: (context) => AddProduct(),
                );
              },
              child: Text("Add products"),
            ),
            Table(children: [
            
          ],
        ),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                // Navigate to ProductListView when the user taps this text
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductListView()),
                );
              },
              child: Text("View All Products"),
            ),
            SizedBox(height: 50),
            Text('stock'),
          ],
        ),
      ),
    );
  }
}
