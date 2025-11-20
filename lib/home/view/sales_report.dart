import 'package:flutter/material.dart';
import 'package:cashier_app/database/sale_service.dart';
import 'package:cashier_app/home/viewModel/sale.dart';

class SalesReportView extends StatefulWidget {
  const SalesReportView({super.key});

  @override
  State<SalesReportView> createState() => _SalesReportViewState();
}

class _SalesReportViewState extends State<SalesReportView> {
  List<Sale> results = [];
  bool loading = false;

  int get totalRevenue {
    int total = 0;
    for (var s in results) {
      total += s.total;
    }
    return total;
  }

  Future<void> loadDaily() async {
    setState(() => loading = true);
    results = await SaleService().getSalesByDay(DateTime.now());
    setState(() => loading = false);
  }

  Future<void> loadWeekly() async {
    setState(() => loading = true);
    results = await SaleService().getSalesByWeek(DateTime.now());
    setState(() => loading = false);
  }

  Future<void> loadMonthly() async {
    setState(() => loading = true);
    results = await SaleService().getSalesByMonth(DateTime.now());
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sales Report"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              await SaleService().clearAllSales();
              setState(() {
                results.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: loadDaily, child: Text("Daily")),
              ElevatedButton(onPressed: loadWeekly, child: Text("Weekly")),
              ElevatedButton(onPressed: loadMonthly, child: Text("Monthly")),
            ],
          ),

          SizedBox(height: 10),

          Text(
            "Total Revenue: ₱$totalRevenue",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : results.isEmpty
                    ? Center(child: Text("No sales yet"))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final s = results[index];
                          return ListTile(
                            title: Text('${s.productName} - ${s.qty} pcs'),
                            subtitle:
                                Text("₱${s.total} — ${s.date.substring(0, 10)}"),
                            trailing: Text("₱${s.price}"),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
