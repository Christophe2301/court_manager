import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/member.dart';
import '../../../core/models/attendance.dart';
import '../models/attendance_screen_data.dart';

class AttendanceRepository {
  final FirebaseFirestore _firestore;

  AttendanceRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  Future<List<Member>> getMembersByGroup(
    String groupId,
  ) async {
    final enrollments = await _firestore
        .collection('enrollments')
        .where(
          'groupId',
          isEqualTo: groupId,
        )
        .where(
          'isActive',
          isEqualTo: true,
        )
        .get();

    final members = <Member>[];

    for (final enrollment in enrollments.docs) {
      final memberId =
          enrollment.data()['memberId'];

      final memberDoc = await _firestore
          .collection('members')
          .doc(memberId)
          .get();

      if (memberDoc.exists) {
        members.add(
          Member.fromFirestore(memberDoc),
        );
      }
    }

    members.sort(
      (a, b) =>
          a.lastName.compareTo(b.lastName),
    );

    return members;
  }

Future<List<Member>> getActiveMembers() async {
  final snapshot = await _firestore
      .collection('members')
      .where(
        'isActive',
        isEqualTo: true,
      )
      .get();

  final members = snapshot.docs
      .map(
        (doc) => Member.fromFirestore(doc),
      )
      .toList();

  members.sort(
    (a, b) =>
        a.lastName.compareTo(b.lastName),
  );

  return members;
}

  Future<void> saveAttendances({
    required String sessionId,
    required Map<String, AttendanceStatus> attendance,
    required Map<String, String> trialPersons,
    required String userId,
  }) async {
    final batch = _firestore.batch();

    final now = DateTime.now();

    attendance.forEach(
      (memberId, status) {
        final docId =
            '${sessionId}_$memberId';

        final doc = _firestore
            .collection('attendance')
            .doc(docId);

        final record = Attendance(
          id: doc.id,
          sessionId: sessionId,
          memberId: memberId,
          trialName: trialPersons[memberId],
          status: status,
          comment: null,
          checkedAt: now,
          createdAt: now,
          updatedAt: now,
          createdBy: userId,
          updatedBy: userId,
        );

        batch.set(
          doc,
          record.toFirestore(),
          SetOptions(merge: true),
        );
      },
    );

    await batch.commit();
  }

Future<AttendanceScreenData>
    getAttendanceScreenData(
  String sessionId,
  String groupId,
) async {
  final members =
      await getMembersByGroup(groupId);

  final attendances =
      await getAttendancesBySession(
    sessionId,
  );

final attendanceRecords =
    await getAttendanceRecordsBySession(
  sessionId,
);

  final availableMembers =
      await getActiveMembers();

  // --------------------------------------------------
  // Identification des adhérents ponctuels
  // --------------------------------------------------

  final regularMemberIds =
      members.map((member) => member.id).toSet();

final trialPersons = <String, String>{};

for (final attendance
    in attendanceRecords) {
  if (attendance.trialName != null &&
      attendance.trialName!
          .trim()
          .isNotEmpty) {
    trialPersons[
            attendance.memberId] =
        attendance.trialName!;
  }
}

  final temporaryMemberIds =
    attendances.keys
        .where(
          (memberId) =>
              !regularMemberIds.contains(memberId) &&
              !trialPersons.containsKey(memberId),
        )
        .toSet();

  // --------------------------------------------------
  // Ajout des adhérents ponctuels à la liste des membres
  // --------------------------------------------------

  for (final memberId in temporaryMemberIds) {
    final memberDoc = await _firestore
        .collection('members')
        .doc(memberId)
        .get();

    if (memberDoc.exists) {
      members.add(
        Member.fromFirestore(memberDoc),
      );
    }
  }

  // On conserve le classement alphabétique.
  members.sort(
    (a, b) =>
        a.lastName.compareTo(b.lastName),
  );

  return AttendanceScreenData(
    members: members,
    attendances: attendances,
    availableMembers: availableMembers,
    temporaryMemberIds: temporaryMemberIds,
    trialPersons: trialPersons,
  );
}
  
  Future<List<Attendance>>
    getAttendanceRecordsBySession(
  String sessionId,
) async {
  final snapshot = await _firestore
      .collection('attendance')
      .where(
        'sessionId',
        isEqualTo: sessionId,
      )
      .get();

  return snapshot.docs
      .map(
        (doc) =>
            Attendance.fromFirestore(doc),
      )
      .toList();
}
  
  Future<Map<String, AttendanceStatus>>
      getAttendancesBySession(
    String sessionId,
  ) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where(
          'sessionId',
          isEqualTo: sessionId,
        )
        .get();

    final result =
        <String, AttendanceStatus>{};

    for (final doc in snapshot.docs) {
      final attendance =
          Attendance.fromFirestore(doc);

      result[attendance.memberId] =
          attendance.status;
    }

    return result;
  }
Future<Member?> getMemberById(
  String memberId,
) async {
  final doc = await _firestore
      .collection('members')
      .doc(memberId)
      .get();

  if (!doc.exists) {
    return null;
  }

  return Member.fromFirestore(doc);
}

Future<void> deleteTrialAttendance({
  required String sessionId,
  required String trialId,
}) async {
  final docId =
      '${sessionId}_$trialId';

  await _firestore
      .collection('attendance')
      .doc(docId)
      .delete();
}

}