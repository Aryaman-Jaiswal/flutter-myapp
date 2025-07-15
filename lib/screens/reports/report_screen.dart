import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html; // For web download
import 'dart:convert'; // For utf8 encoding

import '../../models/client.dart';
import '../../models/project.dart' as model_project;
import '../../models/task.dart';
import '../../models/user.dart';
import '../../providers/client_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedFilterType;
  final List<String> _filterTypes = [
    'Client',
    'Project',
    'Developer',
    'Date Range',
  ];

  // State for selected filter values
  Client? _selectedClient;
  model_project.Project? _selectedProject;
  User? _selectedUser;
  DateTimeRange? _selectedDateRange;

  // Helper to format duration from seconds
  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // --- Main CSV Generation and Download Logic ---
  Future<void> _generateAndDownloadCsv() async {
    if (_selectedFilterType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a filter type.')),
      );
      return;
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    List<Task> allTasks = taskProvider.tasks;
    List<Task> filteredTasks = [];

    // Apply the selected filter
    switch (_selectedFilterType) {
      case 'Client':
        if (_selectedClient == null) return;
        filteredTasks = allTasks
            .where((task) => task.clientId == _selectedClient!.id)
            .toList();
        break;
      case 'Project':
        if (_selectedProject == null) return;
        filteredTasks = allTasks
            .where((task) => task.projectId == _selectedProject!.id)
            .toList();
        break;
      case 'Developer':
        if (_selectedUser == null) return;
        filteredTasks = allTasks
            .where((task) => task.assignedToUserId == _selectedUser!.id)
            .toList();
        break;
      case 'Date Range':
        if (_selectedDateRange == null) return;
        filteredTasks = allTasks.where((task) {
          try {
            final taskStartDate = DateFormat(
              'MMM dd, yyyy',
            ).parse(task.startDate);
            return (taskStartDate.isAfter(_selectedDateRange!.start) ||
                    taskStartDate.isAtSameMomentAs(
                      _selectedDateRange!.start,
                    )) &&
                (taskStartDate.isBefore(_selectedDateRange!.end) ||
                    taskStartDate.isAtSameMomentAs(_selectedDateRange!.end));
          } catch (e) {
            return false;
          }
        }).toList();
        break;
    }

    if (filteredTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data found for the selected filter.')),
      );
      return;
    }

    // --- Create CSV Content ---
    List<List<dynamic>> rows = [];
    // Add header row
    rows.add([
      'Project Name',
      'Task Name',
      'Client',
      'Developer',
      'Start Date',
      'Deadline',
      'Status',
      'Tracked Time (HH:MM:SS)',
    ]);

    // Add data rows
    for (var task in filteredTasks) {
      final projectName = projectProvider.projects
          .firstWhere(
            (p) => p.id == task.projectId,
            orElse: () =>
                model_project.Project(id: -1, name: 'N/A', clientId: -1),
          )
          .name;
      final clientName = clientProvider.clients
          .firstWhere(
            (c) => c.id == task.clientId,
            orElse: () =>
                Client(id: -1, name: 'N/A', city: '', state: '', mobileNo: ''),
          )
          .name;
      final userName = userProvider.users
          .firstWhere(
            (u) => u.id == task.assignedToUserId,
            orElse: () => User(
              id: -1,
              firstName: 'N/A',
              lastName: '',
              email: '',
              password: '',
              mobileNo: '',
            ),
          )
          .firstName;

      rows.add([
        projectName,
        task.taskName,
        clientName,
        userName,
        task.startDate,
        task.deadline,
        task.status,
        _formatDuration(task.totalTrackedSeconds),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // --- Trigger Web Download ---
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
        "download",
        "project_report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv",
      )
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Generate and download project reports based on a selected filter.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Type Selector
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Filter By',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedFilterType,
                    items: _filterTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilterType = newValue;
                        // Reset other filter values when type changes
                        _selectedClient = null;
                        _selectedProject = null;
                        _selectedUser = null;
                        _selectedDateRange = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Conditional Filter Value Selector
                  if (_selectedFilterType == 'Client')
                    Consumer<ClientProvider>(
                      builder: (context, provider, child) =>
                          DropdownButtonFormField<Client>(
                            decoration: const InputDecoration(
                              labelText: 'Select a Client',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedClient,
                            items: provider.clients
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedClient = val),
                          ),
                    ),

                  if (_selectedFilterType == 'Project')
                    Consumer<ProjectProvider>(
                      builder: (context, provider, child) =>
                          DropdownButtonFormField<model_project.Project>(
                            decoration: const InputDecoration(
                              labelText: 'Select a Project',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedProject,
                            items: provider.projects
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedProject = val),
                          ),
                    ),

                  if (_selectedFilterType == 'Developer')
                    Consumer<UserProvider>(
                      builder: (context, provider, child) =>
                          DropdownButtonFormField<User>(
                            decoration: const InputDecoration(
                              labelText: 'Select a Developer',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedUser,
                            items: provider.users
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u.firstName),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedUser = val),
                          ),
                    ),

                  if (_selectedFilterType == 'Date Range')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDateRange == null
                            ? 'Select Date Range'
                            : '${DateFormat.yMd().format(_selectedDateRange!.start)} - ${DateFormat.yMd().format(_selectedDateRange!.end)}',
                      ),
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDateRange = picked;
                          });
                        }
                      },
                    ),

                  const SizedBox(height: 32),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        'Generate & Download CSV',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _generateAndDownloadCsv,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
