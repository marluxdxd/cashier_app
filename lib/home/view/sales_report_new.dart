import 'package:flutter/material.dart';
import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/viewModel/sale.dart';
import 'package:intl/intl.dart';

// PDF packages
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

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

  @override
  void initState() {
    super.initState();
    checkSalesData(); // ✅ call your test function here
  }

  // Test function to see if sales data exists
  Future<void> checkSalesData() async {
    final db = await AppDB.instance.database;
    final result = await db.query('sales');

    if (result.isEmpty) {
      print("No sales data yet.");
    } else {
      print("Sales data found:");
      for (var row in result) {
        print(row); // Each row contains 'productName', 'qty', 'price', 'total', 'date'
      }
    }
  }

  Future<int> deleteSale(int id) async {
    final db = await AppDB.instance.database;
    return await db.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTransaction(Sale sale) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Transaction"),
        content: const Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AppDB.instance.deleteSale(sale.id!);
      await loadSalesByRange(); // Refresh UI
    }
  }

  int get totalRevenue => results.fold(0, (sum, s) => sum + s.total);

  // Load sales within selected date range
  Future<void> loadSalesByRange() async {
    if (startDate == null || endDate == null) return;

    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final end = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      23,
      59,
      59,
    );

    setState(() => loading = true);
    results = await AppDB.instance.getSalesByDateRange(start, end);
    setState(() => loading = false);
  }

  // Generate PDF and open it immediately
  Future<void> generateAndOpenPDF() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select start and end dates")),
      );
      return;
    }

    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Group sales by date
    Map<String, List<Sale>> salesByDate = {};
    for (var sale in results) {
      final dateKey = sale.date.substring(0, 10);
      salesByDate.putIfAbsent(dateKey, () => []);
      salesByDate[dateKey]!.add(sale);
    }

    // Build PDF
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          List<pw.Widget> content = [];
          content.add(
            pw.Text("Sales Report",
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          );
          content.add(pw.SizedBox(height: 5));
          content.add(pw.Text("Report From: ${dateFormat.format(startDate!)}"));
          content.add(pw.Text("Report To  : ${dateFormat.format(endDate!)}"));
          content.add(pw.Divider());
          content.add(pw.SizedBox(height: 10));

          salesByDate.entries.forEach((entry) {
            final date = entry.key;
            final sales = entry.value;

            content.add(
              pw.Text(
                DateFormat('MMM d, yyyy').format(DateTime.parse(date)),
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            );

            content.add(pw.SizedBox(height: 5));

            // Table header
            content.add(
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                      child: pw.Text('Item',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(width: 40),
                  pw.Expanded(
                      child: pw.Text('Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(width: 60),
                  pw.Text('Price',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            );

            // Row items
            sales.forEach((s) {
              content.add(
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text(s.productName)),
                    pw.SizedBox(width: 40),
                    pw.Expanded(child: pw.Text('${s.qty} pcs')),
                    pw.SizedBox(width: 60),
                    pw.Text('₱${s.total}'),
                  ],
                ),
              );
            });

            // Daily subtotal
            final dailyTotal = sales.fold(0, (sum, s) => sum + s.total);

            content.add(pw.SizedBox(height: 5));
            content.add(
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Subtotal: ₱$dailyTotal",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
            );

            content.add(pw.Divider());
          });

          content.add(pw.SizedBox(height: 10));
          content.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text("Total Revenue: ₱$totalRevenue",
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          );

          return content;
        },
      ),
    );

    // Save PDF to Downloads
    if (Platform.isAndroid) {
      if (!await Permission.manageExternalStorage.request().isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) await dir.create(recursive: true);

      final file = File('${dir.path}/sales_report.pdf');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF saved to ${file.path}")),
      );

      await OpenFile.open(file.path); // Open the PDF immediately
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group results for UI table
    Map<String, List<Sale>> salesByDate = {};
    for (var sale in results) {
      final dateKey = sale.date.substring(0, 10);
      salesByDate.putIfAbsent(dateKey, () => []);
      salesByDate[dateKey]!.add(sale);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sales Report")),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "Total Revenue: ₱$totalRevenue",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // DATE PICKERS
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
                child: Text(
                  startDate != null
                      ? DateFormat('yyyy-MM-dd').format(startDate!)
                      : 'Start Date',
                ),
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
                child: Text(
                  endDate != null
                      ? DateFormat('yyyy-MM-dd').format(endDate!)
                      : 'End Date',
                ),
              ),
              ElevatedButton(onPressed: loadSalesByRange, child: const Text("Load")),
            ],
          ),

          const SizedBox(height: 10),
          // Generate PDF button
          ElevatedButton(
            onPressed: generateAndOpenPDF,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Generate PDF", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 10),

          // SALES TABLE PREVIEW
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : salesByDate.isEmpty
                    ? const Center(child: Text("No sales yet"))
                    : ListView(
                        children: salesByDate.entries.map((entry) {
                          final date = entry.key;
                          final sales = entry.value;

                          final dailyTotal = sales.fold(0, (sum, s) => sum + s.total);

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('MMM d, yyyy').format(DateTime.parse(date)),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Expanded(child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold))),
                                      SizedBox(width: 10),
                                      Expanded(child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                                      SizedBox(width: 30),
                                      Text("Price", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(width: 45),
                                    ],
                                  ),
                                  ...sales.map((s) => Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(s.productName)),
                                          const SizedBox(width: 30),
                                          Expanded(child: Text("${s.qty} pcs")),
                                          const SizedBox(width: 60),
                                          Text("₱${s.total}"),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => deleteTransaction(s),
                                          ),
                                        ],
                                      )),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Subtotal: ₱$dailyTotal",
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}
