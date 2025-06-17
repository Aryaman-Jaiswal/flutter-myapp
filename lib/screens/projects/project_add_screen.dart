import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../models/project.dart';
import '../../providers/client_provider.dart';
import '../../providers/project_provider.dart';

class ProjectAddScreen extends StatefulWidget {
  const ProjectAddScreen({super.key});

  @override
  State<ProjectAddScreen> createState() => _ProjectAddScreenState();
}

class _ProjectAddScreenState extends State<ProjectAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Client? _selectedClient;

  @override
  void initState() {
    super.initState();
    // Fetch clients to populate the dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).fetchClients();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addProject() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a client.')),
        );
        return;
      }

      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      final newProject = Project(
        name: _nameController.text,
        description: _descriptionController.text,
        clientId: _selectedClient!.id!,
      );

      await projectProvider.addProject(newProject);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project Added Successfully!')),
        );
        context.go('/projects'); // Navigate back to the project list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Project'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/projects'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter project name' : null,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<Client>(
                    decoration: const InputDecoration(
                      labelText: 'Select Client*',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedClient,
                    hint: const Text('Select a Client'),
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
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addProject,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Add Project'),
                    ),
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
