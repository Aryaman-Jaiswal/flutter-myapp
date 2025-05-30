import 'package:gantt_view/gantt_view.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../models/user.dart'; // Import User to get assigned user name
import '../models/client.dart'; // Import Client for client name

// Helper class to hold project data for Gantt chart
class ProjectGanttData {
  final Project project;
  final DateTime startDate;
  final DateTime endDate;
  final String assignedUserName; // NEW: To display Assigned User on the left
  final String tooltip;

  ProjectGanttData({
    required this.project,
    required this.startDate,
    required this.endDate,
    required this.assignedUserName, // Require assigned user name
    required this.tooltip,
  });

  // NEW: Override toString() to customize the left-hand label in GanttChart
  // This content will appear in the fixed left-hand column for each task.
  @override
  String toString() {
    // You can customize this format
    // Example: "Task Name\nAssigned User" or "Task Name\nID: ${project.id}"
    return '${project.taskName}\n${assignedUserName}'; // As per your image: Task name + user below it
  }
}

// Extension to convert a List<Project> into a List<GridRow>
extension ProjectListToGanttRows on List<Project> {
  // Pass clients and users to get the names for the labels
  List<GridRow> toGanttRows(List<Client> allClients, List<User> allUsers) {
    List<GridRow> rows = [];
    Map<String, List<TaskGridRow<ProjectGanttData>>> groupedTasks = {};

    // Helper to get names
    String _getClientName(int clientId) {
      return allClients
          .firstWhere(
            (c) => c.id == clientId,
            orElse: () => Client(
              name: 'Unknown',
              city: '',
              state: '',
              mobileNo: '',
              id: -1,
            ),
          )
          .name;
    }

    String _getUserName(int userId) {
      return allUsers
          .firstWhere(
            (u) => u.id == userId,
            orElse: () => User(
              firstName: 'Unknown',
              lastName: '',
              email: '',
              password: '',
              mobileNo: '',
              id: -1,
            ),
          )
          .firstName;
    }

    // Sort projects by start date for better timeline display
    sort((a, b) {
      DateTime aStart = DateFormat('MMM dd, yyyy').parse(a.startDate);
      DateTime bStart = DateFormat('MMM dd, yyyy').parse(b.startDate);
      return aStart.compareTo(bStart);
    });

    for (var project in this) {
      final String groupLabel =
          project.status; // Group by project status (To Do, In Progress, etc.)
      DateTime startDate = DateFormat('MMM dd, yyyy').parse(project.startDate);
      DateTime endDate = DateFormat('MMM dd, yyyy').parse(project.deadline);

      final ProjectGanttData ganttData = ProjectGanttData(
        project: project,
        startDate: startDate,
        endDate: endDate,
        assignedUserName: _getUserName(
          project.assignedToUserId,
        ), // Pass assigned user name
        tooltip:
            'Task: ${project.taskName}\nClient: ${_getClientName(project.clientId)}\nAssigned: ${_getUserName(project.assignedToUserId)}\nStatus: ${project.status}\nStarts: ${project.startDate}\nEnds: ${project.deadline}',
      );

      (groupedTasks[groupLabel] ??= []).add(
        TaskGridRow<ProjectGanttData>(
          data: ganttData,
          startDate: ganttData.startDate,
          endDate: ganttData.endDate,
          tooltip: ganttData.tooltip,
        ),
      );
    }

    // Order the groups as desired (e.g., To Do, In Progress, On Review, Ready)
    final List<String> desiredOrder = [
      'To Do',
      'In Progress',
      'On Review',
      'Ready',
    ];
    for (var groupLabel in desiredOrder) {
      if (groupedTasks.containsKey(groupLabel)) {
        rows.add(ActivityGridRow(groupLabel)); // Add activity header
        rows.addAll(groupedTasks[groupLabel]!); // Add tasks for this group
      }
    }

    return rows;
  }
}
