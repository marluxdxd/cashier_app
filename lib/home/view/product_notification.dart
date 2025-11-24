import 'package:flutter/material.dart';

class ProductNotification extends StatelessWidget {
  const ProductNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1),
      ),
      title: Text('Product Notifications'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You have new updates about your product.',
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text('Stock is low on some items.'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
