import 'package:cashier_app/home/view/home.dart';
import 'package:cashier_app/home/view/product_add.dart';
import 'package:cashier_app/home/view/product_list_view.dart';
import 'package:cashier_app/home/view/product_manual.dart';
import 'package:cashier_app/home/view/product_stock.dart';
import 'package:cashier_app/home/view/sales_history.dart';
import 'package:cashier_app/home/view/sales_report.dart';
import 'package:flutter/material.dart';
import 'package:cashier_app/database/database_backup.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppDrawer extends StatefulWidget {
  
 final Future<void> Function()? onProductAdded;  const AppDrawer({super.key, this.onProductAdded}); 
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
 // <-- add this
 Future<bool> showPasswordDialog(BuildContext context) async {
  TextEditingController passwordController = TextEditingController();
  bool isCorrect = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(hintText: 'Enter password'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // close dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (passwordController.text == 'admin123') {
              // ✅ correct password
              isCorrect = true;
              Navigator.of(context).pop();
            } else {
              // ❌ wrong password
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Wrong password!')),
              );
            }
          },
          child: Text('Submit'),
        ),
      ],
    ),
  );

  return isCorrect;
}


 // <-- accept it in constructor
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
             CircleAvatar(
  radius: 65, // size of the circle
  backgroundColor: Colors.white, // optional background color
  child: GestureDetector(
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Select Role'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              print('User selected');
              // handle user role
            },
            child: Text('User'),
          ),
          SimpleDialogOption(
  onPressed: () async {
    bool allowed = await showPasswordDialog(context);
    if (allowed) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TestView1()),
      );
    }
  },
  child: Text('Admin Mode'),
),
        ],
      ),
    );
  },
  child: CircleAvatar(
    radius: 40,
    backgroundColor: Colors.white,
    child: ClipOval(
      child: SvgPicture.asset(
        'assets/icons/salmon-nigiri.svg',
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      ),
    ),
  ),
)

),

              ],
            ),
          ),
 ListTile(
            leading: Icon(Icons.add_moderator_outlined),
            title: Text("Add Products Promo"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                barrierColor: Colors.black.withOpacity(0.2),
                context: context,
                builder: (context) => ProductManual(),
              );
            },
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
