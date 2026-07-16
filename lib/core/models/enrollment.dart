import 'package:cloud_firestore/cloud_firestore.dart';

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


  factory Enrollment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Enrollment(
      id: doc.id,

      memberId:
          data['memberId'] ?? '',

      groupId:
          data['groupId'] ?? '',

      seasonId:
          data['seasonId'] ?? '',

      startDate:
          data['startDate'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : DateTime.now(),

      endDate:
          data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,

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
      'memberId': memberId,

      'groupId': groupId,

      'seasonId': seasonId,

      'startDate':
          Timestamp.fromDate(startDate),

      'endDate':
          endDate != null
              ? Timestamp.fromDate(endDate!)
              : null,

      'isActive': isActive,

      'createdAt':
          Timestamp.fromDate(createdAt),

      'updatedAt':
          Timestamp.fromDate(updatedAt),

      'createdBy': createdBy,

      'updatedBy': updatedBy,
    };
  }


  Enrollment copyWith({
    String? memberId,
    String? groupId,
    String? seasonId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Enrollment(
      id: id,

      memberId:
          memberId ?? this.memberId,

      groupId:
          groupId ?? this.groupId,

      seasonId:
          seasonId ?? this.seasonId,

      startDate:
          startDate ?? this.startDate,

      endDate:
          endDate ?? this.endDate,

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