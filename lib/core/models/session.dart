import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus {
  planned,
  completed,
  cancelled,
}


class Session {
  final String id;

  final String groupId;

  final DateTime date;

  final String startTime;

  final int durationMinutes;

  final List<String> teacherIds;

  final SessionStatus status;

  final String? cancellationReason;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String createdBy;
  final String updatedBy;


  const Session({
    required this.id,
    required this.groupId,
    required this.date,
    required this.startTime,
    required this.durationMinutes,
    required this.teacherIds,
    required this.status,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });


  bool get isCancelled {
    return status == SessionStatus.cancelled;
  }


  bool get hasMultipleTeachers {
    return teacherIds.length > 1;
  }


  factory Session.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Session(
      id: doc.id,

      groupId:
          data['groupId'] ?? '',

      date:
          data['date'] != null
              ? (data['date'] as Timestamp).toDate()
              : DateTime.now(),

      startTime:
          data['startTime'] ?? '',

      durationMinutes:
          data['durationMinutes'] ?? 60,

      teacherIds:
          List<String>.from(
            data['teacherIds'] ?? [],
          ),

      status:
          SessionStatus.values.firstWhere(
            (e) => e.name == data['status'],
            orElse: () => SessionStatus.planned,
          ),

      cancellationReason:
          data['cancellationReason'],

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
      'groupId': groupId,

      'date':
          Timestamp.fromDate(date),

      'startTime': startTime,

      'durationMinutes':
          durationMinutes,

      'teacherIds':
          teacherIds,

      'status':
          status.name,

      'cancellationReason':
          cancellationReason,

      'createdAt':
          Timestamp.fromDate(createdAt),

      'updatedAt':
          Timestamp.fromDate(updatedAt),

      'createdBy':
          createdBy,

      'updatedBy':
          updatedBy,
    };
  }


  Session copyWith({
    String? groupId,
    DateTime? date,
    String? startTime,
    int? durationMinutes,
    List<String>? teacherIds,
    SessionStatus? status,
    String? cancellationReason,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Session(
      id: id,

      groupId:
          groupId ?? this.groupId,

      date:
          date ?? this.date,

      startTime:
          startTime ?? this.startTime,

      durationMinutes:
          durationMinutes ?? this.durationMinutes,

      teacherIds:
          teacherIds ?? this.teacherIds,

      status:
          status ?? this.status,

      cancellationReason:
          cancellationReason ?? this.cancellationReason,

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