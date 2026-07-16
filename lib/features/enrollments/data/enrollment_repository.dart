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
}