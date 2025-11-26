import 'package:flutter/material.dart';
import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/sale.dart';
import 'package:intl/intl.dart';

class SalesReportView extends StatefulWidget {
  const SalesReportView({super.key});

  @override
  State<SalesReportView> createState() => _SalesReportViewState();
}

class _SalesReportViewState extends State<SalesReportView> {
  List<Sale> results = [];
  bool loading = false;

  DateTime? startDate;
  DateTime? endDate;

  int get totalRevenue {
    int total = 0;
    for (var s in results) {
      total += s.total;
    }
    return total;
  }

  Future<void> loadDaily() async {
    setState(() => loading = true);
    final today = DateTime.now();
    results = await AppDB.instance.getSalesByDateRange(today, today);
    setState(() => loading = false);
  }

  Future<void> loadWeekly() async {
    setState(() => loading = true);
    final now = DateTime.now();
    results = await AppDB.instance
        .getSalesByDateRange(now.subtract(Duration(days: 7)), now);
    setState(() => loading = false);
  }

  Future<void> loadMonthly() async {
    setState(() => loading = true);
    final now = DateTime.now();
    results = await AppDB.instance
        .getSalesByDateRange(DateTime(now.year, now.month, 1), now);
    setState(() => loading = false);
  }

Future<void> loadSalesByRange() async {
  if (startDate == null || endDate == null) return;

  // Adjust start and end to include the full days
  final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
  final end = DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59, 999);

  setState(() => loading = true);
  results = await AppDB.instance.getSalesByDateRange(start, end);
  setState(() => loading = false);
}


  @override
  Widget build(BuildContext context) {
    // Group results by date
    Map<String, List<Sale>> salesByDate = {};
    for (var sale in results) {
      final dateKey = sale.date.substring(0, 10); // yyyy-mm-dd
      if (!salesByDate.containsKey(dateKey)) {
        salesByDate[dateKey] = [];
      }
      salesByDate[dateKey]!.add(sale);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Sales Report"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              final db = await AppDB.instance.database;
              await db.delete('sales');
              setState(() => results.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Predefined filters
       

          SizedBox(height: 10),
          Text(
            "Total Revenue: ₱$totalRevenue",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          // Date range pickers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => startDate = date);
                },
                child: Text(startDate != null
                    ? DateFormat('yyyy-MM-dd').format(startDate!)
                    : 'Start Date'),
              ),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => endDate = date);
                },
                child: Text(endDate != null
                    ? DateFormat('yyyy-MM-dd').format(endDate!)
                    : 'End Date'),
              ),
              ElevatedButton(
                onPressed: loadSalesByRange,
                child: Text("Load"),
              ),
            ],
          ),


          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : salesByDate.isEmpty
                    ? Center(child: Text("No sales yet"))
                    : ListView(
                        children: salesByDate.entries.map((entry) {
                          final date = entry.key;
                          final sales = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  DateFormat('MMM d, yyyy')
                                      .format(DateTime.parse(date)),
                                  style: TextStyle(
                                      
                                      fontSize: 16),
                                ),
                              
                          Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Header row
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Expanded(child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(width: 40), // space for Qty
        Expanded(child: Text('qty', style: TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(width: 100), // space for Qty
        
        Text('price', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
    const SizedBox(height: 4), // optional spacing

    // Sales rows
    ...sales.map((s) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        
         Text('${s.productName}  '),
        Text(' ${s.qty} pcs'),
        SizedBox(width: 40), // align with header
        Text('₱${s.total}'),
      ],
    )),

    const SizedBox(height: 8), // spacing before total

    // Total row with top border
    Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
            ),
            padding: const EdgeInsets.only(top: 4), // optional spacing above text
            child: Text(
              'total: ₱${sales.fold(0, (sum, s) => sum + s.total)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),

                              Divider(),
                            ],
                            
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}
