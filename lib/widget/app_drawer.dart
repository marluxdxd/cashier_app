import 'package:cashier_app/home/view/home.dart';
import 'package:cashier_app/home/view/product_form.dart';
import 'package:cashier_app/home/view/product_list_view.dart';
import 'package:cashier_app/home/view/product_stock.dart';
import 'package:cashier_app/home/view/sales_history.dart';
import 'package:cashier_app/home/view/sales_report.dart';
import 'package:flutter/material.dart';
import 'package:cashier_app/database/database_backup.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
                barrierColor: Colors.black.withOpacity(0.2),
                context: context,
                builder: (context) => AddProduct(),
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
            leading: Icon(Icons.list_alt),
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
