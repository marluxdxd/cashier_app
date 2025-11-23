import 'package:flutter/material.dart';

class ProductManual extends StatefulWidget {
  const ProductManual({super.key});

  @override
  State<ProductManual> createState() => _ProductManualState();
}

class _ProductManualState extends State<ProductManual> {
  // Example items (you can load from DB later)
  final List<String> items = [
    "Stick-O",
    "Nova",
    "Piattos",
    "Coke",
  ];

  String? selectedItem;
  final promoQtyCtrl = TextEditingController(text: "3");
  final promoPriceCtrl = TextEditingController(text: "5");
  final priceCtrl = TextEditingController(text: "2");

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Promo Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // --------------------------
          // ITEM DROPDOWN
          // --------------------------
          DropdownButtonFormField<String>(
            value: selectedItem,
            decoration: InputDecoration(labelText: "Select Item"),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedItem = value);
            },
          ),

          SizedBox(height: 15),

          // --------------------------
          // PROMO QTY, PROMO PRICE, REGULAR PRICE
          // --------------------------
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: promoQtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Promo Qty"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: promoPriceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Promo Price"),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          TextField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Price per piece"),
          ),

        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            if (selectedItem == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Select an item first")),
              );
              return;
            }

            Navigator.pop(context, {
              "productName": selectedItem,
              "promoQty": int.parse(promoQtyCtrl.text),
              "promoPrice": int.parse(promoPriceCtrl.text),
              "regularPrice": int.parse(priceCtrl.text),
            });
          },
          child: Text("Add Promo"),
        ),
      ],
    );
  }
}
