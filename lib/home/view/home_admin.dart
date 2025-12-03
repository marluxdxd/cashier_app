import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/view/product_picker_bottom_sheet.dart';
import 'package:cashier_app/home/view/product_search.dart';
import 'package:cashier_app/home/view/qty_picker_bottom_sheet.dart';
import 'package:cashier_app/home/viewModel/sync_status.dart';
import 'package:cashier_app/widget/app_drawer.dart';
import 'package:cashier_app/widget/app_drawer_user.dart';
import 'package:cashier_app/widget/notificationbell.dart';
import 'package:cashier_app/home/view/product_notification.dart';
import 'package:cashier_app/home/viewModel/sale_service.dart';
import 'package:cashier_app/home/viewModel/customer_cash.dart';
import 'package:cashier_app/home/viewModel/product.dart';
import 'package:cashier_app/home/viewModel/row.dart';
import 'package:cashier_app/home/viewModel/sale.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestView1 extends StatefulWidget {
  const TestView1({super.key});

  @override
  State<TestView1> createState() => _TestView1State();
}

class _TestView1State extends State<TestView1> {
  final SaleService saleService = SaleService();

  List<GlobalKey<DropdownSearchState<Product>>> productDropdownKeys = [];
  List<GlobalKey<DropdownSearchState<int>>> qtyDropdownKeys = [];
  List<GlobalKey> productInkWellKeys = [];
List<FocusNode> productFocusNodes = [];
  List<Product> dbProducts = [];
  List<RowData> rows = [];

  bool transactionSaved = false;

  final FocusNode customerCashFocusNode = FocusNode();
  TextEditingController customerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    rows.add(RowData());
    productDropdownKeys.add(GlobalKey<DropdownSearchState<Product>>());
    qtyDropdownKeys.add(GlobalKey<DropdownSearchState<int>>());
    productFocusNodes.add(FocusNode()); // first product field
    loadProducts();
  }

  Future<void> loadProducts() async {
    await AppDB.instance.seedDefaultProducts();
    final productsFromDB = await AppDB.instance.fetchProducts();
    setState(() {
      dbProducts = productsFromDB;
    });
  }

  Future<void> syncTransaction(int amount) async {
    final syncStatus = Provider.of<SyncStatus>(context, listen: false);
    syncStatus.startSync();

    final supabase = Supabase.instance.client;

    try {
      await supabase.from('transactions').insert({
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
      });

      syncStatus.finishSync(success: true);
    } catch (e) {
      syncStatus.finishSync(success: false);
    }
  }

  Future<void> fullRefresh() async {
    setState(() {
      dbProducts = [];
      rows.clear();
      rows.add(RowData());
      customerController.clear();
      transactionSaved = false;

      productDropdownKeys = [GlobalKey<DropdownSearchState<Product>>()];
      qtyDropdownKeys = [GlobalKey<DropdownSearchState<int>>()];
    });

    await loadProducts();
  }

  int calculateTotal(RowData row) {
  if (row.product == null) return 0;

  final price = row.product!.price.toInt();

  // PROMO: total = price (do not multiply qty)
  if (row.product!.promo) {
    return price;
  }

  // NORMAL: qty × price
  return row.qty * price;
}


  int get totalBill => rows.fold(0, (sum, row) => sum + calculateTotal(row));

  void _addEmptyRow() {
    setState(() {
      rows.add(RowData());
      productFocusNodes.add(FocusNode()); // focus node for new row
      productDropdownKeys.add(GlobalKey<DropdownSearchState<Product>>());
      qtyDropdownKeys.add(GlobalKey<DropdownSearchState<int>>());
      productInkWellKeys.add(GlobalKey());
    });
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
              "${row.product!.name} (Available: ${row.product!.qty})");
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
      }
    }

    int change = int.tryParse(customerController.text)! - totalBill;

    setState(() {
      rows.clear();
      rows.add(RowData());
      customerController.clear();
      transactionSaved = false;
      productDropdownKeys = [GlobalKey<DropdownSearchState<Product>>()];
      qtyDropdownKeys = [GlobalKey<DropdownSearchState<int>>()];
      productInkWellKeys = [];
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

    await syncTransaction(totalBill);
  }

  List<String> getLowStockItems() {
    
    return dbProducts
        .where((p) => p.qty < 10)
        .map((p) => "${p.name} (Qty: ${p.qty})")
        .toList();
  }

  Widget buildPOSRow(RowData row, int index, bool isSmall) {
    if (productInkWellKeys.length <= index) productInkWellKeys.add(GlobalKey());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: isSmall
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: InkWell(
                        key: productInkWellKeys[index],
                        onTap: () async {
                          final selectedProduct =
                              await showModalBottomSheet<Product>(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16))),
                            builder: (_) =>
                                ProductPickerBottomSheet(products: dbProducts),
                          );

                          if (selectedProduct == null) return;

                          setState(() {
                            row.product = selectedProduct;
                            row.qty = selectedProduct.promo
                                ? selectedProduct.otherqty
                                : (row.qty == 0 ? 1 : row.qty);

                            if (row == rows.last) _addEmptyRow();

                            
                          });

                          if (!selectedProduct.promo) {
                            final selectedQty =
                                await showModalBottomSheet<int>(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16))),
                              builder: (_) => QtyPickerBottomSheet(maxQty: 50),
                            );

                            if (selectedQty != null) {
                              setState(() => row.qty = selectedQty);
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            row.product?.name ?? "Select product...",
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: row.product == null
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text(''),
                            )
                          : row.product!.promo
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey[200],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${row.product!.otherqty}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : InkWell(
                                  onTap: () async {
                                    final selectedQty =
                                        await showModalBottomSheet<int>(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16))),
                                      builder: (_) =>
                                          QtyPickerBottomSheet(maxQty: 50),
                                    );
                                    if (selectedQty != null) {
                                      setState(() {
                                        row.qty = selectedQty;
                                        if (row == rows.last) _addEmptyRow();
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4)),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${row.qty > 0 ? row.qty : ''}",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text("₱${row.product?.price ?? 0}",
                          style: TextStyle(fontSize: 14)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text("₱${calculateTotal(row)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          if (rows.length > 1) rows.removeAt(index);
                        });
                      },
                    ),
                  ],
                )
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 5,
                  child: InkWell(
                    key: productInkWellKeys[index],
                    onTap: () async {
                      final selectedProduct =
                          await showModalBottomSheet<Product>(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16))),
                        builder: (_) =>
                            ProductPickerBottomSheet(products: dbProducts),
                      );

                      if (selectedProduct == null) return;

                      setState(() {
                        row.product = selectedProduct;
                        row.qty = selectedProduct.promo
                            ? selectedProduct.otherqty
                            : (row.qty == 0 ? 1 : row.qty);

                        if (row == rows.last) _addEmptyRow();
                      });

                      if (!selectedProduct.promo) {
                        final selectedQty = await showModalBottomSheet<int>(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16))),
                          builder: (_) => QtyPickerBottomSheet(maxQty: 50),
                        );

                        if (selectedQty != null) {
                          setState(() => row.qty = selectedQty);
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        row.product?.name ?? "Select product...",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () async {
                      if (row.product != null && !row.product!.promo) {
                        final selectedQty = await showModalBottomSheet<int>(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(16))),
                          builder: (_) => QtyPickerBottomSheet(maxQty: 50),
                        );

                        if (selectedQty != null) {
                          setState(() {
                            row.qty = selectedQty;
                          });
                        }
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                          color: row.product?.promo == true
                              ? Colors.grey[200]
                              : Colors.white),
                      alignment: Alignment.center,
                      child: Text(
                        row.product?.promo == true
                            ? "${row.product!.otherqty}"
                            : "${row.qty > 0 ? row.qty : ''}",
                        style: TextStyle(
                            fontWeight: row.product?.promo == true
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    "₱${row.product?.price ?? 0}",
                      textAlign: TextAlign.center),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text("₱${calculateTotal(row)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        if (rows.length > 1) rows.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Sari-Sari Stre',
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
            icon: Icon(Icons.search, color: Colors.black, size: 30),
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.2),
                builder: (_) => SearchProduct(),
              );
            },
          ),

          SizedBox(width: 20),
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
              SizedBox(height: 20),
              ...rows
                  .asMap()
                  .entries
                  .map((e) => buildPOSRow(e.value, e.key, isSmall))
                  ,
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
                    Text("Total Bill",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("₱$totalBill",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
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
