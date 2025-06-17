import 'package:flutter/material.dart'; // Just for Color type for priority chips

class Task {
  final int? id;
  final String taskName;
  final int projectId; // ID of the project this task belongs to
  // e.g., Design, Frontend
  final int clientId; // ID of the client this project belongs to
  final int assignedToUserId; // ID of the user assigned to this project
  final String startDate;
  final String deadline; // Storing as String for now, can be DateTime
  final String status; // To Do, In Progress, On Review, Ready

  // Mock attributes for display in list view
  final String description;
  final String trackedTime;

  Task({
    this.id,
    required this.taskName,
    required this.projectId,

    required this.clientId,
    required this.assignedToUserId,
    required this.startDate,
    required this.deadline,
    required this.status,
    this.description = '',
    this.trackedTime = '0h 0m',
  });

  // Convert Project object to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskName': taskName,
      'projectId': projectId,

      'clientId': clientId,
      'assignedToUserId': assignedToUserId,
      'startDate': startDate,
      'deadline': deadline,
      'status': status,
      // description and trackedTime are not stored in DB for now
    };
  }

  // Convert Map from SQLite to Project object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      taskName: map['taskName'],
      projectId: map['projectId'],

      clientId: map['clientId'],
      assignedToUserId: map['assignedToUserId'],
      startDate: map['startDate'],
      deadline: map['deadline'],
      status: map['status'],
      // description and trackedTime will default on load if not in map
    );
  }
}

// Helper for priority colors (can be used for Type too if consistent)
