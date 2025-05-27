class Client {
  final int? id;
  final String name;
  final String city;

  Client({
    this.id,
    required this.name,
    required this.city,
  });

  // Convert a Client object into a Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
    };
  }

  // Convert a Map (from SQLite) into a Client object
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      city: map['city'],
    );
  }
}