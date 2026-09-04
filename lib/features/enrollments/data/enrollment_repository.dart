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

Stream<List<Enrollment>> watchEnrollmentsForSeason(
  String seasonId,
) {
  return _firestore
      .collection('enrollments')
      .where(
        'seasonId',
        isEqualTo: seasonId,
      )
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Enrollment.fromFirestore(doc),
            )
            .where(
              (enrollment) => enrollment.isActive,
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

Future<void> deactivateEnrollmentsForMember({
  required String memberId,
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
        'seasonId',
        isEqualTo: seasonId,
      )
      .where(
        'isActive',
        isEqualTo: true,
      )
      .get();

  if (snapshot.docs.isEmpty) {
    return;
  }

  final now = DateTime.now();
  final batch = _firestore.batch();

  for (final doc in snapshot.docs) {
    batch.update(
      doc.reference,
      {
        'isActive': false,
        'endDate': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'updatedBy': updatedBy,
      },
    );
  }

  await batch.commit();
}

Future<void> transferEnrollment({
  required String memberId,
  required String fromGroupId,
  required String toGroupId,
  required String seasonId,
  required DateTime transferDate,
  required String updatedBy,
}) async {
  if (fromGroupId == toGroupId) {
    throw StateError(
      'Le groupe de départ et le groupe d’arrivée '
      'doivent être différents.',
    );
  }

  final targetExists =
      await activeEnrollmentExists(
    memberId: memberId,
    groupId: toGroupId,
    seasonId: seasonId,
  );

  if (targetExists) {
    throw StateError(
      'Cet adhérent est déjà inscrit '
      'dans le groupe sélectionné.',
    );
  }

  final sourceSnapshot = await _firestore
      .collection('enrollments')
      .where(
        'memberId',
        isEqualTo: memberId,
      )
      .where(
        'groupId',
        isEqualTo: fromGroupId,
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

  if (sourceSnapshot.docs.isEmpty) {
    throw StateError(
      'Inscription active introuvable '
      'dans le groupe de départ.',
    );
  }

  final now = DateTime.now();

  final newEnrollmentRef =
      _firestore
          .collection('enrollments')
          .doc();

  final batch = _firestore.batch();

  batch.update(
    sourceSnapshot.docs.first.reference,
    {
      'isActive': false,
      'endDate':
          Timestamp.fromDate(
        transferDate,
      ),
      'updatedAt':
          Timestamp.fromDate(now),
      'updatedBy':
          updatedBy,
    },
  );

  batch.set(
    newEnrollmentRef,
    {
      'memberId':
          memberId,
      'groupId':
          toGroupId,
      'seasonId':
          seasonId,
      'startDate':
          Timestamp.fromDate(
        transferDate,
      ),
      'endDate':
          null,
      'isActive':
          true,
      'createdAt':
          Timestamp.fromDate(now),
      'updatedAt':
          Timestamp.fromDate(now),
      'createdBy':
          updatedBy,
      'updatedBy':
          updatedBy,
    },
  );

  await batch.commit();
}

}