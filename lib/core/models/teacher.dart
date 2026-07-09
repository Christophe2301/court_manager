enum UserRole {
  admin,
  teacher,
}

class Teacher {
  final String id;

  final String firstName;
  final String lastName;

  final String email;

  final UserRole role;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String createdBy;
  final String updatedBy;

  const Teacher({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  String get fullName {
    return '$firstName $lastName';
  }

  bool get isAdmin {
    return role == UserRole.admin;
  }

  bool get isTeacher {
    return role == UserRole.teacher;
  }
}