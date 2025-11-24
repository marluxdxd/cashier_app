// import 'package:flutter/material.dart';
// import 'package:cashier_app/home/viewModel/product.dart';
// class ProductSearchSheet extends StatefulWidget {
//   final List<Product> dbProducts;

//   const ProductSearchSheet({required this.dbProducts});

//   @override
//   State<ProductSearchSheet> createState() => _ProductSearchSheetState();
// }

// class _ProductSearchSheetState extends State<ProductSearchSheet> {
//   TextEditingController searchCtrl = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: TextField(
//             controller: searchCtrl,
//             decoration: InputDecoration(
//               hintText: "Search product...",
//               prefixIcon: Icon(Icons.search),
//             ),
//             onChanged: (_) => setState(() {}),
//           ),
//         ),

//         Expanded(
//           child: ListView(
//             children: widget.dbProducts
//                 .where((p) =>
//                     p.name.toLowerCase().contains(searchCtrl.text.toLowerCase()))
//                 .map((p) => ListTile(
//                       title: Text(p.name),
//                       onTap: () => Navigator.pop(context, p),
//                     ))
//                 .toList(),
//           ),
//         )
//       ],
//     );
//   }
// }
