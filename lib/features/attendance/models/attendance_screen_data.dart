import '../../../core/models/member.dart';
import '../../../core/models/attendance.dart';

class AttendanceScreenData {
  final List<Member> members;
  final Map<String, AttendanceStatus> attendances;

  const AttendanceScreenData({
    required this.members,
    required this.attendances,
  });
}