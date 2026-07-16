import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String id;
  final String licenseNumber;

  final String firstName;
  final String lastName;

  final DateTime? birthDate;

  final String? email;
  final String? phone;

  final bool isActive;

  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String createdBy;
  final String updatedBy;

  const Member({
    required this.id,
    required this.licenseNumber,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.email,
    this.phone,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  String get fullName {
    return '$firstName $lastName';
  }


  factory Member.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Member(
      id: doc.id,
      licenseNumber: data['licenseNumber'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',

      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,

      email: data['email'],
      phone: data['phone'],

      isActive: data['isActive'] ?? true,

      notes: data['notes'],

      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),

      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
    );
  }


  Map<String, dynamic> toFirestore() {
    return {
      'licenseNumber': licenseNumber,

      'firstName': firstName,
      'lastName': lastName,

      'birthDate': birthDate != null
          ? Timestamp.fromDate(birthDate!)
          : null,

      'email': email,
      'phone': phone,

      'isActive': isActive,

      'notes': notes,

      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),

      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }


  Member copyWith({
    String? licenseNumber,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? email,
    String? phone,
    bool? isActive,
    String? notes,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Member(
      id: id,

      licenseNumber:
          licenseNumber ?? this.licenseNumber,

      firstName:
          firstName ?? this.firstName,

      lastName:
          lastName ?? this.lastName,

      birthDate:
          birthDate ?? this.birthDate,

      email:
          email ?? this.email,

      phone:
          phone ?? this.phone,

      isActive:
          isActive ?? this.isActive,

      notes:
          notes ?? this.notes,

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