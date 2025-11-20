import 'package:cashier_app/home/view/home.dart';
import 'package:cashier_app/home/view/sales_history.dart';
import 'package:cashier_app/home/view/sales_report.dart';
import 'package:flutter/material.dart';


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
            leading: Icon(Icons.shopping_cart),
            title: Text("POS / Cashier"),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => TestView(),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.history),
            title: Text("Sales History"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SalesHistoryView()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.assessment),
            title: Text("Sales Report"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SalesReportView()),
              );
            },
          ),
        ],
      ),
    );
  }
}
