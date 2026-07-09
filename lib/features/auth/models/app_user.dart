enum AppUserRole {
  admin,
  teacher,
}

class AppUser {
  final String uid;

  final String firstName;
  final String lastName;

  final String email;

  final AppUserRole role;

  final bool active;

  const AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.active,
  });

  String get fullName {
    return '$firstName $lastName';
  }

  bool get isAdmin {
    return role == AppUserRole.admin;
  }

  bool get isTeacher {
    return role == AppUserRole.teacher;
  }
}