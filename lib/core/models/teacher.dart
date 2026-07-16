import 'package:cloud_firestore/cloud_firestore.dart';

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


  factory Teacher.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Teacher(
      id: doc.id,

      firstName:
          data['firstName'] ?? '',

      lastName:
          data['lastName'] ?? '',

      email:
          data['email'] ?? '',

      role:
          UserRole.values.firstWhere(
            (e) => e.name == data['role'],
            orElse: () => UserRole.teacher,
          ),

      isActive:
          data['isActive'] ?? true,

      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),

      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),

      createdBy:
          data['createdBy'] ?? '',

      updatedBy:
          data['updatedBy'] ?? '',
    );
  }


  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,

      'lastName': lastName,

      'email': email,

      'role': role.name,

      'isActive': isActive,

      'createdAt':
          Timestamp.fromDate(createdAt),

      'updatedAt':
          Timestamp.fromDate(updatedAt),

      'createdBy': createdBy,

      'updatedBy': updatedBy,
    };
  }


  Teacher copyWith({
    String? firstName,
    String? lastName,
    String? email,
    UserRole? role,
    bool? isActive,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Teacher(
      id: id,

      firstName:
          firstName ?? this.firstName,

      lastName:
          lastName ?? this.lastName,

      email:
          email ?? this.email,

      role:
          role ?? this.role,

      isActive:
          isActive ?? this.isActive,

      createdAt:
          createdAt,

      updatedAt:
          updatedAt ?? this.updatedAt,

      createdBy:
          createdBy,

      updatedBy:
          updatedBy ?? this.updatedBy,
    );
  }
}