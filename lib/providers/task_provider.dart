import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> fetchTasks() async {
    _tasks = await _dbHelper.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _dbHelper.insertTask(task);
    await fetchTasks();
  }

  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task);
    await fetchTasks();
  }

  Future<Task?> getTaskById(int id) async {
    return await _dbHelper.getTaskById(id);
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    await fetchTasks();
  }

  Future<void> updateTaskTime(Task task) async {
    await _dbHelper.updateTask(
      task,
    ); // Assuming you have a generic updateTask method
    // Find the task in the local list and update it to avoid a full re-fetch
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }
}
