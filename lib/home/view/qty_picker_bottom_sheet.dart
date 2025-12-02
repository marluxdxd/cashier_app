import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QtyPickerBottomSheet extends StatefulWidget {
  final int maxQty;

  const QtyPickerBottomSheet({super.key, required this.maxQty});

  @override
  State<QtyPickerBottomSheet> createState() => _QtyPickerBottomSheetState();
}

class _QtyPickerBottomSheetState extends State<QtyPickerBottomSheet> {
  final TextEditingController controller = TextEditingController();
  int? enteredQty;

  void _confirmQty() {
    final int? number = int.tryParse(controller.text);
    if (number != null && number >= 1 && number <= widget.maxQty) {
      Navigator.pop(context, number); // valid → close sheet
    } else {
      // invalid → show warning
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter a valid quantity (1 - ${widget.maxQty})'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // List of quantities (optional, for quick selection)
    List<int> qtyList = List.generate(widget.maxQty, (i) => i + 1)
        .where((q) => controller.text.isEmpty || q.toString().contains(controller.text))
        .toList();

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.20,
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 50,
                height: 5,
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Numeric input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: "Enter quantity...",
                        prefixIcon: Icon(Icons.dialpad),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          final int? number = int.tryParse(value);
                          enteredQty = number;
                        });
                      },
                      onSubmitted: (_) => _confirmQty(), // optional: press Enter to confirm
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _confirmQty,
                    child: Icon(Icons.check),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // Optional: filtered list for manual selection
              Expanded(
                child: qtyList.isEmpty
                    ? Center(child: Text("No match"))
                    : ListView.builder(
                        itemCount: qtyList.length,
                        itemBuilder: (context, i) {
                          final q = qtyList[i];
                          return ListTile(
                            title: Text(
                              "Quantity: $q",
                              style: TextStyle(fontSize: 16),
                            ),
                            onTap: () => Navigator.pop(context, q),
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
