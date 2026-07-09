class Enrollment {
  final String id;

  final String memberId;
  final String groupId;

  final String seasonId;

  final DateTime startDate;
  final DateTime? endDate;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String createdBy;
  final String updatedBy;

  const Enrollment({
    required this.id,
    required this.memberId,
    required this.groupId,
    required this.seasonId,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  bool get isCurrent {
    return isActive && endDate == null;
  }
}