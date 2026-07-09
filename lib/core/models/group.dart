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
}