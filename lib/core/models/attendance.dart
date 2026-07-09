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
}