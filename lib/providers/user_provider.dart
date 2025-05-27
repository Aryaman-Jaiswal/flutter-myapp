import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class UserProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> _users = [];

  List<User> get users => _users;

  Future<void> fetchUsers() async {
    _users = await _dbHelper.getUsers();
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    await _dbHelper.insertUser(user);
    await fetchUsers(); 
  }

  Future<void> updateUser(User user) async {
    await _dbHelper.updateUser(user);
    await fetchUsers(); 
  }

  Future<User?> getUserById(int id) async {
    return await _dbHelper.getUserById(id);
  }

  Future<void> deleteUser(int id) async {
    await _dbHelper.deleteUser(id);
    await fetchUsers();
  }
}