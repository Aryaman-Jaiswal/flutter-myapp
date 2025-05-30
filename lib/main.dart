import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/auth/login_screen.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/client_provider.dart';
import 'providers/project_provider.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Auth & Roles App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: const Color(0xFF6C63FF),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepPurple,
          ).copyWith(primary: const Color(0xFF6C63FF), secondary: Colors.teal),
        ),
        home: LoginScreen(),
      ),
    );
  }
}
