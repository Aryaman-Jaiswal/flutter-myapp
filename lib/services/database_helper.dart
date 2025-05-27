import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; // For getApplicationDocumentsDirectory
import 'dart:io';

import '../models/user.dart';
import '../models/client.dart';
import '../utils/constants.dart'; // For UserRole

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database; 

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'my_app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle schema upgrades later
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        mobileNo TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Create Clients Table
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        city TEXT NOT NULL
      )
    ''');

    await db.insert('users', {
      'firstName': 'Super',
      'lastName': 'Admin',
      'email': 'superadmin@example.com',
      'password': 'password', 
      'mobileNo': '1234567890',
      'role': UserRole.superAdmin.toShortString(),
    });
    print("Super Admin created: superadmin@example.com / password");
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implement database schema upgrades here if app evolves
  }

  // --- USER CRUD OPERATIONS ---

  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    Database db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    Database db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- CLIENT CRUD OPERATIONS ---

  Future<int> insertClient(Client client) async {
    Database db = await database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<Client>> getClients() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clients');
    return List.generate(maps.length, (i) {
      return Client.fromMap(maps[i]);
    });
  }

  Future<int> updateClient(Client client) async {
    Database db = await database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    Database db = await database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}