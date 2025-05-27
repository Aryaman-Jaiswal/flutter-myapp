enum UserRole {
  user,
  admin,
  superAdmin,
}

// Helper extension to convert enum to String and back
extension UserRoleExtension on UserRole {
  String toShortString() {
    return toString().split('.').last;
  }

  static UserRole fromString(String roleString) {
    switch (roleString) {
      case 'user':
        return UserRole.user;
      case 'admin':
        return UserRole.admin;
      case 'superAdmin':
        return UserRole.superAdmin;
      default:
        return UserRole.user; // Default role
    }
  }
}