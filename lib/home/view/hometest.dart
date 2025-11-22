import 'package:cashier_app/database/app_db.dart';

import 'package:cashier_app/database/sale_service.dart';
import 'package:cashier_app/home/view/customer_cash.dart';

import 'package:cashier_app/home/view/product_search.dart';

import 'package:cashier_app/home/view/sales_history.dart';
import 'package:cashier_app/home/view/sales_report.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/home/viewModel/row.dart';
import 'package:cashier_app/data/row_data.dart';
import 'package:cashier_app/home/viewModel/sale.dart';
import 'package:cashier_app/widget/app_drawer.dart';
import 'package:flutter/material.dart';

class TestView1 extends StatefulWidget {
  const TestView1({super.key});

  @override
  State<TestView1> createState() => _TestView1State();
}

class _TestView1State extends State<TestView1> {
  bool transactionSaved = false;
  Product? selectedProduct;
  int qty = 0;
  List<Product> dbProducts = [];
  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
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

  void controllerClearCustomerCash() {
    setState(() {
      customerController.clear();
    });
  }

  // ✅ PUT THE FUNCTION HERE
  void saveTransaction() async {
    if (transactionSaved) return;
    transactionSaved = true;

    final service = SaleService();

    for (var row in rows) {
      if (row.product != null && row.qty > 0) {
        try {
          // ⭐ CHECK STOCK
          row.product!.reduceStock(row.qty);
        } catch (e) {
          // ⭐ SHOW STOCK ERROR
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll("Exception:", "").trim()),
            ),
          );

          // ⭐ CLEAR CUSTOMER CASH FIELD
          controllerClearCustomerCash();

          transactionSaved = false;
          return;
        }

        // ⭐ SAVE SALE
        final sale = Sale(
          productName: row.product!.name,
          qty: row.qty,
          price: row.product!.price.toInt(),
          total: row.qty * row.product!.price.toInt(),
          date: DateTime.now().toIso8601String(),
        );

        await service.insertSale(sale);

        // ⭐ UPDATE STOCK IN DATABASE
        await AppDB.instance.updateProduct(row.product!);
      }
    }

    int finalChange = int.tryParse(customerController.text)! - totalBill;

    // ⭐ RESET UI AFTER SUCCESS
    setState(() {
      rows.clear();
      rows.add(RowData());
      customerController.clear();
      transactionSaved = false;
    });

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
      ),
    );
  }

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
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(
                barrierColor: Colors.black.withOpacity(0.2),
                context: context,
                builder: (context) => SearchProduct(),
              );
            },
            child: Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),

      // ✅ Wrap drawer with callback to refresh products
      drawer: AppDrawer(
        onProductAdded: () async {
          await loadProducts(); // reload products after adding
        },
      ),

      // ✅ Wrap body with RefreshIndicator
      body: RefreshIndicator(
        onRefresh: loadProducts, // called when user pulls down

        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // allows scroll for RefreshIndicator
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 100),
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
                      Text(
                        'Qty',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Item',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

                        // Item Dropdown
                        DropdownButton<Product>(
                          value: dbProducts.contains(row.product)
                              ? row.product
                              : null,
                          isExpanded: true,
                          underline: SizedBox(),
                          hint: Text("Select item"),
                          items: dbProducts.map((p) {
                            return DropdownMenuItem<Product>(
                              value: p,
                              child: Text(p.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              row.product = value;
                              if (row == rows.last)
                                rows.add(RowData()); // add new row dynamically
                            });
                          },
                        ),

                        // Price
                        Text(row.product?.price.toString() ?? '0'),

                        // Total
                        Text((row.qty * (row.product?.price ?? 0)).toString()),

                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (rows.length > 1) rows.remove(row);
                            });
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              SizedBox(height: 10),
              Text(
                'Total Bill: $totalBill',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              CustomerCashField(
                controller: customerController,
                totalBill: totalBill,
                transactionSaved: transactionSaved,
                saveTransaction: saveTransaction,
              ),
            ],
          ),
        ),
      ),
     


    );
  }
}

class HomeView1 extends StatelessWidget {
  const HomeView1({super.key});

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

      body: Center(child: Column(children: [SizedBox(height: 50)])),
    );
  }
}
