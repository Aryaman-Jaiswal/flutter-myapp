// lib/models/project.dart

class Project {
  final int? id;
  final String name;
  final String description;
  final int clientId; // Which client this project is for

  Project({
    this.id,
    required this.name,
    this.description = '',
    required this.clientId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'clientId': clientId,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      clientId: map['clientId'],
    );
  }
}
