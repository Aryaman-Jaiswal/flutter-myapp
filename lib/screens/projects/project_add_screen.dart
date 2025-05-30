import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../models/project.dart';
import '../../models/client.dart';
import '../../models/user.dart';
import '../../providers/project_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/user_provider.dart';

class ProjectAddScreen extends StatefulWidget {
  const ProjectAddScreen({super.key});

  @override
  State<ProjectAddScreen> createState() => _ProjectAddScreenState();
}

class _ProjectAddScreenState extends State<ProjectAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _trackedTimeController = TextEditingController(
    text: '0h 0m',
  ); // Default
  final TextEditingController _statusController = TextEditingController(
    text: 'To Do',
  ); // Default status

  Client? _selectedClient;
  User? _assignedToUser;
  DateTime? _selectedStartDate; // NEW: Start Date
  DateTime? _selectedDeadline;

  final List<String> _categories = [
    'Design',
    'Frontend',
    'Backend',
    'Marketing',
    'Content',
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
    // Fetch clients and users when screen initializes to populate dropdowns
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
          _selectedDeadline ??
          DateTime.now().add(
            const Duration(days: 7),
          ); // Default 7 days from now for deadline
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365 * 2),
      ), // 2 years back
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 5),
      ), // 5 years forward
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
          // Ensure deadline is not before start date
          if (_selectedDeadline != null &&
              _selectedDeadline!.isBefore(picked)) {
            _selectedDeadline = picked.add(
              const Duration(days: 1),
            ); // Set deadline to next day
          }
        } else {
          _selectedDeadline = picked;
          // Ensure start date is not after deadline
          if (_selectedStartDate != null &&
              _selectedStartDate!.isAfter(picked)) {
            _selectedStartDate = picked.subtract(
              const Duration(days: 1),
            ); // Set start date to previous day
          }
        }
      });
    }
  }

  void _addProject() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a client.')),
        );
        return;
      }
      if (_assignedToUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an assigned user.')),
        );
        return;
      }
      if (_selectedStartDate == null) {
        // Validate start date
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a start date.')),
        );
        return;
      }
      if (_selectedDeadline == null) {
        // Validate deadline
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a deadline.')),
        );
        return;
      }

      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      final newProject = Project(
        taskName: _taskNameController.text,
        category: _categoryController
            .text, // Assuming category is selected from dropdown
        clientId: _selectedClient!.id!,
        assignedToUserId: _assignedToUser!.id!,
        startDate: DateFormat(
          'MMM dd, yyyy',
        ).format(_selectedStartDate!), // Pass start date
        deadline: DateFormat('MMM dd, yyyy').format(_selectedDeadline!),
        status:
            _statusController.text, // Assuming status is selected from dropdown
        description: _descriptionController.text,
        trackedTime: _trackedTimeController.text,
      );

      await projectProvider.addProject(newProject);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project Added Successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Project')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _taskNameController,
                    decoration: const InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter task name' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: _categoryController.text.isNotEmpty
                        ? _categoryController.text
                        : null,
                    hint: const Text('Select Category'),
                    items: _categories.map((String cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _categoryController.text = newValue!;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Client Selector Dropdown
                  DropdownButtonFormField<Client>(
                    decoration: const InputDecoration(
                      labelText: 'Client',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedClient,
                    hint: const Text('Select Client'),
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
                  const SizedBox(height: 16.0),

                  // Assigned To User Selector Dropdown
                  DropdownButtonFormField<User>(
                    decoration: const InputDecoration(
                      labelText: 'Assigned To',
                      border: OutlineInputBorder(),
                    ),
                    value: _assignedToUser,
                    hint: const Text('Select User'),
                    items: userProvider.users.map((User user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child: Text(user.firstName),
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
                  const SizedBox(height: 16.0),

                  // NEW: Start Date Date Picker
                  GestureDetector(
                    onTap: () => _selectDate(context, isStartDate: true),
                    child: AbsorbPointer(
                      // Prevents TextFormField from being editable directly
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _selectedStartDate == null
                              ? ''
                              : DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_selectedStartDate!),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please select a start date'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Deadline Date Picker (uses _selectDate now)
                  GestureDetector(
                    onTap: () => _selectDate(context, isStartDate: false),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _selectedDeadline == null
                              ? ''
                              : DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_selectedDeadline!),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Deadline',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please select a deadline' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: _statusController.text.isNotEmpty
                        ? _statusController.text
                        : null,
                    hint: const Text('Select Status'),
                    items: _statuses.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _statusController.text = newValue!;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a status' : null,
                  ),
                  const SizedBox(height: 16.0),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16.0),

                  TextFormField(
                    controller: _trackedTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Tracked Time (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 32.0),

                  ElevatedButton(
                    onPressed: _addProject,
                    child: const Text('Add Project'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
