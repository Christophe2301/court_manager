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
}