// lib/providers/project_provider.dart

import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/database_helper.dart';

class ProjectProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  Future<void> fetchProjects() async {
    _projects = await _dbHelper.getProjects();
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    await _dbHelper.insertProject(project);
    await fetchProjects();
  }

  

  // ... (updateProject, getProjectById, deleteProject methods)

  Future<void> updateProject(Project project) async {
    await _dbHelper.updateProject(project);
    await fetchProjects();
  }

  Future<Project?> getProjectById(int id) async {
    return await _dbHelper.getProjectById(id);
  }

  Future<void> deleteProject(int id) async {
    await _dbHelper.deleteProject(id);
    await fetchProjects();
  }
}
