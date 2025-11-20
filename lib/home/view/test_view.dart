// import 'package:flutter/material.dart';
// import 'package:cashier_app/home/viewModel/product.dart';
// import 'package:cashier_app/home/viewModel/row.dart';
// import 'package:cashier_app/data/row_data.dart';
// import 'package:cashier_app/data/product_data.dart';
// import 'package:cashier_app/data/db_helper.dart';

// class TestView extends StatefulWidget {
//   const TestView({super.key});

//   @override
//   State<TestView> createState() => _TestViewState();
// }

// class _TestViewState extends State<TestView> {
//   List<RowData> rows = []; // dynamic rows list
//   TextEditingController customerController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     loadRowsFromDB(); // Load saved rows when screen opens
//   }

//   int get totalBill {
//     int sum = 0;
//     for (var row in rows) {
//       final price = row.product?.price ?? 0;
//       sum += row.qty * price.toInt();
//     }
//     return sum;
//   }

//   int get change {
//     int customerCash = int.tryParse(customerController.text) ?? 0;
//     return customerCash - totalBill;
//   }

//   Future<void> saveAllRows() async {
//     for (var row in rows) {
//       if (row.product != null && row.qty > 0) {
//         row.date = DateTime.now();
//         await DBHelper().insertRow(row);
//       }
//     }
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text("Saved to database!")));
//   }

//   Future<void> loadRowsFromDB() async {
//     rows = await DBHelper().getRows();
//     if (rows.isEmpty) {
//       rows.add(RowData()); // Add empty row if no saved data
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Table(
//                   border: TableBorder.all(),
//                   columnWidths: const {
//                     0: FlexColumnWidth(),
//                     1: FlexColumnWidth(),
//                     2: FlexColumnWidth(),
//                     3: FlexColumnWidth(),
//                     4: FlexColumnWidth(),
//                     5: FlexColumnWidth(),
//                   },
//                   children: [
//                     // Header row
//                     TableRow(
//                       children: [
//                         Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     // Dynamic rows
//                     ...rows.map((row) {
//                       return TableRow(
//                         children: [
//                           // Qty Dropdown
//                           DropdownButton<int>(
//                             value: row.qty == 0 ? null : row.qty,
//                             isExpanded: true,
//                             underline: SizedBox(),
//                             hint: Text("0"),
//                             items: List.generate(50, (index) {
//                               int number = index + 1;
//                               return DropdownMenuItem(
//                                 value: number,
//                                 child: Text(number.toString()),
//                               );
//                             }),
//                             onChanged: (value) {
//                               setState(() {
//                                 row.qty = value!;
//                               });
//                             },
//                           ),
//                           // Product Dropdown
//                           DropdownButton<Product>(
//                             value: row.product,
//                             isExpanded: true,
//                             underline: SizedBox(),
//                             hint: Text("Select item"),
//                             items: products.map((p) {
//                               return DropdownMenuItem(
//                                 value: p,
//                                 child: Text(p.name),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 row.product = value;
//                                 bool isLastRow = row == rows.last;
//                                 if (isLastRow) rows.add(RowData());
//                               });
//                             },
//                           ),
//                           // Price
//                           Text(row.product?.price.toString() ?? '0'),
//                           // Total (qty × price)
//                           Text((row.qty * (row.product?.price ?? 0)).toString()),
//                           // Date
//                           Text(row.date.toLocal().toString().split(' ')[0]),
//                           // Delete Button
//                           IconButton(
//                             icon: Icon(Icons.delete, color: Colors.red),
//                             onPressed: () {
//                               setState(() {
//                                 rows.remove(row);
//                               });
//                             },
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Text('Total Bill: $totalBill',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             // Customer cash
//             TextField(
//               controller: customerController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: "Customer Cash",
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (_) {
//                 setState(() {}); // refresh UI whenever user types
//               },
//             ),
//             SizedBox(height: 10),
//             Text(
//               "Change: $change",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: saveAllRows,
//               child: Text("Save All"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
