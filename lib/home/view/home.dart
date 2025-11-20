import 'package:cashier_app/database/sale_service.dart';
import 'package:cashier_app/home/view/sales_history.dart';
import 'package:cashier_app/home/view/sales_report.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/home/viewModel/row.dart';
import 'package:cashier_app/data/row_data.dart';
import 'package:cashier_app/home/viewModel/sale.dart';
import 'package:cashier_app/widget/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:cashier_app/data/product_data.dart';

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  Product? selectedProduct;
  int qty = 0;

  

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
                        value: row.product,
                        isExpanded: true,
                        underline: SizedBox(),
                        hint: Text("Select item"),
                        items: products.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            row.product = value;
                            bool isLastRow = row == rows.last;  

                            if (isLastRow) {
                              rows.add(RowData());
                            } // ADD NEW ROW HERE
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
          'honey sari-sari stores',
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

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'test'),

                

                
                ]),
          
        ],
      ),
    );
  }
}


