import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import 'dart:async'; // Import for Timer

class TaskProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];

  // --- NEW: Timer logic moved to the provider ---
  final Map<int, Timer> _runningTimers = {};
  final Map<int, DateTime> _trackingStartTimes = {};

  List<Task> get tasks => _tasks;

  // Check if a specific task is currently being tracked
  bool isTaskTracking(int taskId) {
    return _runningTimers.containsKey(taskId);
  }

  DateTime? getTaskStartTime(int taskId) {
    return _trackingStartTimes[taskId];
  }

  // Get the total number of active timers
  int get activeTimersCount => _runningTimers.length;
  // --- END NEW ---

  Future<void> fetchTasks() async {
    _tasks = await _dbHelper.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _dbHelper.insertTask(task);
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
    notifyListeners();
    await fetchTasks();
  }

  Future<void> updateTask(Task task) async {
    // You need a generic update method
    await _dbHelper.updateTask(task);
    await fetchTasks();
  }

  // NEW method to specifically handle starting and stopping the timer
  void toggleTimer(Task task) {
    if (isTaskTracking(task.id!)) {
      // --- STOPPING ---
      final timer = _runningTimers[task.id!];
      timer?.cancel(); // Cancel the timer
      _runningTimers.remove(task.id!);

      final startTime = _trackingStartTimes.remove(
        task.id!,
      ); // Remove and get start time
      if (startTime != null) {
        task.totalTrackedSeconds += DateTime.now()
            .difference(startTime)
            .inSeconds;
      }

      // Persist the final time to the database
      updateTask(task); // Use a generic update here
    } else {
      _trackingStartTimes[task.id!] =
          DateTime.now(); // Store start time in the provider
      _runningTimers[task.id!] = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) {
        // Just notify listeners. The UI will calculate the elapsed time.
        notifyListeners();
      });
    }
    notifyListeners();
  }

  // Clean up timers when the provider is disposed
  @override
  void dispose() {
    _runningTimers.forEach((key, timer) => timer.cancel());
    super.dispose();
  }
}
