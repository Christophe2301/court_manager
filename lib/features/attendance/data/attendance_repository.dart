import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/member.dart';
import '../../../core/models/attendance.dart';


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

    required Map<String, bool> attendance,

    required String userId,

  }) async {


    final batch =
        _firestore.batch();


    final now =
        DateTime.now();


    attendance.forEach(
      (memberId, present) {

        final doc =
            _firestore
                .collection('attendance')
                .doc();


        final record =
            Attendance(

              id: doc.id,

              sessionId:
                  sessionId,

              memberId:
                  memberId,

              status:
                  present
                      ? AttendanceStatus.present
                      : AttendanceStatus.absent,

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
        );
      },
    );


    await batch.commit();
  }
}