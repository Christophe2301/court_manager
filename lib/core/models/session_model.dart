class SessionModel {
  final String id;
  final String groupId;
  final String seasonId;
  final List<String> teacherIds;
  final DateTime date;
  final String startTime;
  final int durationMinutes;
  final String status;

  SessionModel({
    required this.id,
    required this.groupId,
    required this.seasonId,
    required this.teacherIds,
    required this.date,
    required this.startTime,
    required this.durationMinutes,
    required this.status,
  });

  factory SessionModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return SessionModel(
      id: documentId,
      groupId: data['groupId'] ?? '',
      seasonId: data['seasonId'] ?? '',
      teacherIds: List<String>.from(
        data['teacherIds'] ?? [],
      ),
      date: (data['date']).toDate(),
      startTime: data['startTime'] ?? '',
      durationMinutes:
          data['durationMinutes'] ?? 60,
      status: data['status'] ?? 'planned',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'seasonId': seasonId,
      'teacherIds': teacherIds,
      'date': date,
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'status': status,
    };
  }
}