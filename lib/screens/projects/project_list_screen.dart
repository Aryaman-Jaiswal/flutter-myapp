import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../models/client.dart';
import '../../models/user.dart';
import '../../providers/project_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/user_provider.dart';
import 'project_add_screen.dart';
import 'dart:math'; // For min/max
import 'package:intl/intl.dart'; // For date formatting
import 'package:gantt_view/gantt_view.dart';
import '../../utils/gantt_helpers.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  String _selectedView = 'Board'; // Default view
  final List<String> _views = ['Board', 'List', 'Timeline'];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  // Helper to get priority color (moved from project.dart to here if it needs context or is specific to UI)
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green[400]!;
      case 'medium':
        return Colors.orange[400]!;
      case 'high':
        return Colors.red[400]!;
      default:
        return Colors.grey[400]!;
    }
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
      case 'marketing':
        return Colors.pink[400]!;
      case 'content':
        return Colors.brown[400]!;
      case 'devops':
        return Colors.cyan[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final clientProvider = Provider.of<ClientProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    List<Project> projects = projectProvider.projects;

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      projects = projects.where((project) {
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
    for (var project in projects) {
      if (groupedProjects.containsKey(project.status)) {
        groupedProjects[project.status]!.add(project);
      }
    }

    // Determine which view to show
    Widget currentView;
    if (_selectedView == 'Timeline') {
      currentView = _buildTimelineView(
        projects,
        clientProvider.clients,
        userProvider.users,
      );
    } else {
      // Default to Board view or 'List' if implemented
      currentView = _buildBoardView(
        groupedProjects,
        clientProvider.clients,
        userProvider.users,
      );
    }

    return Container(
      color: Colors.grey[50], // Light grey background
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Home > Project',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
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

          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: [
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
          Expanded(
            child: currentView, // Display the selected view
          ),
        ],
      ),
    );
  }

  // --- Helper for Board View (from previous implementation) ---
  Widget _buildBoardView(
    Map<String, List<Project>> groupedProjects,
    List<Client> clients,
    List<User> users,
  ) {
    return ListView(
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
                                color: Theme.of(context).colorScheme.primary,
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
                            SnackBar(content: Text('Add task to "$status"')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey[300]),

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
                      _projectTableHeaderCell('Client', flex: 2),
                      _projectTableHeaderCell('Category', flex: 2),
                      _projectTableHeaderCell('Priority', flex: 1),
                      _projectTableHeaderCell('', flex: 0.5),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey[300]),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: projectsInStatus.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final project = projectsInStatus[index];
                    final client = clients.firstWhere(
                      (c) => c.id == project.clientId,
                      orElse: () => Client(
                        name: 'Unknown',
                        city: '',
                        state: '',
                        mobileNo: '',
                        id: -1,
                      ),
                    );
                    final assignedUser = users.firstWhere(
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

                    return _buildProjectRow(project, client, assignedUser);
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- NEW: Helper for Timeline View ---
  Widget _buildTimelineView(
    List<Project> projects,
    List<Client> clients,
    List<User> users,
  ) {
    if (projects.isEmpty) {
      return const Center(child: Text('No projects to display in Timeline.'));
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: GanttChart<ProjectGanttData>(
        rows: projects.toGanttRows(clients, users),
        showCurrentDate: true,
        style: GanttStyle(
          columnWidth: 50,
          barHeight: 24,
          timelineAxisType: TimelineAxisType.daily,

          tooltipType: TooltipType.hover,
          taskBarColor: const Color.fromARGB(255, 117, 13, 214),
          taskLabelColor: Colors.white,

          taskLabelBuilder: (ganttData) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ganttData.data.project.taskName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getUserName(ganttData.data.project.assignedToUserId, users),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          gridColor:
              Colors.white, // Grid lines white to remove lighter sections
          taskBarRadius: 8,
          axisDividerColor:
              Colors.white, // Axis dividers white to remove lighter sections
          tooltipColor: Colors.black.withOpacity(0.8),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 6.0,
          ),
          weekendColor:
              Colors.white, // Weekends white to remove lighter sections
          dateLineColor: Colors.red,
          snapToDay: true,

          monthLabelBuilder: (Month month) => Text(
            [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec',
            ][month.id - 1],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        dateLines: [
          GanttDateLine(date: DateTime.now(), width: 2, color: Colors.red),
        ],
        // The taskLabel parameter is causing the error. We need to implement a custom
        // `rowBuilder` or rely on `toString()` for the left column label based on GanttView's API.
        // As discussed, overriding toString() in ProjectGanttData is the common approach.
        // We removed the activityLabelBuilder also.
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

  // Helper widget to build a single project row (for Board view)
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
          _projectTableCell(client.name, flex: 2),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  project.category,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                backgroundColor: _getCategoryChipColor(project.category),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  'Low',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ), // Mock priority for now
                backgroundColor: _getPriorityColor(
                  'low',
                ), // Use helper function
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 0.5.toInt(),
            child: IconButton(
              icon: const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
              onPressed: () {
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
        maxLines: 2,
      ),
    );
  }
}
