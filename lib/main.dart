import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_router.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/client_provider.dart';
import 'providers/task_provider.dart';
import 'services/database_helper.dart';
import 'providers/project_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseFactory factory;
  if (kIsWeb) {
    factory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    factory = databaseFactoryFfi;
  } else {
    factory = databaseFactory;
  }

  databaseFactory = factory;

  await DatabaseHelper().database;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<ClientProvider>(create: (_) => ClientProvider()),
        ChangeNotifierProvider<ProjectProvider>(
          create: (_) => ProjectProvider(),
        ), // For high-level projects
        ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider()),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = Provider.of<AuthProvider>(context);
          return MaterialApp.router(
            title: 'Flutter Auth & Roles App',
            debugShowCheckedModeBanner: false,
            // --- UPDATED THEME FOR MATERIAL 3 ---
            theme: ThemeData(
              useMaterial3: true, // Enable Material 3
              // For M3, ColorScheme is the primary way to define colors.
              // We'll create a scheme from a seed color.
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF), // A nice purple/blue seed
                // You can optionally override specific colors
                // primary: const Color(0xFF6C63FF),
                // secondary: Colors.teal,
                // background: Colors.grey[50], // If you want a specific background
              ),
              // You can still define specific component themes if needed
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routerConfig: AppRouter(authProvider).router,
          );
        },
      ),
    );
  }
}
