import '../utils/constants.dart'; 

class User {
  final int? id; // SQLite will auto-increment this
  final String firstName;
  final String lastName;
  final String email;
  final String password; 
  final String mobileNo;
  UserRole role; 

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.mobileNo,
    this.role = UserRole.user, // Default role
  });

  // Convert a User object into a Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'mobileNo': mobileNo,
      'role': role.toShortString(), // Store enum as string
    };
  }

  // Convert a Map (from SQLite) into a User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      password: map['password'],
      mobileNo: map['mobileNo'],
      role: UserRoleExtension.fromString(map['role']), // Convert string to enum
    );
  }
}