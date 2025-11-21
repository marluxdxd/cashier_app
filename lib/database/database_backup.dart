import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';

class DatabaseBackup {
  static Future<String> getDbPath() async {
    final dbPath = await getDatabasesPath();
    final dir = await getApplicationDocumentsDirectory();
    final databasesPath = await getDatabasesPath();
    final backupPath = join(dir.path, 'backup_app.db');
    return join(databasesPath, 'cashier.db'); // match your AppDB DB name
   
  }

  static Future<String> getBackupDir() async {
    if (Platform.isAndroid) {
      // Request permission
      if (!await Permission.manageExternalStorage.request().isGranted) {
        throw Exception("Storage permission denied");
      }

      

      final dir = Directory('/storage/emulated/0/Download'); 
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
      return dir.path;
    } else {
    // For iOS or other platforms, use app documents directory
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
    }
  }

  /// Backup database
  static Future<String> backupDatabase() async {
  final dbPath = await getDbPath();
  final dbFile = File(dbPath);

  if (!await dbFile.exists()) {
    throw Exception("Database file does not exist.");
  }

   final backupDir = await getBackupDir(); // ✅ use your method here
  final backupPath = join(backupDir, 'backup_app.db');

  await dbFile.copy(backupPath);

  print("Database backed up at: $backupPath");
  return backupPath; // return path in case you want to share/export
}


  /// Restore database
  static Future<void> restoreDatabase() async {
  final backupDir = await getBackupDir(); // ✅ use the same method
  final backupPath = join(backupDir, 'backup_app.db');

  final backupFile = File(backupPath);
  if (!await backupFile.exists()) {
    throw Exception("Backup not found at: $backupPath");
  }

  final dbPath = await getDbPath();
  await deleteDatabase(dbPath); 
  await backupFile.copy(dbPath);

  print("Database restored from backup.");
}


  
}
