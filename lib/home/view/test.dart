import 'package:flutter/material.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supplies:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    minChildSize: 0.4,
                    maxChildSize: 0.95,
                    expand: false,
                    builder: (_, controller) {
                      return SupplyModal(scrollController: controller);
                    },
                  ),
                );
              },
              child: AbsorbPointer(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Click to enter supply',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupplyModal extends StatefulWidget {
  final ScrollController? scrollController;
  const SupplyModal({super.key, this.scrollController});

  @override
  State<SupplyModal> createState() => _SupplyModalState();
}

class _SupplyModalState extends State<SupplyModal> {
  // Step 1: supplies list (qty, item, price)
  List<Map<String, dynamic>> supplies = [];

  // Controllers for the add-item inputs
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController itemController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  // Helper: compute total
  int getTotal() {
    return supplies.fold(0, (sum, row) {
      final int q = (row['qty'] as int?) ?? 0;
      final int p = (row['price'] as int?) ?? 0;
      return sum + q * p;
    });
  }

  // Add new row (with simple validation)
  void addRow() {
    final int? qty = int.tryParse(qtyController.text.trim());
    final String item = itemController.text.trim();
    final int? price = int.tryParse(priceController.text.trim());

    if (qty == null || qty <= 0) {
      _showMessage('Enter a valid qty (number > 0).');
      return;
    }
    if (item.isEmpty) {
      _showMessage('Enter an item name.');
      return;
    }
    if (price == null || price < 0) {
      _showMessage('Enter a valid price (0 or more).');
      return;
    }

    setState(() {
      supplies.add({'qty': qty, 'item': item, 'price': price});
      qtyController.clear();
      itemController.clear();
      priceController.clear();
    });
  }

  void removeRow(int index) {
    setState(() {
      supplies.removeAt(index);
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    qtyController.dispose();
    itemController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a Stack to allow floating "Close" overlap if you want
    return Material(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      color: Colors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row (we leave room for floating Close)
                SizedBox(height: 10),
                Text('Supply', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),

                // Header labels
                Row(
                  children: [
                    Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 1, child: Text('Price', style: TextStyle(fontWeight: FontWeight.w600))),
                    SizedBox(width: 40), // space for delete icon column
                  ],
                ),
                SizedBox(height: 8),

                // List area (scrollable)
                Expanded(
                  child: supplies.isEmpty
                      ? Center(child: Text('No items yet. Add items below.'))
                      : ListView.separated(
                          controller: widget.scrollController,
                          itemCount: supplies.length,
                          separatorBuilder: (_, __) => Divider(),
                          itemBuilder: (context, idx) {
                            final row = supplies[idx];
                            return Row(
                              children: [
                                Expanded(flex: 1, child: Text(row['qty'].toString())),
                                Expanded(flex: 3, child: Text(row['item'])),
                                Expanded(flex: 1, child: Text(row['price'].toString())),
                                IconButton(
                                  onPressed: () => removeRow(idx),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            );
                          },
                        ),
                ),

                SizedBox(height: 12),

                // Total
                Row(
                  children: [
                    Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Text(getTotal().toString(), style: TextStyle(fontSize: 18)),
                  ],
                ),

                SizedBox(height: 12),

                // Add item inputs
                Row(
                  children: [
                    // Qty input
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Q',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),

                    // Item input
                    Flexible(
                      flex: 3,
                      child: TextField(
                        controller: itemController,
                        decoration: InputDecoration(
                          labelText: 'Item',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),

                    // Price input
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'P',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),

                    SizedBox(width: 8),

                    // Add button
                    ElevatedButton(
                      onPressed: addRow,
                      child: Text('Add'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ),

          // Floating Close button overlapping at top-left
          Positioned(
            top: -18,
            left: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
