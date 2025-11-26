// import 'package:flutter/material.dart';
// import 'package:cashier_app/database/database_backup.dart'; // <-- import backup class

// class TestBackupPage extends StatefulWidget {
//   const TestBackupPage({super.key});

//   @override
//   State<TestBackupPage> createState() => _TestBackupPageState();
// }

// class _TestBackupPageState extends State<TestBackupPage> {
//   bool isBackingUp = false; // Optional: show progress

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Test Backup'),
//       ),
//       body: Center(
//         child: ElevatedButton.icon(
//           icon: const Icon(Icons.backup),
//           label: isBackingUp
//               ? const Text("Backing up...")
//               : const Text("Test Backup to Firebase"),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//             textStyle: const TextStyle(fontSize: 16),
//           ),
//           onPressed: isBackingUp
//               ? null
//               : () async {
//                   setState(() => isBackingUp = true);
//                   try {
//                     // Perform backup and upload
//                     await DatabaseBackup.autoBackup();
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             "✅ Backup successful at ${DateTime.now().toLocal().toString().substring(11, 19)}",
//                           ),
//                         ),
//                       );
//                     }
//                   } catch (e) {
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("Backup failed: $e")),
//                       );
//                     }
//                   } finally {
//                     if (mounted) setState(() => isBackingUp = false);
//                   }
//                 },
//         ),
//       ),
//     );
//   }
// }
