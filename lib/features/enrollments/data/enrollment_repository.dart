import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/enrollment.dart';

class EnrollmentRepository {
  final FirebaseFirestore _firestore;

  EnrollmentRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;


  Stream<List<Enrollment>> watchEnrollmentsForGroup(
    String groupId,
  ) {
    return _firestore
        .collection('enrollments')
        .where(
          'groupId',
          isEqualTo: groupId,
        )
        .where(
          'isActive',
          isEqualTo: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Enrollment.fromFirestore(doc),
              )
              .toList(),
        );
  }

Stream<List<Enrollment>> watchEnrollmentsForMember(
  String memberId,
) {
  return _firestore
      .collection('enrollments')
      .where(
        'memberId',
        isEqualTo: memberId,
      )
      .where(
        'isActive',
        isEqualTo: true,
      )
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Enrollment.fromFirestore(doc),
            )
            .toList(),
      );
}

Future<bool> activeEnrollmentExists({
  required String memberId,
  required String groupId,
  required String seasonId,
}) async {
  final snapshot = await _firestore
      .collection('enrollments')
      .where(
        'memberId',
        isEqualTo: memberId,
      )
      .where(
        'groupId',
        isEqualTo: groupId,
      )
      .where(
        'seasonId',
        isEqualTo: seasonId,
      )
      .where(
        'isActive',
        isEqualTo: true,
      )
      .limit(1)
      .get();

  return snapshot.docs.isNotEmpty;
}

Future<void> createEnrollment(
  Enrollment enrollment,
) async {
  await _firestore
      .collection('enrollments')
      .doc(enrollment.id)
      .set(
        enrollment.toFirestore(),
      );
}

String newEnrollmentId() {
  return _firestore
      .collection('enrollments')
      .doc()
      .id;
}

Future<void> deactivateEnrollment({
  required String memberId,
  required String groupId,
  required String seasonId,
  required String updatedBy,
}) async {
  final snapshot = await _firestore
      .collection('enrollments')
      .where(
        'memberId',
        isEqualTo: memberId,
      )
      .where(
        'groupId',
        isEqualTo: groupId,
      )
      .where(
        'seasonId',
        isEqualTo: seasonId,
      )
      .where(
        'isActive',
        isEqualTo: true,
      )
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) {
    return;
  }

  final now = DateTime.now();

  await snapshot.docs.first.reference.update({
    'isActive': false,
    'endDate': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
    'updatedBy': updatedBy,
  });
}

}