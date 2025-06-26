import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/user.dart';
import '../models/client.dart';
import '../utils/constants.dart';
import '../models/task.dart';
import '../models/project.dart';

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
    String path;
    if (kIsWeb) {
      // For web, just provide a database name.
      // The sqflite_common_ffi_web package will handle the rest.
      path = 'my_app_database.db';
    } else {
      // For mobile/desktop, use path_provider to find a suitable directory.
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'my_app_database.db');
    }
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
        city TEXT NOT NULL,
        state TEXT NOT NULL,
        mobileNo TEXT NOT NULL
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

    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        clientId INTEGER NOT NULL,
        FOREIGN KEY (clientId) REFERENCES clients(id) ON DELETE CASCADE
      )
    ''');

    // --- RENAMED: from 'projects' to 'tasks' ---
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskName TEXT NOT NULL,
        projectId INTEGER NOT NULL, -- Added projectId foreign key
      
        clientId INTEGER NOT NULL,
        assignedToUserId INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        deadline TEXT NOT NULL,
        status TEXT NOT NULL,
        totalTrackedSeconds INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (clientId) REFERENCES clients(id) ON DELETE CASCADE,
        FOREIGN KEY (assignedToUserId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
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
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
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
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  //--- PROJECT CRUD OPERATIONS ---
  // --- USER CRUD OPERATIONS (unchanged) ---

  // --- NEW: PROJECT CRUD OPERATIONS (for high-level projects) ---
  Future<int> insertProject(Project project) async {
    Database db = await database;
    return await db.insert('projects', project.toMap());
  }

  Future<List<Project>> getProjects() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('projects');
    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }

  Future<Project?> getProjectById(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Project.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProject(Project project) async {
    Database db = await database;
    return await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> deleteProject(int id) async {
    Database db = await database;
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // --- RENAMED: TASK CRUD OPERATIONS ---
  Future<int> insertTask(Task task) async {
    Database db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<Task?> getTaskById(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTask(Task task) async {
    Database db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
