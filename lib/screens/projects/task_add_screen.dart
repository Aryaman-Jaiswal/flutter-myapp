import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../models/task.dart'; // Renamed from project.dart
import '../../models/client.dart';
import '../../models/user.dart';
import '../../providers/task_provider.dart'; // Renamed from project_provider.dart
import '../../providers/client_provider.dart';
import '../../providers/user_provider.dart';

class TaskAddScreen extends StatefulWidget {
  // Renamed class
  final int projectId;
  const TaskAddScreen({super.key, required this.projectId}); // Renamed class

  @override
  State<TaskAddScreen> createState() => _TaskAddScreenState(); // Renamed state class
}

class _TaskAddScreenState extends State<TaskAddScreen> {
  // Renamed state class
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _trackedTimeController = TextEditingController(
    text: '0h 0m',
  );
  final TextEditingController _statusController = TextEditingController(
    text: 'To Do',
  );

  Client? _selectedClient;
  User? _assignedToUser;
  DateTime? _selectedStartDate;
  DateTime? _selectedDeadline;

  final List<String> _categories = [
    'Design',
    'Frontend',
    'Backend',
    'Marketing',
    'Content',
    'DevOps',
  ];
  final List<String> _statuses = [
    'To Do',
    'In Progress',
    'On Review',
    'Ready',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).fetchClients();
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _trackedTimeController.dispose();
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
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 7));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
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

  void _addTask() async {
    // Renamed method
    if (_formKey.currentState!.validate()) {
      if (_selectedClient == null ||
          _assignedToUser == null ||
          _selectedStartDate == null ||
          _selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields.')),
        );
        return;
      }

      final taskProvider = Provider.of<TaskProvider>(
        context,
        listen: false,
      ); // Use TaskProvider
      final newTask = Task(
        // Use Task model and assign projectId
        projectId: widget.projectId,
        taskName: _taskNameController.text,

        clientId: _selectedClient!.id!,
        assignedToUserId: _assignedToUser!.id!,
        startDate: DateFormat('MMM dd, yyyy').format(_selectedStartDate!),
        deadline: DateFormat('MMM dd, yyyy').format(_selectedDeadline!),
        status: _statusController.text,
        description: _descriptionController.text,
        trackedTime: _trackedTimeController.text,
      );

      await taskProvider.addTask(newTask); // Use addTask method

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task Added Successfully!'),
        ), // Updated message
      );

      Navigator.pop(context);
    }
  }

  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'), // Changed title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Task', // Changed header
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Task Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _taskNameController,
                    decoration: _getInputDecoration('Enter task name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter task name' : null,
                  ),
                  const SizedBox(height: 24),

                  const Text('Client'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Client>(
                    decoration: _getInputDecoration('Select Client'),
                    value: _selectedClient,
                    items: clientProvider.clients.map((Client client) {
                      return DropdownMenuItem<Client>(
                        value: client,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: (Client? newValue) {
                      setState(() {
                        _selectedClient = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a client' : null,
                  ),
                  const SizedBox(height: 24),

                  const Text('Assigned To'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<User>(
                    decoration: _getInputDecoration('Select User'),
                    value: _assignedToUser,
                    items: userProvider.users.map((User user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child: Text('${user.firstName} ${user.lastName}'),
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
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () =>
                                  _selectDate(context, isStartDate: true),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: TextEditingController(
                                    text: _selectedStartDate == null
                                        ? ''
                                        : DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(_selectedStartDate!),
                                  ),
                                  decoration: _getInputDecoration('Select date')
                                      .copyWith(
                                        suffixIcon: const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                        ),
                                      ),
                                  validator: (value) => value!.isEmpty
                                      ? 'Select start date'
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Deadline'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () =>
                                  _selectDate(context, isStartDate: false),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: TextEditingController(
                                    text: _selectedDeadline == null
                                        ? ''
                                        : DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(_selectedDeadline!),
                                  ),
                                  decoration: _getInputDecoration('Select date')
                                      .copyWith(
                                        suffixIcon: const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                        ),
                                      ),
                                  validator: (value) =>
                                      value!.isEmpty ? 'Select deadline' : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text('Description (Optional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _getInputDecoration('Enter description'),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 32.0),
                    child: ElevatedButton(
                      onPressed: _addTask, // Changed to call _addTask
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add Task', // Changed button text
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
          ],
        ),
      ),
    );
  }
}
