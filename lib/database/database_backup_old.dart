// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class DatabaseBackup {
//   /// Check if the device is on Wi-Fi
//   static Future<bool> isWifi() async {
//     var result = await Connectivity().checkConnectivity();
//     return result == ConnectivityResult.wifi;
//   }

//   static Future<String> getDbPath() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final databasesPath = await getDatabasesPath();
//     return join(databasesPath, 'cashier.db'); // match your AppDB DB name
//   }

//   static Future<String> getBackupDir() async {
//     if (Platform.isAndroid) {
//       if (!await Permission.manageExternalStorage.request().isGranted) {
//         throw Exception("Storage permission denied");
//       }

//       final dir = Directory('/storage/emulated/0/Download'); 
//       if (!await dir.exists()) {
//         await dir.create(recursive: true);
//       }
//       return dir.path;
//     } else {
//       final dir = await getApplicationDocumentsDirectory();
//       return dir.path;
//     }
//   }

//   /// Backup database
//   static Future<String> backupDatabase() async {
//     // Optional: check Wi-Fi before backup
//     if (!await isWifi()) {
//       throw Exception("Please connect to Wi-Fi to backup the database.");
//     }

//     final dbPath = await getDbPath();
//     final dbFile = File(dbPath);

//     if (!await dbFile.exists()) {
//       throw Exception("Database file does not exist.");
//     }

//     final backupDir = await getBackupDir();
//     final backupPath = join(backupDir, 'backup_app.db');

//     await dbFile.copy(backupPath);

//     print("Database backed up at: $backupPath");
//     return backupPath;
//   }

//   /// Restore database
//   static Future<void> restoreDatabase() async {
//     final backupDir = await getBackupDir();
//     final backupPath = join(backupDir, 'backup_app.db');

//     final backupFile = File(backupPath);
//     if (!await backupFile.exists()) {
//       throw Exception("Backup not found at: $backupPath");
//     }

//     final dbPath = await getDbPath();
//     await deleteDatabase(dbPath);
//     await backupFile.copy(dbPath);

//     print("Database restored from backup.");
//   }
// }
