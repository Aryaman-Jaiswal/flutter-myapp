import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../models/client.dart'; // To get client name from clientId
import '../../models/user.dart'; // To get user name from assignedToUserId
import '../../providers/project_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/user_provider.dart';
import 'project_add_screen.dart'; // Import for "Add task" button

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  // Mock filter/view options
  String _selectedView = 'List'; // Board, List, Timeline
  final List<String> _views = ['Board', 'List', 'Timeline'];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch all projects, clients, and users when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
      Provider.of<ClientProvider>(context, listen: false).fetchClients();
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper to get client name from ID
  String _getClientName(int clientId, List<Client> clients) {
    return clients
        .firstWhere(
          (c) => c.id == clientId,
          orElse: () => Client(
            name: 'Unknown Client',
            city: '',
            state: '',
            mobileNo: '',
            id: -1,
          ),
        )
        .name;
  }

  // Helper to get user name from ID
  String _getUserName(int userId, List<User> users) {
    return users
        .firstWhere(
          (u) => u.id == userId,
          orElse: () => User(
            firstName: 'Unknown User',
            lastName: '',
            email: '',
            password: '',
            mobileNo: '',
            id: -1,
          ),
        )
        .firstName;
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final clientProvider = Provider.of<ClientProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Filter projects based on search query
    List<Project> filteredProjects = projectProvider.projects;
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredProjects = filteredProjects.where((project) {
        return project.taskName.toLowerCase().contains(query) ||
            project.category.toLowerCase().contains(query) ||
            project.deadline.toLowerCase().contains(query) ||
            project.status.toLowerCase().contains(query) ||
            project.description.toLowerCase().contains(query) ||
            _getClientName(
              project.clientId,
              clientProvider.clients,
            ).toLowerCase().contains(query) ||
            _getUserName(
              project.assignedToUserId,
              userProvider.users,
            ).toLowerCase().contains(query);
      }).toList();
    }

    // Group projects by status
    final Map<String, List<Project>> groupedProjects = {
      'To Do': [],
      'In Progress': [],
      'On Review': [],
      'Ready': [],
    };
    for (var project in filteredProjects) {
      if (groupedProjects.containsKey(project.status)) {
        groupedProjects[project.status]!.add(project);
      }
    }

    return Container(
      color: Colors.grey[50], // Light grey background
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Breadcrumb (Home > Project)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Home > Project',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          // Section 2: Project Title and Add Task Button
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Project',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProjectAddScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add task',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),

          // Section 3: View Toggles (Board, List, Timeline), Search, Settings, More
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: [
                // View Toggles
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ToggleButtons(
                    isSelected: _views
                        .map((view) => view == _selectedView)
                        .toList(),
                    onPressed: (int index) {
                      setState(() {
                        _selectedView = _views[index];
                        // Implement view switching logic here
                      });
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    selectedColor: Colors.white,
                    color: Colors.grey[700],
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.primary, // Selected background color
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderWidth: 0,
                    children: _views
                        .map(
                          (view) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  view == 'Board'
                                      ? Icons.dashboard
                                      : view == 'List'
                                      ? Icons.list_alt
                                      : Icons.timeline,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(view),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(width: 20),
                // Search Bar
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
                    onChanged: (query) {
                      setState(() {
                        // Trigger rebuild to apply search filter
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Settings Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.grey),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings not implemented.'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // More Options Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('More options not implemented.'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Section 4: Project Status Sections (To Do, In Progress, etc.)
          Expanded(
            child: ListView(
              children: groupedProjects.keys.map((status) {
                final projectsInStatus = groupedProjects[status]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header (To Do, In Progress)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.grey[700],
                                  ), // Collapse icon
                                  const SizedBox(width: 8),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${projectsInStatus.length}',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.grey),
                                onPressed: () {
                                  // Add task to this specific status
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Add task to "$status"'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey[300],
                        ), // Separator
                        // Table Header Row for Projects
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            children: [
                              _projectTableHeaderCell('Task name', flex: 3),
                              _projectTableHeaderCell('Description', flex: 4),
                              _projectTableHeaderCell('Deadline', flex: 2),
                              _projectTableHeaderCell('Tracked time', flex: 2),
                              _projectTableHeaderCell('Assigned to', flex: 2),
                              _projectTableHeaderCell(
                                'Client',
                                flex: 2,
                              ), // Changed from 'Type' to 'Client'
                              _projectTableHeaderCell(
                                'Category',
                                flex: 2,
                              ), // Changed from 'Priority' to 'Category'
                              _projectTableHeaderCell(
                                'Priority',
                                flex: 1,
                              ), // Priority column
                              _projectTableHeaderCell(
                                '',
                                flex: 0.5,
                              ), // For ... icon
                            ],
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey[300]),

                        // Project List Rows
                        ListView.separated(
                          shrinkWrap: true, // Important for nested ListView
                          physics:
                              const NeverScrollableScrollPhysics(), // Important for nested ListView
                          itemCount: projectsInStatus.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final project = projectsInStatus[index];
                            final client = clientProvider.clients.firstWhere(
                              (c) => c.id == project.clientId,
                              orElse: () => Client(
                                name: 'Unknown',
                                city: '',
                                state: '',
                                mobileNo: '',
                                id: -1,
                              ),
                            );
                            final assignedUser = userProvider.users.firstWhere(
                              (u) => u.id == project.assignedToUserId,
                              orElse: () => User(
                                firstName: 'Unknown',
                                lastName: '',
                                email: '',
                                password: '',
                                mobileNo: '',
                                id: -1,
                              ),
                            );

                            return _buildProjectRow(
                              project,
                              client,
                              assignedUser,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for project table header cells
  Widget _projectTableHeaderCell(String text, {double flex = 1}) {
    return Expanded(
      flex: flex.toInt(),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper widget to build a single project row
  Widget _buildProjectRow(Project project, Client client, User assignedUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Checkbox(value: false, onChanged: (val) {}),
          ),
          const SizedBox(width: 8),
          _projectTableCell(project.taskName, flex: 3),
          _projectTableCell(project.description, flex: 4),
          _projectTableCell(project.deadline, flex: 2),
          _projectTableCell(project.trackedTime, flex: 2),
          Expanded(
            // Assigned To column with avatar
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    assignedUser.firstName[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  assignedUser.firstName,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
          _projectTableCell(client.name, flex: 2), // Client name here
          Expanded(
            // Category chip
            flex: 2,
            child: Align(
              // Align chip to center or start
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  project.category,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                backgroundColor: _getCategoryChipColor(
                  project.category,
                ), // Dynamic color for category
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          ),
          Expanded(
            // Priority chip
            flex: 1,
            child: Align(
              // Align chip to center or start
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  'Low',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ), // Mock priority for now
                backgroundColor: getPriorityColor('low'), // Use helper function
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          ),
          Expanded(
            // More options icon
            flex: 0.5.toInt(),
            child: IconButton(
              icon: const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
              onPressed: () {
                // Implement more options for the project
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('More options for ${project.taskName}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for regular project table cells
  Widget _projectTableCell(String text, {double flex = 1}) {
    return Expanded(
      flex: flex.toInt(),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        overflow: TextOverflow.ellipsis,
        maxLines: 2, // Allow description to wrap
      ),
    );
  }

  // Helper to get dynamic colors for category chips
  Color _getCategoryChipColor(String category) {
    switch (category.toLowerCase()) {
      case 'design':
        return Colors.orange[400]!;
      case 'frontend':
        return Colors.deepPurple[400]!;
      case 'backend':
        return Colors.blue[400]!;
      default:
        return Colors.grey[400]!;
    }
  }
}
