import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/database_helper.dart';

class ClientProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Client> _clients = [];

  List<Client> get clients => _clients;

  Future<void> fetchClients() async {
    _clients = await _dbHelper.getClients();
    notifyListeners();
  }

  Future<void> addClient(Client client) async {
    await _dbHelper.insertClient(client);
    await fetchClients();
  }

  Future<void> updateClient(Client client) async {
    await _dbHelper.updateClient(client);
    await fetchClients();
  }

  Future<void> deleteClient(int id) async {
    await _dbHelper.deleteClient(id);
    await fetchClients();
  }
}