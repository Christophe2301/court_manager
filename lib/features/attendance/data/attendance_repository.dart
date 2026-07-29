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

    final enrollments =
        await _firestore
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


      final memberDoc =
          await _firestore
              .collection('members')
              .doc(memberId)
              .get();


      if (memberDoc.exists) {

        members.add(
          Member.fromFirestore(
            memberDoc,
          ),
        );
      }
    }


    members.sort(
      (a, b) =>
          a.lastName.compareTo(
            b.lastName,
          ),
    );


    return members;
  }




  Future<void> saveAttendances({

    required String sessionId,

    required Map<String, AttendanceStatus> attendance,

    required String userId,

  }) async {


    final batch =
        _firestore.batch();


    final now =
        DateTime.now();


    attendance.forEach(
      (memberId, status) {

       final docId =
    '${sessionId}_$memberId';


final doc =
    _firestore
        .collection('attendance')
        .doc(docId);


        final record =
            Attendance(

              id: doc.id,

              sessionId:
                  sessionId,

              memberId:
                  memberId,

              status: status,

              comment:
                  null,

              checkedAt:
                  now,

              createdAt:
                  now,

              updatedAt:
                  now,

              createdBy:
                  userId,

              updatedBy:
                  userId,
            );


        batch.set(
  doc,
  record.toFirestore(),
  SetOptions(
    merge: true,
  ),
);
      },
    );


    await batch.commit();
  }
  Future<Map<String, Attendance>> getAttendancesBySession(
  String sessionId,
) async {

  final snapshot = await _firestore
      .collection('attendance')
      .where(
        'sessionId',
        isEqualTo: sessionId,
      )
      .get();

  final attendances = <String, Attendance>{};

  for (final doc in snapshot.docs) {

    final attendance =
        Attendance.fromFirestore(doc);

    attendances[attendance.memberId] =
        attendance;
  }

  return attendances;
}
Future<AttendanceScreenData> getAttendanceScreenData(
  String sessionId,
  String groupId,
) async {

  final membersFuture =
      getMembersByGroup(groupId);

  final attendancesFuture =
      getAttendancesBySession(sessionId);

  final members =
      await membersFuture;

  final attendances =
      await attendancesFuture;

  return AttendanceScreenData(
    members: members,
    attendances: attendances,
  );
}
}