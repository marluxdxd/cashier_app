import 'package:flutter/material.dart';
import 'package:cashier_app/data/product_data.dart';
  

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

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Supplies:'),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SupplyModal(),
                    );
                  },
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Click to enter supply',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(children: [Text('Item Bought')]),
          SizedBox(height: 20),
          Text('Quantity'),
          SizedBox(height: 20),
          Text('Date'),
          SizedBox(height: 20),
          Text('Balance'),
        ],
      ),
    );
  }
}

class SupplyModal extends StatefulWidget {
  const SupplyModal({super.key});

  @override
  State<SupplyModal> createState() => _SupplyModalState();
}

class _SupplyModalState extends State<SupplyModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        height: 700,
        child: Stack(
          clipBehavior: Clip.none, // IMPORTANT for overlap!
          children: [
            // MAIN CONTENT
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
      
                  Text(
                    'Supply',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
      
                  SizedBox(height: 20),
      
                 Table(
  border: TableBorder.all(),
  columnWidths: const {
    0: FlexColumnWidth(),
    1: FlexColumnWidth(),
    2: FlexColumnWidth(),
    3: FlexColumnWidth(),
  },
  children: [
    TableRow(
      children: [
        Padding(padding: EdgeInsets.all(8), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8), child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8), child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8), child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    ),
 // Product rows
    ...products.map((p) {
      return TableRow(
        children: [
          Padding(padding: EdgeInsets.all(8), child: Text(p.qty.toString())),
          Padding(padding: EdgeInsets.all(8), child: Text(p.name)),
          Padding(padding: EdgeInsets.all(8), child: Text('${p.price}')),
          Padding(padding: EdgeInsets.all(8), child: Text('${p.total}')),
        ],
      );
    }).toList(),
  ],
),
      
                  Expanded(child: Container()),
                  Text('Total: 10'),
      
                  // Text("Total: 10", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
                  SizedBox(height: 10),
      
                  SizedBox(height: 40),
                ],
              ),
            ),
      
            // ✅ CLOSE BUTTON FLOATING & OVERLAPPING
            Positioned(
              top: -20, // goes OUTSIDE the modal
              left: 270, // start position
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 4,
                ),
                child: Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
