import 'package:cloud_firestore/cloud_firestore.dart';
enum AttendanceStatus {
  present,
  absent,
  excused,
  makeup,
  trial,
  guest,
}

class Attendance {
  final String id;

  final String sessionId;
  final String memberId;

  final AttendanceStatus status;

  final String? comment;

  final DateTime? checkedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String createdBy;
  final String updatedBy;

  const Attendance({
    required this.id,
    required this.sessionId,
    required this.memberId,
    required this.status,
    this.comment,
    this.checkedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  bool get isPresent {
    return status == AttendanceStatus.present;
  }

  bool get isExcused {
    return status == AttendanceStatus.excused;
  }
factory Attendance.fromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {

  final data = doc.data()!;

  return Attendance(
    id: doc.id,

    sessionId:
        data['sessionId'] ?? '',

    memberId:
        data['memberId'] ?? '',

    status:
        AttendanceStatus.values.firstWhere(
          (e) =>
              e.name ==
              (data['status'] ?? 'absent'),
          orElse: () =>
              AttendanceStatus.absent,
        ),

    comment:
        data['comment'],

    checkedAt:
        data['checkedAt'] != null
            ? (data['checkedAt'] as Timestamp)
                .toDate()
            : null,

    createdAt:
        (data['createdAt'] as Timestamp)
            .toDate(),

    updatedAt:
        (data['updatedAt'] as Timestamp)
            .toDate(),

    createdBy:
        data['createdBy'] ?? '',

    updatedBy:
        data['updatedBy'] ?? '',
  );
}


Map<String, dynamic> toFirestore() {

  return {

    'sessionId':
        sessionId,

    'memberId':
        memberId,

    'status':
        status.name,

    'comment':
        comment,

    'checkedAt':
        checkedAt != null
            ? Timestamp.fromDate(checkedAt!)
            : null,

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
}