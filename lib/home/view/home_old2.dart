// import 'package:cashier_app/database/app_db.dart';
// import 'package:cashier_app/widget/notificationbell.dart';
// import 'package:cashier_app/home/view/product_notification.dart';
// import 'package:cashier_app/home/viewModel/sale_service.dart';
// import 'package:cashier_app/home/viewModel/customer_cash.dart';
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
//   String? selectedValue;

//   // ✅ Updated: lists of keys for each row
//   List<GlobalKey<DropdownSearchState<Product>>> productDropdownKeys = [];
//   List<GlobalKey<DropdownSearchState<int>>> qtyDropdownKeys = [];

//   List<String> fruits = ['Apple', 'Banana', 'Cherry', 'Date'];

//   List<String> getLowStockItems() {
//     return dbProducts
//         .where((p) => p.qty < 10) // pick only low-stock products
//         .map((p) => "${p.name} (Qty: ${p.qty})") // convert to string
//         .toList();
//   }

//   // Focus nodes for item, quantity, and customer cash
//   final FocusNode searchFocusNode = FocusNode();
//   final FocusNode qtyFocusNode = FocusNode();
//   final FocusNode customerCashFocusNode = FocusNode();

//   bool transactionSaved = false;
//   List<Product> dbProducts = [];
//   bool promo = false;

//   @override
//   void initState() {
//     super.initState();
//     loadProducts();

//     // Initialize keys for the first row
//     productDropdownKeys.add(GlobalKey<DropdownSearchState<Product>>());
//     qtyDropdownKeys.add(GlobalKey<DropdownSearchState<int>>());
//   }

//   Future<void> loadProducts() async {
//     await AppDB.instance.seedDefaultProducts();
//     final productsFromDB = await AppDB.instance.fetchProducts();
//     setState(() {
//       dbProducts = productsFromDB;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (productDropdownKeys.isNotEmpty &&
//           dbProducts.isNotEmpty &&
//           productDropdownKeys[0].currentState != null) {
//         productDropdownKeys[0].currentState!.openDropDownSearch();
//       }
//     });
//   }

//   Future<void> fullRefresh() async {
//     setState(() {
//       dbProducts = [];
//       rows.clear();
//       rows.add(RowData());
//       customerController.clear();
//       transactionSaved = false;

//       // Reset keys
//       productDropdownKeys = [GlobalKey<DropdownSearchState<Product>>()];
//       qtyDropdownKeys = [GlobalKey<DropdownSearchState<int>>()];
//     });

//     await loadProducts();
//   }

//   int calculateTotal(RowData row) {
//     if (row.product == null) return 0;
//     final p = row.product!;
//     final price = p.price.toInt();

//     if (p.promo) return (row.qty * price) - 1;

//     return row.qty * price;
//   }

//   int get totalBill => rows.fold(0, (sum, row) => sum + calculateTotal(row));

//   TextEditingController customerController = TextEditingController();

//   void controllerClearCustomerCash() {
//     setState(() => customerController.clear());
//   }

//   void saveTransaction() async {
//     if (transactionSaved) return;
//     transactionSaved = true;
//     final service = SaleService();

//     List<String> insufficientStockProducts = [];

//     for (var row in rows) {
//       if (row.product != null && row.qty > 0) {
//         if (row.qty > row.product!.qty) {
//           insufficientStockProducts.add(
//             "${row.product!.name} (Available left: ${row.product!.qty})",
//           );
//         }
//       }
//     }

//     if (insufficientStockProducts.isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "Not enough stock for:\n${insufficientStockProducts.join('\n')}",
//           ),
//           duration: Duration(seconds: 4),
//         ),
//       );
//       transactionSaved = false;
//       return;
//     }

//     for (var row in rows) {
//       if (row.product != null && row.qty > 0) {
//         row.product!.reduceStock(row.qty);

//         final sale = Sale(
//           productName: row.product!.name,
//           qty: row.qty,
//           price: row.product!.price.toInt(),
//           total: calculateTotal(row),
//           date: DateTime.now().toIso8601String(),
//         );

//         await service.insertSale(sale);
//         await AppDB.instance.updateProduct(row.product!);

//         setState(() {});
//       }
//     }

//     int change = int.tryParse(customerController.text)! - totalBill;

//     setState(() {
//       rows.clear();
//       rows.add(RowData());
//       customerController.clear();
//       transactionSaved = false;

//       // Reset keys
//       productDropdownKeys = [GlobalKey<DropdownSearchState<Product>>()];
//       qtyDropdownKeys = [GlobalKey<DropdownSearchState<int>>()];
//     });

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         title: Center(
//           child: Column(
//             children: [
//               Text(
//                 'Sukli',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 15),
//               Text(
//                 "$change",
//                 style: TextStyle(
//                   fontSize: 150,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
// final isSmall = screenWidth < 380;  // you can adjust value later
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         title: Text(
//           'Sari-Sari Store',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.black),
//         actions: [
//           NotificationBell(
//             lowItems: getLowStockItems(),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 barrierColor: Colors.black.withOpacity(0.2),
//                 builder: (_) =>
//                     ProductNotification(lowItems: getLowStockItems()),
//               );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.black),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 barrierColor: Colors.black.withOpacity(0.2),
//                 builder: (_) => SearchProduct(),
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: AppDrawer(onProductAdded: () async => await loadProducts()),
//       body: RefreshIndicator(
//         onRefresh: fullRefresh,
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//          SizedBox(height: 50,),
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 elevation: 3,
//                 child: Padding(
//                   padding: EdgeInsets.all(12),
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: DataTable(
//                       headingRowColor: WidgetStateProperty.all(
//                         Colors.grey[200],
//                       ),
//                       columnSpacing: 20,
//                       columns: const [
//                         DataColumn(label: Text("Item")),
//                         DataColumn(label: Text("Qty")),
//                         DataColumn(label: Text("Price")),
//                         DataColumn(label: Text("Total")),
//                         DataColumn(label: Text("Remove")),
//                       ],
//                       rows: rows.map((row) {
//                         int index = rows.indexOf(row); // ✅ Row index

//                         int? dropdownValue = row.qty == 0 ? null : row.qty;

//                         List<DropdownMenuItem<int>> qtyItems =
//                             (row.product?.promo ?? false)
//                             ? [
//                                 DropdownMenuItem(
//                                   value: row.product?.otherqty ?? 1,
//                                   child: Text("${row.product?.otherqty ?? 1}"),
//                                 ),
//                               ]
//                             : List.generate(20, (i) {
//                                 int n = i + 1;
//                                 return DropdownMenuItem(
//                                   value: n,
//                                   child: Text("$n"),
//                                 );
//                               });

//                         return DataRow(
//                           cells: [
//                             DataCell(
//                               SizedBox(
//                                 width: 270,
//                                 child: DropdownSearch<Product>(
//                                   key: productDropdownKeys[index],
//                                   items: dbProducts,
//                                   selectedItem: row.product,
//                                   itemAsString: (p) => p.name,
//                                   dropdownBuilder: (context, p) => Text(
//                                     p?.name ?? "Select...",
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(fontSize: 14),
//                                   ),
//                                   dropdownDecoratorProps:
//                                       DropDownDecoratorProps(
//                                         dropdownSearchDecoration:
//                                             InputDecoration(
//                                               border: OutlineInputBorder(),
//                                               contentPadding:
//                                                   EdgeInsets.symmetric(
//                                                     horizontal: 8,
//                                                   ),
//                                             ),
//                                       ),
//                                   popupProps: PopupProps.menu(
//                                     showSearchBox: true,
//                                     emptyBuilder: (context, searchEntry) =>
//                                         Center(
//                                           child: Text("Loading products..."),
//                                         ),
//                                     searchFieldProps: TextFieldProps(
//                                       focusNode: searchFocusNode,
//                                       autofocus: true,
//                                       decoration: InputDecoration(
//                                         hintText: "Search...",
//                                       ),
//                                       style: TextStyle(fontSize: 14),
//                                     ),
//                                     itemBuilder: (context, item, isSelected) {
//                                       return Container(
//                                         height: 40,
//                                         decoration: BoxDecoration(
//                                           border: Border(
//                                             bottom: BorderSide(
//                                               color: Colors.grey,
//                                               width: 1,
//                                             ),
//                                           ),
//                                         ),
//                                         child: ListTile(
//                                           dense: true,
//                                           title: Text(
//                                             item.name,
//                                             style: TextStyle(fontSize: 12),
//                                           ),
//                                           selected: isSelected,
//                                           contentPadding: EdgeInsets.symmetric(
//                                             horizontal: 5,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   onChanged: (p) {
//                                     setState(() {
//                                       row.product = p;

//                                       if (row.product != null) {
//                                         if (row.product!.promo) {
//                                           row.qty = row.product!.otherqty;
//                                         } else if (row.qty == 0) {
//                                           row.qty = 1;
//                                         }
//                                       }

//                                       FocusScope.of(
//                                         context,
//                                       ).requestFocus(qtyFocusNode);

//                                       // ✅ Open qty dropdown for this row
//                                       if (qtyDropdownKeys[index].currentState !=
//                                           null) {
//                                         WidgetsBinding.instance
//                                             .addPostFrameCallback((_) {
//                                               qtyDropdownKeys[index]
//                                                   .currentState!
//                                                   .openDropDownSearch();
//                                             });
//                                       }

//                                       if (row == rows.last) {
//                                         rows.add(RowData());
//                                         productDropdownKeys.add(
//                                           GlobalKey<
//                                             DropdownSearchState<Product>
//                                           >(),
//                                         );
//                                         qtyDropdownKeys.add(
//                                           GlobalKey<DropdownSearchState<int>>(),
//                                         );
//                                       }
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               SizedBox(
//                                 width: 60,
//                                 child: DropdownSearch<int>(
//                                   key: qtyDropdownKeys[index],
//                                   items: qtyItems.map((e) => e.value!).toList(),
//                                   selectedItem: row.qty,
//                                   popupProps: PopupProps.menu(
//                                     showSearchBox: true,
//                                     searchFieldProps: TextFieldProps(
//                                       keyboardType: TextInputType.number,
//                                       focusNode: qtyFocusNode,
//                                       autofocus: true,
//                                       decoration: InputDecoration(
//                                         hintText: "Search...",
//                                       ),
//                                       style: TextStyle(fontSize: 14),
//                                     ),
//                                     itemBuilder: (context, item, isSelected) {
//                                       return Container(
//                                         height: 40,
//                                         decoration: BoxDecoration(
//                                           border: Border(
//                                             bottom: BorderSide(
//                                               color: Colors.grey,
//                                               width: 1,
//                                             ),
//                                           ),
//                                         ),
//                                         child: ListTile(
//                                           dense: true,
//                                           title: Text(
//                                             "$item",
//                                             style: TextStyle(fontSize: 12),
//                                           ),
//                                           selected: isSelected,
//                                           contentPadding: EdgeInsets.symmetric(
//                                             horizontal: 5,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   dropdownBuilder: (context, selectedQty) {
//                                     return Text(
//                                       "$selectedQty",
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(fontSize: 14),
//                                     );
//                                   },
//                                   onChanged: (v) {
//                                     setState(() {
//                                       if (v != null) row.qty = v;
//                                       FocusScope.of(
//                                         context,
//                                       ).requestFocus(customerCashFocusNode);
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               SizedBox(
//                                 width: 60,
//                                 child: Text(
//                                   "${row.product?.price ?? 0}",
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               SizedBox(
//                                 width: 70,
//                                 child: Text(
//                                   "${calculateTotal(row)}",
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               IconButton(
//                                 icon: Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () {
//                                   setState(() {
//                                     if (rows.length > 1) rows.remove(row);
//                                   });
//                                 },
//                               ),
//                             ),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       blurRadius: 5,
//                       color: Colors.grey.withOpacity(0.2),
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Total Bill",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     Text(
//                       "₱$totalBill",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               CustomerCashField(
//                 controller: customerController,
//                 totalBill: totalBill,
//                 transactionSaved: transactionSaved,
//                 saveTransaction: saveTransaction,
//                 focusNode: customerCashFocusNode,
//               ),
//               SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// ORIGINAL