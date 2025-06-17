import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart'; // Ensure correct import
import '../../models/client.dart';
import '../../models/user.dart';
import '../../providers/task_provider.dart'; // Ensure correct import
import '../../providers/client_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/project_provider.dart'; // <-- Add this import
import 'task_add_screen.dart'; // Ensure correct import
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:gantt_view/gantt_view.dart';
import '../../utils/gantt_helpers.dart';
import '../../models/project.dart'
    as model_project; // Use alias to avoid conflict

class TaskListScreen extends StatefulWidget {
  final int projectId;
  const TaskListScreen({super.key, required this.projectId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _selectedView = 'Board';
  final List<String> _views = ['Board', 'List', 'Timeline'];

  final TextEditingController _searchController = TextEditingController();
  late Future<model_project.Project?>
  _projectFuture; // Use alias for Project model

  @override
  void initState() {
    super.initState();
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    _projectFuture = projectProvider.getProjectById(widget.projectId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
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

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final clientProvider = Provider.of<ClientProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    List<Task> tasksForThisProject = taskProvider.tasks
        .where((task) => task.projectId == widget.projectId)
        .toList();

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      tasksForThisProject = tasksForThisProject.where((task) {
        return task.taskName.toLowerCase().contains(query) ||
            task.deadline.toLowerCase().contains(query) ||
            task.status.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query) ||
            _getClientName(
              task.clientId,
              clientProvider.clients,
            ).toLowerCase().contains(query) ||
            _getUserName(
              task.assignedToUserId,
              userProvider.users,
            ).toLowerCase().contains(query);
      }).toList();
    }

    final Map<String, List<Task>> groupedTasks = {
      // Use Task model
      'To Do': [],
      'In Progress': [],
      'On Review': [],
      'Ready': [],
    };
    for (var task in tasksForThisProject) {
      if (groupedTasks.containsKey(task.status)) {
        groupedTasks[task.status]!.add(task);
      }
    }

    Widget currentView;
    if (_selectedView == 'Timeline') {
      currentView = _buildTimelineView(
        tasksForThisProject,
        clientProvider.clients,
        userProvider.users,
      );
    } else {
      currentView = _buildBoardView(
        groupedTasks,
        clientProvider.clients,
        userProvider.users,
      );
    }

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<model_project.Project?>(
        future: _projectFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return const Center(child: Text('Error: Project not found.'));
          }

          final project = snapshot.data!;
          final String projectName = project.name;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Home > Projects > $projectName', // Updated breadcrumb
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      projectName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TaskAddScreen(projectId: widget.projectId),
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
                        fillColor: Theme.of(context).colorScheme.primary,
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
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
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
                          setState(() {});
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
              Expanded(child: currentView),
            ],
          );
        },
      ),
    );
  }

  // Helper for Board View
  Widget _buildBoardView(
    Map<String, List<Task>> groupedTasks,
    List<Client> clients,
    List<User> users,
  ) {
    return ListView(
      children: groupedTasks.keys.map((status) {
        final tasksInStatus = groupedTasks[status]!;
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
                          ),
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
                              '${tasksInStatus.length}',
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Add task to "$status"')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.grey),

                // Table Header Row - MODIFIED
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
                      // REMOVED: _projectTableHeaderCell('Category', flex: 2),
                      // REMOVED: _projectTableHeaderCell('Priority', flex: 1),
                      _projectTableHeaderCell('', flex: 0.5), // For ... icon
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.grey),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasksInStatus.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final task = tasksInStatus[index];
                    final client = clients.firstWhere(
                      (c) => c.id == task.clientId,
                      orElse: () => Client(
                        name: 'Unknown',
                        city: '',
                        state: '',
                        mobileNo: '',
                        id: -1,
                      ),
                    );
                    final assignedUser = users.firstWhere(
                      (u) => u.id == task.assignedToUserId,
                      orElse: () => User(
                        firstName: 'Unknown',
                        lastName: '',
                        email: '',
                        password: '',
                        mobileNo: '',
                        id: -1,
                      ),
                    );

                    return _buildProjectRow(task, client, assignedUser);
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Helper for Board View (from previous implementation) ---

  // --- NEW: Helper for Timeline View ---
  Widget _buildTimelineView(
    List<Task> tasks,
    List<Client> clients,
    List<User> users,
  ) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No projects to display in Timeline.'));
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: GanttChart<TaskGanttData>(
        rows: tasks.toGanttRows(clients, users),
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
                  ganttData.data.taskName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  ganttData.data.assignedToName,
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
  Widget _buildProjectRow(Task task, Client client, User assignedUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Checkbox(value: false, onChanged: (val) {}),
          ),
          const SizedBox(width: 8),
          _projectTableCell(task.taskName, flex: 3),
          _projectTableCell(task.description, flex: 4),
          _projectTableCell(task.deadline, flex: 2),
          _projectTableCell(task.trackedTime, flex: 2),
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
          _projectTableCell(client.name, flex: 2), // ADDED BACK
          Expanded(
            flex: 0.5.toInt(),
            child: IconButton(
              icon: const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('More options for ${task.taskName}')),
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

  // Helper function to get priority color
}
