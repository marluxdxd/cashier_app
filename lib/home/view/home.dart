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
  Product? selectedProduct;
  int qty = 0;
  List<Product> dbProducts = [];
  bool promo = false; // default ON
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

  final product = row.product!;
  final qty = row.qty;
  final price = product.price.toInt();

  if (product.promo) { // if product is active promo
    promo = true;
    return (qty * price) - 1;

  }
 if (product == promo) { // if product is active promo
      for (int q = 3; q < 12; q += 2) {
    print(q);
    }
  
  }
  return qty * price;
}


  int get totalBill {
    int sum = 0;

    for (var row in rows) {
      final price = row.product?.price ?? 0; // double or int
      sum += calculateTotal(row);
    }

    return sum;
  }

  TextEditingController customerController = TextEditingController();

  int get change {
    int customerCash = int.tryParse(customerController.text) ?? 0;
    return customerCash - totalBill;
  }

  void controllerClearCustomerCash() {
    setState(() {
      customerController.clear();
    });
  }

  // ✅ PUT THE FUNCTION HERE
  void saveTransaction() async {
    if (transactionSaved) return;
    transactionSaved = true;

    final service = SaleService();

    for (var row in rows) {
      if (row.product != null && row.qty > 0) {
        try {
          // ⭐ CHECK STOCK
          row.product!.reduceStock(row.qty);
        } catch (e) {
          // ⭐ SHOW STOCK ERROR
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll("Exception:", "").trim()),
            ),
          );

          // ⭐ CLEAR CUSTOMER CASH FIELD
          controllerClearCustomerCash();

          transactionSaved = false;
          return;
        }

        // ⭐ SAVE SALE
        final sale = Sale(
          productName: row.product!.name,
          qty: row.qty,
          price: row.product!.price.toInt(),
          total: calculateTotal(row), // total after promo

          date: DateTime.now().toIso8601String(),
        );

        await service.insertSale(sale);

        // ⭐ UPDATE STOCK IN DATABASE
        await AppDB.instance.updateProduct(row.product!);
      }
    }

    int finalChange = int.tryParse(customerController.text)! - totalBill;

    // ⭐ RESET UI AFTER SUCCESS
    setState(() {
      rows.clear();
      rows.add(RowData());
      customerController.clear();
      transactionSaved = false;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Column(
            children: [
              Text('Sukli'),
              Text(
                "$finalChange",
                style: TextStyle(fontSize: 100, color: Colors.red),
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
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    showDialog(
                     barrierColor: Colors.black.withOpacity(0.2),
                  context: context,
                    builder: (context) => ProductNotification(),
                    );
                  }, 
                ),
                SizedBox(width: 20,),
                IconButton(onPressed:(){
                   showDialog(
                      barrierColor: Colors.black.withOpacity(0.2),
                      context: context,
                      builder: (context) => SearchProduct(),
                    );
                }, icon: Icon(Icons.search)),
             
                
              ],
            ),
          ),
        ],
      ),

      // ✅ Wrap drawer with callback to refresh products
      drawer: AppDrawer(
        onProductAdded: () async {
          await loadProducts(); // reload products after adding
        },
      ),

      // ✅ Wrap body with RefreshIndicator
      body: RefreshIndicator(
        onRefresh: loadProducts, // called when user pulls down

        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // allows scroll for RefreshIndicator
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              

             IconButton(
  icon: Icon(Icons.textsms_sharp),
  onPressed: () {
    bool promo = false;
    int qty = 3;
    int price = 1;

    


    if (!promo) {
       print("Promo not applied for $qty items");

    
    }
  },
),


              
              SizedBox(height: 200),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FixedColumnWidth(80), // Qty
                    1: FixedColumnWidth(150), // Item
                    2: FixedColumnWidth(80), // Price
                    3: FixedColumnWidth(100), // Total
                    4: FixedColumnWidth(150), // Action buttons
                  },
                  children: [
                    TableRow(
                      children: [
                        Text(
                          'Qty',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Item',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Price',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Action',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    ...rows.map((row) {
                      return TableRow(
                        children: [
                          DropdownButton<int>(
                            value: row.qty == 0 ? null : row.qty,
                            isExpanded: true,
                            underline: SizedBox(),
                            hint: Text("0"),
                           items: List.generate(20, (index) {
  int step = row.product?.otherqty ?? 1;
  if (step <= 0) step = 1;

  int number = (index + 1) * step;  // multiples
  return DropdownMenuItem(
    value: number,
    child: Text(number.toString()),
  );
}),

                       onChanged: (value) {
  setState(() {
    row.qty = value!;

    // ⭐ get the step from product.otherqty
    if (row.product != null) {
      int step = row.product!.otherqty;   // <-- your correct step
      if (step <= 0) step = 1;

      // ⭐ auto-correct qty to nearest valid multiple
      if (row.qty % step != 0) {
        row.qty = ((row.qty / step).ceil()) * step;
        print("Corrected qty to: ${row.qty}");
      }
    }
  });
},


                          ),

                          DropdownSearch<Product>(
                            items: dbProducts, // list of products
                            itemAsString: (p) => p.name, // display product name
                            selectedItem: row.product, // currently selected
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                hintText: "Select ",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            popupProps: PopupProps.menu(
                              showSearchBox: true, // enable search
                              searchFieldProps: TextFieldProps(
                                autofocus:
                                    true, // focus the search box immediately
                                    decoration: InputDecoration(
                                  hintText: 'Search product...',
                                   contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                   )
                              ),
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(title: Text(item.name));
                              },
                            ),
                            onChanged: (p) {
                              setState(() {
                                row.product = p;
                                if (row == rows.last) rows.add(RowData()); // keep adding row if last
                              });
                            },
                          ),

                          Text(row.product?.price.toString() ?? '0'),
                          Text(calculateTotal(row).toString()),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // IconButton(
                              //   icon: Icon(
                              //     Icons.local_offer,
                              //     color: promo
                              //         ? Colors.green
                              //         : Colors.grey,
                              //   ),
                              //   onPressed: () {
                              //     setState(() {
                              //       promo = !promo;
                              //     });
                              //   },
                              // ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    if (rows.length > 1) rows.remove(row);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Text(
                'Total Bill: $totalBill',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              CustomerCashField(
                controller: customerController,
                totalBill: totalBill,
                transactionSaved: transactionSaved,
                saveTransaction: saveTransaction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeView1 extends StatelessWidget {
  const HomeView1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Honey Sari-Sari Store',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      // ⭐ ADD DRAWER HERE
      drawer: AppDrawer(),

      body: Center(child: Column(children: [SizedBox(height: 50)])),
    );
  }
}
