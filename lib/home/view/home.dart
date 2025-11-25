import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/view/product_notification.dart';
import 'package:cashier_app/home/viewModel/sale_service.dart';
import 'package:cashier_app/home/view/customer_cash.dart';
import 'package:cashier_app/home/view/product_search.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/home/viewModel/row.dart';
import 'package:cashier_app/data/row_data.dart';
import 'package:cashier_app/home/viewModel/sale.dart';
import 'package:cashier_app/widget/app_drawer.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class TestView1 extends StatefulWidget {
  const TestView1({super.key});

  @override
  State<TestView1> createState() => _TestView1State();
}

class _TestView1State extends State<TestView1> {
  bool transactionSaved = false;
  List<Product> dbProducts = [];
  bool promo = false;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    await AppDB.instance.seedDefaultProducts();
    final productsFromDB = await AppDB.instance.fetchProducts();
    setState(() {
      dbProducts = productsFromDB;
    });
  }

  int calculateTotal(RowData row) {
    if (row.product == null) return 0;
    final p = row.product!;
    final price = p.price.toInt();

    if (p.promo) return (row.qty * price) - 1;

    return row.qty * price;
  }

  int get totalBill => rows.fold(0, (sum, row) => sum + calculateTotal(row));

  TextEditingController customerController = TextEditingController();

  void controllerClearCustomerCash() {
    setState(() => customerController.clear());
  }

  void saveTransaction() async {
    if (transactionSaved) return;
    transactionSaved = true;
    final service = SaleService();

    for (var row in rows) {
      if (row.product != null && row.qty > 0) {
        try {
          row.product!.reduceStock(row.qty);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll("Exception:", "").trim()),
            ),
          );
          transactionSaved = false;
          return;
        }

        final sale = Sale(
          productName: row.product!.name,
          qty: row.qty,
          price: row.product!.price.toInt(),
          total: calculateTotal(row),
          date: DateTime.now().toIso8601String(),
        );

        await service.insertSale(sale);
        await AppDB.instance.updateProduct(row.product!);
      }
    }

    int change = int.tryParse(customerController.text)! - totalBill;

    setState(() {
      rows.clear();
      rows.add(RowData());
      customerController.clear();
      transactionSaved = false;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Column(
            children: [
              Text(
                'Sukli',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "$change",
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Honey Sari-Sari Store',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.2),
                builder: (_) => ProductNotification(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.2),
                builder: (_) => SearchProduct(),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(onProductAdded: () async => await loadProducts()),
      body: RefreshIndicator(
        onRefresh: loadProducts,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// =====================================================================
              /// DATA TABLE (UPDATED, SCALED, CLEAN)
              /// =====================================================================
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        Colors.grey[200],
                      ),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text("Item")),
                        DataColumn(label: Text("Qty")),
                        DataColumn(label: Text("Price")),
                        DataColumn(label: Text("Total")),
                        DataColumn(label: Text("")),
                      ],
                      rows: rows.map((row) {
                        int? dropdownValue = row.qty == 0 ? null : row.qty;

                        List<DropdownMenuItem<int>> qtyItems =
                            (row.product?.promo ?? false)
                            ? [
                                DropdownMenuItem(
                                  value: row.product?.otherqty ?? 1,
                                  child: Text("${row.product?.otherqty ?? 1}"),
                                ),
                              ]
                            : List.generate(20, (i) {
                                int n = i + 1;
                                return DropdownMenuItem(
                                  value: n,
                                  child: Text("$n"),
                                );
                              });

                        return DataRow(
                          cells: [
                            /// ITEM — Fixed width + ellipsis
                            DataCell(
                              SizedBox(
                                width: 270,
                                child: DropdownSearch<Product>(
                                  items: dbProducts,
                                  selectedItem: row.product,
                                  itemAsString: (p) => p.name,
                                  dropdownBuilder: (context, p) => Text(
                                    p?.name ?? "Select...",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                            ),
                                      ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        hintText: "Search...",
                                      ),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    itemBuilder: (context, item, isSelected) {
                                      return Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          title: Text(
                                            item.name,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          selected: isSelected,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  onChanged: (p) {
                                    setState(() {
                                      row.product = p;
                                      if (row == rows.last) rows.add(RowData());
                                    });
                                  },
                                ),
                              ),
                            ),

                            /// QTY — Small column
                            DataCell(
                              SizedBox(
                                width: 60,
                                child: DropdownButton<int>(
                                  value: dropdownValue,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  items: qtyItems,
                                  onChanged: (v) =>
                                      setState(() => row.qty = v!),
                                ),
                              ),
                            ),

                            /// PRICE — Narrow column
                            DataCell(
                              SizedBox(
                                width: 60,
                                child: Text(
                                  "${row.product?.price ?? 0}",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            /// TOTAL — Narrow column
                            DataCell(
                              SizedBox(
                                width: 70,
                                child: Text(
                                  "${calculateTotal(row)}",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            /// ACTION — Smallest column
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    if (rows.length > 1) rows.remove(row);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              /// TOTAL BILL
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.grey.withOpacity(0.2),
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Bill",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "₱$totalBill",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              CustomerCashField(
                controller: customerController,
                totalBill: totalBill,
                transactionSaved: transactionSaved,
                saveTransaction: saveTransaction,
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
