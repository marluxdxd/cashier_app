import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/database/database_backup.dart';
import 'package:cashier_app/database/sale_service.dart';
import 'package:cashier_app/home/view/product_form.dart';
import 'package:cashier_app/home/view/product_list_view.dart';
import 'package:cashier_app/home/view/product_search.dart';
import 'package:cashier_app/home/view/product_stock.dart';
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
  bool transactionSaved = false;
  Product? selectedProduct;
  int qty = 0;
  List<Product> dbProducts = [];
  @override
  void initState() {
    super.initState();
    loadProducts();
  }

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
     if (transactionSaved) return; // prevent multiple saves
  transactionSaved = true;
    
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
    int finalChange = change; // calculate before clearing data
    // ⭐ Clear rows after saving
    setState(() {
      rows.clear();
      rows.add(RowData()); // Add an empty new row
      customerController.clear();
       transactionSaved = false; // ready for next transaction
    });

    print("✔ Transaction saved & rows cleared");
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Column(
            children: [
              Text('Sukli'),
              Text(
                "$finalChange",
                style: TextStyle(fontSize: 100, color: Colors.red),
              ),
            ],
          ),
        ),
        actions: [
          // TextButton(
          //   onPressed: () => Navigator.pop(context),
          //   child: Text("OK"),
          // )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Customer')),
      content: Form(
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
                        value: row
                            .product, // Ensure this value matches one of the products in the items list
                        isExpanded: true,
                        underline: SizedBox(),
                        hint: Text("Select item"),
                        items: dbProducts.map((p) {
                          return DropdownMenuItem<Product>(
                            value: p, // Set the value as the product instance
                            child: Text(p.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            row.product =
                                value; // Ensure that the value is correctly set to the selected product
                            bool isLastRow = row == rows.last;
                            if (isLastRow) {
                              rows.add(RowData()); // Add new empty row
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
      if (rows.length > 1) {
        rows.remove(row); // remove the row from the list
      }
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
  onChanged: (value) {
    setState(() {}); // refresh change display

    int customerCash = int.tryParse(value) ?? 0;

    if (totalBill == 0) return; // no products, do nothing

    if (customerCash < totalBill) {
      // Optional: you can show a warning if cash is insufficient
      print("Cash is not enough yet.");
      return; // do not proceed
    }

    if (!transactionSaved) {
      saveTransaction(); // auto save
    }
  },
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
             GestureDetector(
              onTap: () {
                showDialog(
                  barrierColor: Colors.black.withOpacity(0.2),
                  context: context,
                  builder: (context) => ProductStock(),
                );
              },
              child: Text("Stock"),
            ),
            SizedBox(height: 50),
            Column(
              
  children: [
    
    ElevatedButton(
  onPressed: () async {
    try {
      await DatabaseBackup.backupDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Database backed up!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Backup failed: $e")),
      );
    }
  },
  child: Text("Backup Database"),
),
ElevatedButton(
  onPressed: () async {
    try {
      await DatabaseBackup.restoreDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Database restored!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Restore failed: $e")),
      );
    }
  },
  child: Text("Restore Database"),
),

  ],
)

            
          ],
        ),
      
      ),
    );
  }
}
