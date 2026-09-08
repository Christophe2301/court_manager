import '../../../core/models/member.dart';
import '../../../core/models/attendance.dart';

class AttendanceScreenData {
  final List<Member> members;
  final Map<String, AttendanceStatus> attendances;
  final List<Member> availableMembers;
  final Set<String> temporaryMemberIds;
  final Map<String, String> trialPersons;

  const AttendanceScreenData({
    required this.members,
    required this.attendances,
    required this.availableMembers,
    required this.temporaryMemberIds,
    required this.trialPersons,
  });

}