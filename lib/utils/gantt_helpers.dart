import 'package:gantt_view/gantt_view.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../models/user.dart'; // Import User model
import '../models/client.dart';

// Helper class to hold project data for Gantt chart
class ProjectGanttData {
  final Project project;
  final DateTime startDate;
  final DateTime endDate;
  final String taskId;
  final String taskName;
  final String assignedToName; // NEW: Assigned user's name
  final String tooltip;

  ProjectGanttData({
    required this.project,
    required this.startDate,
    required this.endDate,
    required this.taskId,
    required this.taskName,
    required this.assignedToName, // NEW
    required this.tooltip,
  });

  @override
  String toString() {
    // This string is used for the default left-hand label
    return '$taskName\n${assignedToName}'; // Format as "Task Name\nAssigned To Name"
  }
}

// Extension to convert a List<Project> into a List<GridRow>
extension ProjectListToGanttRows on List<Project> {
  // Pass clients and users lists to the extension to get names
  List<GridRow> toGanttRows(List<Client> clients, List<User> users) {
    List<GridRow> rows = [];

    // Sort projects by start date for better timeline display
    sort((a, b) {
      DateTime aStart = DateFormat('MMM dd, yyyy').parse(a.startDate);
      DateTime bStart = DateFormat('MMM dd, yyyy').parse(b.startDate);
      return aStart.compareTo(bStart);
    });

    for (var project in this) {
      DateTime startDate = DateFormat('MMM dd, yyyy').parse(project.startDate);
      DateTime endDate = DateFormat('MMM dd, yyyy').parse(project.deadline);

      // Helper to get user name from ID (re-use from ProjectListScreen)
      String assignedUserName = users
          .firstWhere(
            (u) => u.id == project.assignedToUserId,
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

      final ProjectGanttData ganttData = ProjectGanttData(
        project: project,
        startDate: startDate,
        endDate: endDate,
        taskId: project.id?.toString() ?? 'N/A',
        taskName: project.taskName,
        assignedToName: assignedUserName, // Pass assigned user's name
        tooltip:
            'Task: ${project.taskName}\nAssigned: $assignedUserName\nStarts: ${project.startDate}\nEnds: ${project.deadline}',
      );

      // Directly add TaskGridRow without ActivityGridRow
      rows.add(
        TaskGridRow<ProjectGanttData>(
          data: ganttData,
          startDate: ganttData.startDate,
          endDate: ganttData.endDate,
          tooltip: ganttData.tooltip,
        ),
      );
    }

    return rows;
  }
}
