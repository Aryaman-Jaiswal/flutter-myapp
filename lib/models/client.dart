class Client {
  final int? id;
  final String name;
  final String city;
  final String state;
  final String mobileNo; // Make it a required field

  // Mock attributes for UI only
  final String caseRef;
  final String openedAt;
  final String doa;
  final String source;
  final String serviceProvider;
  final List<String> services;
  final double value;

  Client({
    this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.mobileNo, // NEW: Make mobileNo required in constructor
    this.caseRef = 'CC/0000',
    this.openedAt = 'N/A',
    this.doa = 'N/A',
    this.source = 'N/A',
    this.serviceProvider = 'N/A',
    this.services = const [],
    this.value = 0.0,
  });

  // Convert a Client object into a Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'state': state,
      'mobileNo': mobileNo, // Include mobileNo for persistence
    };
  }

  // Convert a Map (from SQLite) into a Client object
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      city: map['city'],
      state: map['state'],
      mobileNo: map['mobileNo'], // Load mobileNo from DB
      // Mock attributes are not loaded from DB, will use defaults defined above
    );
  }
}
