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

  // Generate PDF and save to device
  Future<void> generatePDF() async {
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

    final totalRevenue = results.fold(0, (sum, s) => sum + s.total);

    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            "Sales Report",
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),

          pw.Text("Report From: ${dateFormat.format(startDate!)}"),
          pw.Text("Report To      : ${dateFormat.format(endDate!)}"),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text("(Date here)"),
          pw.SizedBox(height: 10),

          ...salesByDate.entries.map((entry) {
  final date = entry.key;
  final sales = entry.value;
  final dayTotal = sales.fold(0, (sum, s) => sum + s.total);

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        DateFormat('MMM d, yyyy').format(DateTime.parse(date)),
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 6),

      // Table header
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              'Item',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(width: 40),
          pw.Expanded(
            child: pw.Text(
              'qty',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(width: 100),
          pw.Text(
            'price',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      pw.SizedBox(height: 4),

      // Table rows
      ...sales.map((s) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(child: pw.Text(s.productName)),
              pw.SizedBox(width: 40),
              pw.Text('${s.qty} pcs'),
              pw.SizedBox(width: 40),
              pw.Text('₱${s.total}'),
            ],
          )),

      pw.SizedBox(height: 6),
      // Day total
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Day Total: ₱$dayTotal',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.Divider(),
    ],
  );
}).toList(),


          pw.SizedBox(height: 15),
          pw.Text(
            "Total Sales: ₱$totalRevenue",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    // Save PDF AFTER adding pages
    final bytes = await pdf.save();

    if (Platform.isAndroid) {
      // request permission (you already do in backup)
      if (!await Permission.manageExternalStorage.request().isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Storage permission denied")));
        return;
      }

      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File('${dir.path}/sales_report.pdf');
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF saved to ${file.path}")));
    } else {
      // fallback for iOS
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sales_report.pdf');
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF saved to ${file.path}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group results for UI
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

          // PDF BUTTON
          ElevatedButton(
            onPressed: generatePDF,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Generate PDF", style: TextStyle(fontSize: 16)),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : salesByDate.isEmpty
                    ? const Center(child: Text("No sales yet"))
                    : ListView(
                        children: salesByDate.entries.map((entry) {
                          final date = entry.key;
                          final sales = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM d, yyyy').format(DateTime.parse(date)),
                                style: const TextStyle(fontSize: 16),
                              ),

                              // Table in UI
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Expanded(
                                        child: Text(
                                          'Item',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(width: 40),
                                      Expanded(
                                        child: Text(
                                          'qty',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(width: 100),
                                      Text(
                                        'price',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  ...sales.map(
                                    (s) => Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${s.productName}'),
                                        Text(' ${s.qty} pcs'),
                                        const SizedBox(width: 40),
                                        Text('₱${s.total}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
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
