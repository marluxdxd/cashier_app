import 'package:cashier_app/home/view/home_user.dart';
import 'package:cashier_app/home/viewModel/sync_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashier_app/services/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://omlbqcpyinbdgtanckfk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9tbGJxY3B5aW5iZGd0YW5ja2ZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzODA1NDMsImV4cCI6MjA3OTk1NjU0M30.7bNWGAuT2R_HYPlklt9XEeim-3XdQNymoWSgw6tYOwk',
  );

  // 🔥 START AUTO SYNC
  SyncService.instance.startAutoSync();

  runApp(
    ChangeNotifierProvider(
      create: (context) => SyncStatus(), // Provide SyncStatus to the app
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Marhon',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: UserView(),
    );
  }
}
