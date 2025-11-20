import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/home/viewModel/row.dart';
import 'package:cashier_app/data/row_data.dart';
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
    final price = row.product?.price ?? 0;   // double or int
    sum += row.qty * price.toInt();
  }

  return sum;
}


TextEditingController customerController = TextEditingController();

int get change {
  int customerCash = int.tryParse(customerController.text) ?? 0;
  return customerCash - totalBill;
}


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: 100.0,
          left: 10.0,
          right: 10.0,
    
        ),
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

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Price Check:'),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SupplyModal(),
                    );
                  },
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(hintText: 'Click to enter'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text('Test:'),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => TestView(),
                    );
                  },
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(hintText: 'test'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text('Quantity'),
          SizedBox(height: 20),
          Text('Date'),
          SizedBox(height: 20),
          Text('Balance'),
        ],
      ),
    );
  }
}

class SupplyModal extends StatefulWidget {
  const SupplyModal({super.key});

  @override
  State<SupplyModal> createState() => _SupplyModalState();
}

class _SupplyModalState extends State<SupplyModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        height: 700,
        child: Stack(
          clipBehavior: Clip.none, // IMPORTANT for overlap!
          children: [
            // MAIN CONTENT
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),

                  Text(
                    'Supply',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),

                  Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FlexColumnWidth(),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(),
                      3: FlexColumnWidth(),
                    },
                    children: [
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
                        ],
                      ),
                      // Product rows
                      ...products.map((p) {
                        return TableRow(
                          children: [
                            Text(p.qty.toString()),

                            Text(p.name),

                            Text('${p.price}'),

                            Text('${p.total}'),
                          ],
                        );
                      }).toList(),
                    ],
                  ),

                  Expanded(child: Container()),

                  // Text('Total: 10'),
                  Text(
                    "Total: 101",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  SizedBox(height: 40),
                ],
              ),
            ),

            // ✅ CLOSE BUTTON FLOATING & OVERLAPPING
            Positioned(
              top: -20, // goes OUTSIDE the modal
              left: 270, // start position
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 4,
                ),
                child: Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
