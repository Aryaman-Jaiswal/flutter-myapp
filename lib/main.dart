import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/client_provider.dart';
import 'utils/app_router.dart';
import 'services/database_helper.dart'; 

import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For desktop

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize FFI for desktop platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  await DatabaseHelper().database;
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Create the AuthProvider once and pass it to AppRouter
  final AuthProvider _authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _authProvider),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<ClientProvider>(create: (_) => ClientProvider()),
      ],
      child: Builder(
        builder: (context) {
          final appRouter = AppRouter(_authProvider); 
          return MaterialApp.router(
            title: 'Flutter Auth & Roles App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}