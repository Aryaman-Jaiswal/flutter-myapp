import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/task.dart';
// REMOVED: import '../../models/client.dart'; // No longer needed for dropdown
import '../../models/user.dart';
import '../../providers/task_provider.dart';
// REMOVED: import '../../providers/client_provider.dart'; // No longer needed
import '../../providers/user_provider.dart';
import '../../providers/project_provider.dart'; // Import to get project details
import '../../models/project.dart' as model_project; // Use alias
import '../../providers/auth_provider.dart'; // Import to get current user

class TaskAddScreen extends StatefulWidget {
  final int projectId;
  const TaskAddScreen({super.key, required this.projectId});

  @override
  State<TaskAddScreen> createState() => _TaskAddScreenState();
}

class _TaskAddScreenState extends State<TaskAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController(
    text: 'To Do',
  );

  // REMOVED: Client? _selectedClient;
  User? _assignedToUser;
  DateTime? _selectedStartDate;
  DateTime? _selectedDeadline;

  // REMOVED: Category logic as it was not in the new design
  // final List<String> _categories = [...];
  // final TextEditingController _categoryController = TextEditingController();

  final List<String> _statuses = [
    'To Do',
    'In Progress',
    'On Review',
    'Ready',
    'Completed',
    'Cancelled',
  ];
  late Future<model_project.Project?>
  _projectFuture; // To fetch project details

  @override
  void initState() {
    super.initState();
    // Fetch the project details to get its clientId
    _projectFuture = Provider.of<ProjectProvider>(
      context,
      listen: false,
    ).getProjectById(widget.projectId);
    // Fetch users for the dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    DateTime? initialDate = DateTime.now();
    if (isStartDate) {
      initialDate = _selectedStartDate ?? DateTime.now();
    } else {
      initialDate =
          _selectedDeadline ??
          _selectedStartDate ??
          DateTime.now().add(const Duration(days: 7));
    }

    // --- THIS IS THE CODE THAT DISPLAYS THE CALENDAR ---
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    // --- END CALENDAR DISPLAY CODE ---

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
          if (_selectedDeadline != null &&
              _selectedDeadline!.isBefore(picked)) {
            _selectedDeadline = picked.add(const Duration(days: 1));
          }
        } else {
          _selectedDeadline = picked;
          if (_selectedStartDate != null &&
              _selectedStartDate!.isAfter(picked)) {
            _selectedStartDate = picked.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  void _addTask(int clientId) async {
    // Now accepts clientId
    if (_formKey.currentState!.validate()) {
      if (_assignedToUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an assigned user.')),
        );
        return;
      }
      if (_selectedStartDate == null || _selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both start and end dates.'),
          ),
        );
        return;
      }

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final newTask = Task(
        projectId: widget.projectId,
        taskName: _taskNameController.text,
        clientId: clientId, // Use the clientId from the parent project
        assignedToUserId: _assignedToUser!.id!,
        startDate: DateFormat('MMM dd, yyyy').format(_selectedStartDate!),
        deadline: DateFormat('MMM dd, yyyy').format(_selectedDeadline!),
        status: _statusController.text,
        description: _descriptionController.text,
        // Category is no longer part of the model
      );

      await taskProvider.addTask(newTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task Added Successfully!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(
      context,
    ); // To get current user

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Task',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<model_project.Project?>(
        future: _projectFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Project details could not be loaded.'),
            );
          }
          final project = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Task Name and Description Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Task Name*',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _taskNameController,
                              decoration: _inputDecoration('Enter task name'),
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter task name' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Description (Optional)'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: _inputDecoration('Enter description'),
                              maxLines:
                                  1, // Keep it single line to align with Task Name
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // REMOVED: Client Selector

                  // Assigned To Row
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.end, // Align items to the bottom
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assigned To*',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<User>(
                              decoration: _inputDecoration('Select User'),
                              value: _assignedToUser,
                              items: userProvider.users.map((User user) {
                                return DropdownMenuItem<User>(
                                  value: user,
                                  child: Text(
                                    '${user.firstName} ${user.lastName}',
                                  ),
                                );
                              }).toList(),
                              onChanged: (User? newValue) {
                                setState(() {
                                  _assignedToUser = newValue;
                                });
                              },
                              validator: (value) =>
                                  value == null ? 'Please select a user' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // "Assign to Me" Button
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 1.0,
                        ), // Align with form field bottom
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _assignedToUser = authProvider.currentUser;
                            });
                          },
                          child: const Text('Assign to Me'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dates Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Date*',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              readOnly: true,
                              onTap: () =>
                                  _selectDate(context, isStartDate: true),
                              controller: TextEditingController(
                                text: _selectedStartDate == null
                                    ? ''
                                    : DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(_selectedStartDate!),
                              ),
                              decoration: _inputDecoration('Select date')
                                  .copyWith(
                                    suffixIcon: const Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                    ),
                                  ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Select start date' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deadline*',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              readOnly: true,
                              onTap: () =>
                                  _selectDate(context, isStartDate: false),
                              controller: TextEditingController(
                                text: _selectedDeadline == null
                                    ? ''
                                    : DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(_selectedDeadline!),
                              ),
                              decoration: _inputDecoration('Select date')
                                  .copyWith(
                                    suffixIcon: const Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                    ),
                                  ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Select deadline' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () =>
                          _addTask(project.clientId), // Pass the clientId
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C527D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Add Task',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
    );
  }
}
