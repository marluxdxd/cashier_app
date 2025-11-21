import 'package:flutter/material.dart';

class ProductStock extends StatefulWidget {
  const ProductStock({super.key});

  @override
  State<ProductStock> createState() => _ProductStockState();
}

class _ProductStockState extends State<ProductStock> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Stocks', style: TextStyle(fontSize: 10)),
      content: SizedBox(
        width: 500, // Adjust the width as needed
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field

              // Horizontal Scrollable Table header
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    0: IntrinsicColumnWidth(),
                    1: IntrinsicColumnWidth(), // item auto expandss
                    2: IntrinsicColumnWidth(),
                    3: IntrinsicColumnWidth(),
                    4: IntrinsicColumnWidth(),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.white),
                      children: [
                        Text('Qty'),
                        Text('Item'),
                        Text('Price'),
                        Text('Total'),
                        Text('Action'),
                      ],
                    ),
                    // Display filtered products in rows
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}