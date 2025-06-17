// lib/screens/projects/project_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../models/project.dart';
import '../../providers/client_provider.dart';
import 'package:collection/collection.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
      Provider.of<ClientProvider>(context, listen: false).fetchClients();
    });
  }

  String _getClientName(int clientId, BuildContext context) {
    final clients = Provider.of<ClientProvider>(context, listen: false).clients;
    // firstWhereOrNull is a safe way to find an element or get null.
    final client = clients.firstWhereOrNull((c) => c.id == clientId);
    return client?.name ?? 'Unknown Client'; // Use the null-aware operator
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Projects',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to ProjectAddScreen
                  context.go('/projects/add');
                },
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text(
                  'Add Project',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Project List
          Expanded(
            child: projectProvider.projects.isEmpty
                ? const Center(
                    child: Text(
                      'No projects found. Add a new one to get started.',
                    ),
                  )
                : ListView.builder(
                    itemCount: projectProvider.projects.length,
                    itemBuilder: (context, index) {
                      final project = projectProvider.projects[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            project.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Client: ${_getClientName(project.clientId, context)}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to the task list for this project
                            context.go('/projects/${project.id}');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
