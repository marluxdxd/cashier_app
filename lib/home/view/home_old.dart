// import 'package:cashier_app/database/app_db.dart';
// import 'package:cashier_app/home/view/product_notification.dart';
// import 'package:cashier_app/home/viewModel/sale_service.dart';
// import 'package:cashier_app/home/view/customer_cash.dart';
// import 'package:cashier_app/home/view/product_search.dart';
// import 'package:cashier_app/home/viewModel/product.dart';
// import 'package:cashier_app/home/viewModel/row.dart';
// import 'package:cashier_app/data/row_data.dart';
// import 'package:cashier_app/home/viewModel/sale.dart';
// import 'package:cashier_app/widget/app_drawer.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';

// class TestView1 extends StatefulWidget {
//   const TestView1({super.key});

//   @override
//   State<TestView1> createState() => _TestView1State();
// }

// class _TestView1State extends State<TestView1> {
//   bool transactionSaved = false;
//   Product? selectedProduct;
//   int qty = 0;
//   List<Product> dbProducts = [];
//   bool promo = false; // default ON

//   @override
//   void initState() {
//     super.initState();
//     loadProducts();
//   }

//   Future<void> loadProducts() async {
//     await AppDB.instance.seedDefaultProducts();
//     final productsFromDB = await AppDB.instance.fetchProducts();
//     setState(() {
//       dbProducts = productsFromDB;
//     });
//   }

//   int calculateTotal(RowData row) {
//     if (row.product == null) return 0;

//     final product = row.product!;
//     final qty = row.qty;
//     final price = product.price.toInt();

//     if (product.promo) {
//       promo = true;
//       return (qty * price) - 1;
//     }
//     if (product == promo) {
//       for (int q = 3; q < 12; q += 2) {
//         print(q);
//       }
//     }
//     return qty * price;
//   }

//   int get totalBill {
//     int sum = 0;
//     for (var row in rows) {
//       sum += calculateTotal(row);
//     }
//     return sum;
//   }

//   TextEditingController customerController = TextEditingController();

//   int get change {
//     int customerCash = int.tryParse(customerController.text) ?? 0;
//     return customerCash - totalBill;
//   }

//   void controllerClearCustomerCash() {
//     setState(() {
//       customerController.clear();
//     });
//   }

//   void saveTransaction() async {
//     if (transactionSaved) return;
//     transactionSaved = true;

//     final service = SaleService();

//     for (var row in rows) {
//       if (row.product != null && row.qty > 0) {
//         try {
//           row.product!.reduceStock(row.qty);
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(e.toString().replaceAll("Exception:", "").trim()),
//             ),
//           );
//           controllerClearCustomerCash();
//           transactionSaved = false;
//           return;
//         }

//         final sale = Sale(
//           productName: row.product!.name,
//           qty: row.qty,
//           price: row.product!.price.toInt(),
//           total: calculateTotal(row),
//           date: DateTime.now().toIso8601String(),
//         );

//         await service.insertSale(sale);
//         await AppDB.instance.updateProduct(row.product!);
//       }
//     }

//     int finalChange = int.tryParse(customerController.text)! - totalBill;

//     setState(() {
//       rows.clear();
//       rows.add(RowData());
//       customerController.clear();
//       transactionSaved = false;
//     });

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Center(
//           child: Column(
//             children: [
//               Text('Sukli'),
//               Text(
//                 "$finalChange",
//                 style: TextStyle(fontSize: 100, color: Colors.red),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           '',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 20.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.notifications),
//                   onPressed: () {
//                     showDialog(
//                       barrierColor: Colors.black.withOpacity(0.2),
//                       context: context,
//                       builder: (context) => ProductNotification(),
//                     );
//                   },
//                 ),
//                 SizedBox(width: 20),
//                 IconButton(
//                   onPressed: () {
//                     showDialog(
//                       barrierColor: Colors.black.withOpacity(0.2),
//                       context: context,
//                       builder: (context) => SearchProduct(),
//                     );
//                   },
//                   icon: Icon(Icons.search),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       drawer: AppDrawer(
//         onProductAdded: () async {
//           await loadProducts();
//         },
//       ),
//       body: RefreshIndicator(
//         onRefresh: loadProducts,
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.textsms_sharp),
//                 onPressed: () {
//                   bool promo = false;
//                   int qty = 3;
//                   int price = 1;
//                   if (!promo) {
//                     print("Promo not applied for $qty items");
//                   }
//                 },
//               ),
//               SizedBox(height: 200),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Table(
//                   border: TableBorder.all(),
//                   columnWidths: const {
//                     0: FixedColumnWidth(150),
//                     1: FixedColumnWidth(70),
//                     2: FixedColumnWidth(80),
//                     3: FixedColumnWidth(100),
//                     4: FixedColumnWidth(150),
//                   },
//                   children: [
//                     TableRow(
//                       children: [
//                         Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
//                         Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     ...rows.map((row) {
//                       // Ensure qty value exists in items to prevent Flutter error
//                       int? dropdownValue = row.qty == 0 ? null : row.qty;
//                       List<DropdownMenuItem<int>> qtyItems =
//                           (row.product?.promo ?? false)
//                               ? [
//                                   DropdownMenuItem(
//                                     value: row.product?.otherqty ?? 1,
//                                     child:
//                                         Text((row.product?.otherqty ?? 1).toString()),
//                                   )
//                                 ]
//                               : List.generate(20, (index) {
//                                   int number = index + 1;
//                                   return DropdownMenuItem(
//                                     value: number,
//                                     child: Text(number.toString()),
//                                   );
//                                 });
//                       // Reset dropdownValue if invalid
//                       if (dropdownValue != null &&
//                           !qtyItems.any((item) => item.value == dropdownValue)) {
//                         dropdownValue = qtyItems.first.value;
//                         row.qty = dropdownValue!;
//                       }

//                       return TableRow(
//                         children: [
//                           DropdownSearch<Product>(
//                             items: dbProducts,
//                             itemAsString: (p) => p.name,
//                             selectedItem: row.product,
//                             dropdownDecoratorProps: DropDownDecoratorProps(
//                               dropdownSearchDecoration: InputDecoration(
//                                 hintText: "Select ",
//                                 border: OutlineInputBorder(),
//                               ),
//                             ),
//                             popupProps: PopupProps.menu(
//                               showSearchBox: true,
//                               searchFieldProps: TextFieldProps(
//                                 autofocus: true,
//                                 decoration: InputDecoration(
//                                   hintText: 'Search product...',
//                                   contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 4,
//                                   ),
//                                 ),
//                               ),
//                               itemBuilder: (context, item, isSelected) {
//                                 return ListTile(title: Text(item.name));
//                               },
//                             ),
//                             onChanged: (p) {
//                               setState(() {
//                                 row.product = p;
//                                 if (row == rows.last) rows.add(RowData());
//                               });
//                             },
//                           ),
//                           DropdownButton<int>(
//                             value: dropdownValue,
//                             isExpanded: true,
//                             underline: SizedBox(),
//                             hint: Text("0"),
//                             items: qtyItems,
//                             onChanged: (value) {
//                               setState(() {
//                                 row.qty = value!;
//                               });
//                             },
//                           ),
//                           Text(row.product?.price.toString() ?? '0'),
//                           Text(calculateTotal(row).toString()),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () {
//                                   setState(() {
//                                     if (rows.length > 1) rows.remove(row);
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text('Total Bill: $totalBill',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               SizedBox(height: 20),
//               CustomerCashField(
//                 controller: customerController,
//                 totalBill: totalBill,
//                 transactionSaved: transactionSaved,
//                 saveTransaction: saveTransaction,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class HomeView1 extends StatelessWidget {
//   const HomeView1({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Honey Sari-Sari Store',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       drawer: AppDrawer(),
//       body: Center(child: Column(children: [SizedBox(height: 50)])),
//     );
//   }
// }
