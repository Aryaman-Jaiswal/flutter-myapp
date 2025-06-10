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

  // Create a reusable InputDecoration
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
      // Add back the AppBar
      appBar: AppBar(
        title: const Text('Add New Project'),
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
            // Header
            const Text(
              'Add New Project',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Name
                  const Text('Task Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _taskNameController,
                    decoration: _getInputDecoration('Enter task name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter task name' : null,
                  ),
                  const SizedBox(height: 24),

                  // Category
                  const Text('Category'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: _getInputDecoration('Select Category'),
                    value: _categoryController.text.isNotEmpty
                        ? _categoryController.text
                        : null,
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
                  const SizedBox(height: 24),

                  // Client
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

                  // Assigned To
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

                  // Dates Row
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

                  // Description
                  const Text('Description (Optional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _getInputDecoration('Enter description'),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 32.0),
                    child: ElevatedButton(
                      onPressed: _addProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add Project',
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
