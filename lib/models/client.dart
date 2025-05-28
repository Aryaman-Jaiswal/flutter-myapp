class Client {
  final int? id;
  final String name;
  final String city;
  final String state;

  Client({
    this.id,
    required this.name,
    required this.city,
    required this.state,
  });

  // Convert a Client object into a Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'city': city, 'state': state};
  }

  // Convert a Map (from SQLite) into a Client object
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      city: map['city'],
      state: map['state'],
    );
  }
}
