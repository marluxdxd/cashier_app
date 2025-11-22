import 'package:cashier_app/home/view/product_form.dart';
import 'package:cashier_app/home/view/product_list_view.dart';
import 'package:cashier_app/home/view/product_stock.dart';
import 'package:cashier_app/home/view/sales_history.dart';
import 'package:cashier_app/home/view/sales_report.dart';
import 'package:flutter/material.dart';
import 'package:cashier_app/database/database_backup.dart';

class AppDrawer extends StatelessWidget {
  
 final Future<void> Function()? onProductAdded; // <-- add this

 Future<bool> showAdminPasswordDialog(BuildContext context) async {
  final TextEditingController passwordController = TextEditingController();
  bool isAdmin = false;

  await showDialog(
    context: context,
    barrierDismissible: false, // User must tap a button
    builder: (_) => AlertDialog(
      title: Text("Admin Access"),
      content: TextField(
        controller: passwordController,
        obscureText: true, // hide input
        decoration: InputDecoration(labelText: "Enter password"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cancel
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (passwordController.text == "marhon") {
              isAdmin = true; // correct password
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Wrong password!")),
              );
            }
          },
          child: Text("Enter"),
        ),
      ],
    ),
  );

  return isAdmin; // true if correct password
}


  const AppDrawer({super.key, this.onProductAdded}); // <-- accept it in constructor

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Honey Sari-Sari Store",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
     ListTile(
  leading: Icon(Icons.inventory_rounded),
  title: Text("Add Products"),
  onTap: () {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AddProduct(
        onProductAdded: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Product added successfully!")),
          );
        },
      ),
    );
  },
),



          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text("View all products"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                barrierColor: Colors.black.withOpacity(0.2),
                context: context,
                builder: (context) => ProductListView(),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.storefront_sharp),
            title: Text("Stock"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                barrierColor: Colors.black.withOpacity(0.2),
                context: context,
                builder: (context) => ProductStock(),
              );
            },
          ),
            ListTile(
            leading: Icon(Icons.history),
            title: Text("Sales History"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                barrierColor: Colors.black.withOpacity(0.2),
                context: context,
                builder: (context) => SalesHistoryView(),
              );
            },
          ),
            ListTile(
            leading: Icon(Icons.campaign),
            title: Text("Sales Report"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                barrierColor: Colors.black.withOpacity(0.2),
                context: context,
                builder: (context) => SalesReportView(),
              );
            },
          ),

          ExpansionTile(
            leading: Icon(Icons.storage),
            title: Text("Database"),
            children: [
              // Backup Database
              ListTile(
                leading: Icon(Icons.backup),
                title: Text("Backup Database"),
                onTap: () async {
                  try {
                    await DatabaseBackup.backupDatabase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Database backup completed!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Backup failed: $e")),
                    );
                  }
                },
              ),

              // Restore Database
              ListTile(
                leading: Icon(Icons.restore),
                title: Text("Restore Database"),
                onTap: () async {
                  try {
                    await DatabaseBackup.restoreDatabase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Database restored!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Restore failed: $e")),
                    );
                  }
                },
              ),
            ],
          ),
          

          
        ],
      ),
    );
  }
}
