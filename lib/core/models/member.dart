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
}