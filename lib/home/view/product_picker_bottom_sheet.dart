import 'package:flutter/material.dart';
import 'package:cashier_app/home/viewModel/product.dart';

class ProductPickerBottomSheet extends StatefulWidget {
  final List<Product> products;

  const ProductPickerBottomSheet({super.key, required this.products});

  @override
  State<ProductPickerBottomSheet> createState() =>
      _ProductPickerBottomSheetState();
}

class _ProductPickerBottomSheetState extends State<ProductPickerBottomSheet> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    List<Product> filtered = widget.products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Search Bar
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search product...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => setState(() => query = value),
              ),

              SizedBox(height: 10),

              // Results
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text("No products found"))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final p = filtered[index];

                          return ListTile(
                            title: Text(p.name),
                            subtitle: Text(
                              "Price: ₱${p.price.toStringAsFixed(2)} • Stock: ${p.qty}",
                            ),
                            trailing: p.promo
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "PROMO",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(context, p); // return product
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
