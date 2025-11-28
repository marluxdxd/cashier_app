import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/widget/notificationbell.dart';
import 'package:cashier_app/home/view/product_notification.dart';
import 'package:cashier_app/home/viewModel/sale_service.dart';
import 'package:cashier_app/home/viewModel/customer_cash.dart';
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
  String? selectedValue;

  // lists of keys for each row
  List<GlobalKey<DropdownSearchState<Product>>> productDropdownKeys = [];
  List<GlobalKey<DropdownSearchState<int>>> qtyDropdownKeys = [];

  List<String> fruits = ['Apple', 'Banana', 'Cherry', 'Date'];

  List<String> getLowStockItems() {
    return dbProducts
        .where((p) => p.qty < 10) // pick only low-stock products
        .map((p) => "${p.name} (Qty: ${p.qty})") // convert to string
        .toList();
  }

  // Focus nodes for item, quantity, and customer cash
  final FocusNode searchFocusNode = FocusNode();
  final FocusNode qtyFocusNode = FocusNode();
  final FocusNode customerCashFocusNode = FocusNode();

  bool transactionSaved = false;
  List<Product> dbProducts = [];
  bool promo = false;

  // local rows state (keeps behavior predictable)
  List<RowData> rows = [];

  @override
  void initState() {
    super.initState();
    // initialize rows and keys
    rows.add(RowData());
    productDropdownKeys.add(GlobalKey<DropdownSearchState<Product>>());
    qtyDropdownKeys.add(GlobalKey<DropdownSearchState<int>>());

    loadProducts();
  }

  Future<void> loadProducts() async {
    await AppDB.instance.seedDefaultProducts();
    final productsFromDB = await AppDB.instance.fetchProducts();
    setState(() {
      dbProducts = productsFromDB;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (productDropdownKeys.isNotEmpty &&
          dbProducts.isNotEmpty &&
          productDropdownKeys[0].currentState != null) {
        productDropdownKeys[0].currentState!.openDropDownSearch();
      }
    });
  }

  Future<void> fullRefresh() async {
    setState(() {
      dbProducts = [];
      rows.clear();
      rows.add(RowData());
      customerController.clear();
      transactionSaved = false;

      // Reset keys
      productDropdownKeys = [GlobalKey<DropdownSearchState<Product>>()];
      qtyDropdownKeys = [GlobalKey<DropdownSearchState<int>>()];
    });

    await loadProducts();
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

    List<String> insufficientStockProducts = [];

    for (var row in rows) {
      if (row.product != null && row.qty > 0) {
        if (row.qty > row.product!.qty) {
          insufficientStockProducts.add(
            "${row.product!.name} (Available left: ${row.product!.qty})",
          );
        }
      }
    }

    if (insufficientStockProducts.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Not enough stock for:\n${insufficientStockProducts.join('\n')}",
          ),
          duration: Duration(seconds: 4),
        ),
      );
      transactionSaved = false;
      return;
    }

    for (var row in rows) {
      if (row.product != null && row.qty > 0) {
        row.product!.reduceStock(row.qty);

        final sale = Sale(
          productName: row.product!.name,
          qty: row.qty,
          price: row.product!.price.toInt(),
          total: calculateTotal(row),
          date: DateTime.now().toIso8601String(),
        );

        await service.insertSale(sale);
        await AppDB.instance.updateProduct(row.product!);

        setState(() {});
      }
    }

    int change = int.tryParse(customerController.text)! - totalBill;

    setState(() {
      rows.clear();
      rows.add(RowData());
      customerController.clear();
      transactionSaved = false;

      // Reset keys
      productDropdownKeys = [GlobalKey<DropdownSearchState<Product>>()];
      qtyDropdownKeys = [GlobalKey<DropdownSearchState<int>>()];
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  fontSize: 150,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // helper to add a new row and matching keys
  void _addEmptyRow() {
    setState(() {
      rows.add(RowData());
      productDropdownKeys.add(GlobalKey<DropdownSearchState<Product>>());
      qtyDropdownKeys.add(GlobalKey<DropdownSearchState<int>>());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380; // responsive trigger, adjust as needed

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Sari-Sari Store',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          NotificationBell(
            lowItems: getLowStockItems(),
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.2),
                builder: (_) =>
                    ProductNotification(lowItems: getLowStockItems()),
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
        onRefresh: fullRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('test'),
                  Text('test'),
                ],
              ),
              
              SizedBox(height: 20),
              // keep small dropdown (unchanged)

              // Card containing responsive rows
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // header for wide screens
                      if (!isSmall)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          color: Colors.grey[200],
                          child: Row(
                            children: [
                              Expanded(flex: 5, child: Text("Item")),
                              SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Text("Qty", textAlign: TextAlign.center),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Price",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Total",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: 8),
                              SizedBox(
                                width: 40,
                                child: Text("", textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 8),

                      // rows
                      ...rows.map((row) {
                        int index = rows.indexOf(row);
                        List<int> qtyItems = (row.product?.promo ?? false)
                            ? [row.product?.otherqty ?? 1]
                            : List.generate(20, (i) => i + 1);

                        // ensure keys lists are in sync
                        if (productDropdownKeys.length <= index) {
                          productDropdownKeys.add(
                            GlobalKey<DropdownSearchState<Product>>(),
                          );
                        }
                        if (qtyDropdownKeys.length <= index) {
                          qtyDropdownKeys.add(
                            GlobalKey<DropdownSearchState<int>>(),
                          );
                        }

                        if (isSmall) {
                          // Compact A2 layout: Item + Qty on first line, Price/Total/Delete on second line
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Item (takes most space)
                                    Expanded(
                                      flex: 6,
                                      child: DropdownSearch<Product>(
                                        key: productDropdownKeys[index],
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
                                                    border:
                                                        OutlineInputBorder(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                  ),
                                            ),
                                        popupProps: PopupProps.menu(
                                          showSearchBox: true,
                                          emptyBuilder:
                                              (context, searchEntry) => Center(
                                                child: Text(
                                                  "Loading products...",
                                                ),
                                              ),
                                          searchFieldProps: TextFieldProps(
                                            focusNode: searchFocusNode,
                                            autofocus: true,
                                            decoration: InputDecoration(
                                              hintText: "Search...",
                                            ),
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        onChanged: (p) {
                                          setState(() {
                                            row.product = p;
                                            if (row.product != null) {
                                              if (row.product!.promo) {
                                                row.qty = row.product!.otherqty;
                                              } else if (row.qty == 0) {
                                                row.qty = 1;
                                              }
                                            }

                                            // focus qty
                                            FocusScope.of(
                                              context,
                                            ).requestFocus(qtyFocusNode);

                                            // try to open qty dropdown for this row
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                                  if (qtyDropdownKeys[index]
                                                          .currentState !=
                                                      null) {
                                                    qtyDropdownKeys[index]
                                                        .currentState!
                                                        .openDropDownSearch();
                                                  }
                                                });

                                            // add new row if last
                                            if (row == rows.last) {
                                              _addEmptyRow();
                                            }
                                          });
                                        },
                                      ),
                                    ),

                                    SizedBox(width: 8),

                                    // Qty (compact, beside item)
                                    Expanded(
                                      flex: 2,
                                      child: DropdownSearch<int>(
                                        key: qtyDropdownKeys[index],
                                        items: qtyItems,
                                        selectedItem: row.qty,
                                        popupProps: PopupProps.menu(
                                          showSearchBox: true,
                                          searchFieldProps: TextFieldProps(
                                            keyboardType: TextInputType.number,
                                            focusNode: qtyFocusNode,
                                            autofocus: true,
                                            decoration: InputDecoration(
                                              hintText: "Qty",
                                            ),
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        dropdownBuilder:
                                            (context, selectedQty) {
                                              return Text(
                                                "${selectedQty ?? ''}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 14),
                                              );
                                            },
                                        onChanged: (v) {
                                          setState(() {
                                            if (v != null) row.qty = v;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Price
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "₱${row.product?.price ?? 0}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),

                                    // Total
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "₱${calculateTotal(row)}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                    // Delete
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (rows.length > 1) {
                                            rows.removeAt(index);
                                            // keep keys in sync
                                            if (productDropdownKeys.length >
                                                index)
                                              productDropdownKeys.removeAt(
                                                index,
                                              );
                                            if (qtyDropdownKeys.length > index)
                                              qtyDropdownKeys.removeAt(index);
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Wide layout (single-line row)
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: DropdownSearch<Product>(
                                    key: productDropdownKeys[index],
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
                                      emptyBuilder: (context, searchEntry) =>
                                          Center(
                                            child: Text("Loading products..."),
                                          ),
                                      searchFieldProps: TextFieldProps(
                                        focusNode: searchFocusNode,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          hintText: "Search...",
                                        ),
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    onChanged: (p) {
                                      setState(() {
                                        row.product = p;
                                        if (row.product != null) {
                                          if (row.product!.promo) {
                                            row.qty = row.product!.otherqty;
                                          } else if (row.qty == 0) {
                                            row.qty = 1;
                                          }
                                        }

                                        // focus qty
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(qtyFocusNode);

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (qtyDropdownKeys[index]
                                                      .currentState !=
                                                  null) {
                                                qtyDropdownKeys[index]
                                                    .currentState!
                                                    .openDropDownSearch();
                                              }
                                            });

                                        if (row == rows.last) {
                                          _addEmptyRow();
                                        }
                                      });
                                    },
                                  ),
                                ),

                                SizedBox(width: 8),

                                Expanded(
                                  flex: 2,
                                  child: DropdownSearch<int>(
                                    key: qtyDropdownKeys[index],
                                    items: qtyItems,
                                    selectedItem: row.qty,
                                    popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                      searchFieldProps: TextFieldProps(
                                        keyboardType: TextInputType.number,
                                        focusNode: qtyFocusNode,
                                        autofocus: false,
                                        decoration: InputDecoration(
                                          hintText: "Qty",
                                        ),
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    dropdownBuilder: (context, selectedQty) {
                                      return Text(
                                        "${selectedQty ?? ''}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14),
                                      );
                                    },
                                    onChanged: (v) {
                                      setState(() {
                                        if (v != null) row.qty = v;
                                      });
                                    },
                                  ),
                                ),

                                SizedBox(width: 8),

                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "₱${row.product?.price ?? 0}",
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                SizedBox(width: 8),

                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "₱${calculateTotal(row)}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 8),

                                SizedBox(
                                  width: 40,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        if (rows.length > 1) {
                                          rows.removeAt(index);
                                          if (productDropdownKeys.length >
                                              index)
                                            productDropdownKeys.removeAt(index);
                                          if (qtyDropdownKeys.length > index)
                                            qtyDropdownKeys.removeAt(index);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }).toList(),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

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
                        color: Colors.red,
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
                focusNode: customerCashFocusNode,
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
