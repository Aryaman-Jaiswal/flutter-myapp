import 'package:gantt_view/gantt_view.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../models/client.dart';

// Helper class to hold TASK data for Gantt chart
class TaskGanttData {
  final Task task; // Holds a Task object
  final DateTime startDate;
  final DateTime endDate;
  final String taskId;
  final String taskName;
  final String assignedToName;
  final String tooltip;

  TaskGanttData({
    required this.task,
    required this.startDate,
    required this.endDate,
    required this.taskId,
    required this.taskName,
    required this.assignedToName,
    required this.tooltip,
  });

  @override
  String toString() {
    return '$taskName\nAssigned to: $assignedToName';
  }
}

// Extension to convert a List<Task> into a List<GridRow>
extension TaskListToGanttRows on List<Task> {
  List<GridRow> toGanttRows(List<Client> clients, List<User> users) {
    List<GridRow> rows = [];

    sort((a, b) {
      DateTime aStart = DateFormat('MMM dd, yyyy').parse(a.startDate);
      DateTime bStart = DateFormat('MMM dd, yyyy').parse(b.startDate);
      return aStart.compareTo(bStart);
    });

    for (var task in this) {
      DateTime startDate = DateFormat('MMM dd, yyyy').parse(task.startDate);
      DateTime endDate = DateFormat('MMM dd, yyyy').parse(task.deadline);

      String assignedUserName = users
          .firstWhere(
            (u) => u.id == task.assignedToUserId,
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

      final TaskGanttData ganttData = TaskGanttData(
        task: task, // This is correct
        startDate: startDate,
        endDate: endDate,
        taskId: task.id?.toString() ?? 'N/A',
        taskName: task.taskName,
        assignedToName: assignedUserName,
        tooltip:
            'Task: ${task.taskName}\nAssigned: $assignedUserName\nStarts: ${task.startDate}\nEnds: ${task.deadline}',
      );

      rows.add(
        TaskGridRow<TaskGanttData>(
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
