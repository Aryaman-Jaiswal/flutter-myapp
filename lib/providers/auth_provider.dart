import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import '../utils/constants.dart'; 

class AuthProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  bool get isSuperAdmin => _currentUser?.role == UserRole.superAdmin;
  bool get isAdmin => _currentUser?.role == UserRole.admin || _currentUser?.role == UserRole.superAdmin;

  Future<bool> login(String email, String password) async {
    User? user = await _dbHelper.getUserByEmail(email);
    if (user != null && user.password == password) { 
      _currentUser = user;
      notifyListeners();
      return true;
    }
    _currentUser = null;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updateCurrentUser(User updatedUser) {
    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }
}