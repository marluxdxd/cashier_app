import 'package:cashier_app/database/app_db.dart';
import 'package:cashier_app/home/view/home_admin.dart';
import 'package:cashier_app/home/view/home_user.dart';
import 'package:flutter/material.dart';
import 'package:cashier_app/database/database_backup.dart';

class AppDrawerUser extends StatefulWidget {
  final Future<void> Function()? onProductAdded;
  const AppDrawerUser({super.key, this.onProductAdded});
  @override
  State<AppDrawerUser> createState() => _AppDrawerUserState();
}

class _AppDrawerUserState extends State<AppDrawerUser> {
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
          decoration: InputDecoration(hintText: 'Enter admin password'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 🔥 CHECK IN DATABASE
              final result = await AppDB.instance.login(
                "admin", // username
                passwordController.text,
              );

              if (result != null && result["role"] == "admin") {
                // correct admin
                isCorrect = true;
                Navigator.of(context).pop();
              } else {
                // wrong password
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Wrong password!')));
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
            decoration: BoxDecoration(color: Colors.teal[100]),
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
                                Navigator.pop(context); // close the dialog

                                // 🔥 Navigate back to USER MODE
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => UserView()),
                                );
                              },
                              child: Text('User'),
                            ),

                            SimpleDialogOption(
                              onPressed: () async {
                                bool allowed = await showPasswordDialog(
                                  context,
                                );
                                if (allowed) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TestView1(),
                                    ),
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
                      radius: 100,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/marhon.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              Navigator.pop(context);
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
            ],
          ),
        ],
      ),
    );
  }
}
