import 'package:flutter/material.dart';
import 'package:cashier_app/database/sale_service.dart';
import 'package:cashier_app/home/viewModel/sale.dart';

class SalesHistoryView extends StatefulWidget {
  const SalesHistoryView({super.key});

  @override
  State<SalesHistoryView> createState() => _SalesHistoryViewState();
}

class _SalesHistoryViewState extends State<SalesHistoryView> {
  List<Sale> sales = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    final list = await SaleService().getSales();
    setState(() {
      sales = list;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sales History"),
         actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              await SaleService().clearAllSales();
              setState(() {
                sales.clear();
              });
            },
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : sales.isEmpty
              ? Center(child: Text("No sales yet"))
              : ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          "${sale.productName}  •  Qty: ${sale.qty}",
                        ),
                        subtitle: Text("₱${sale.total}  —  ${sale.date}"),
                        trailing: Text("₱${sale.price}"),
                      ),
                    );
                  },
                ),
    );
  }
}
