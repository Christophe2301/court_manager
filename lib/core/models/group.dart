import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupType {
  tennisSchool,
  adultLeisure,
  competition,
  team,
  course,
  other,
}

class Group {
  final String id;

  final String name;

  final GroupType type;

  final String seasonId;

  final int dayOfWeek;

  final String startTime;

  final int durationMinutes;

  final List<String> teacherIds;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String createdBy;
  final String updatedBy;

  const Group({
    required this.id,
    required this.name,
    required this.type,
    required this.seasonId,
    required this.dayOfWeek,
    required this.startTime,
    required this.durationMinutes,
    required this.teacherIds,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });


  bool get hasMultipleTeachers {
    return teacherIds.length > 1;
  }


  factory Group.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Group(
      id: doc.id,

      name: data['name'] ?? '',

      type: GroupType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => GroupType.other,
      ),

      seasonId: data['seasonId'] ?? '',

      dayOfWeek: data['dayOfWeek'] ?? 1,

      startTime: data['startTime'] ?? '',

      durationMinutes:
          data['durationMinutes'] ?? 60,

      teacherIds:
          List<String>.from(data['teacherIds'] ?? []),

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
      'name': name,

      'type': type.name,

      'seasonId': seasonId,

      'dayOfWeek': dayOfWeek,

      'startTime': startTime,

      'durationMinutes': durationMinutes,

      'teacherIds': teacherIds,

      'isActive': isActive,

      'createdAt': Timestamp.fromDate(createdAt),

      'updatedAt': Timestamp.fromDate(updatedAt),

      'createdBy': createdBy,

      'updatedBy': updatedBy,
    };
  }


  Group copyWith({
    String? name,
    GroupType? type,
    String? seasonId,
    int? dayOfWeek,
    String? startTime,
    int? durationMinutes,
    List<String>? teacherIds,
    bool? isActive,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Group(
      id: id,

      name:
          name ?? this.name,

      type:
          type ?? this.type,

      seasonId:
          seasonId ?? this.seasonId,

      dayOfWeek:
          dayOfWeek ?? this.dayOfWeek,

      startTime:
          startTime ?? this.startTime,

      durationMinutes:
          durationMinutes ?? this.durationMinutes,

      teacherIds:
          teacherIds ?? this.teacherIds,

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