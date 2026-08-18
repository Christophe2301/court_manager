import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/auth/models/app_user.dart';

class TeacherRepository {
  final FirebaseFirestore _firestore;

  TeacherRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  Stream<List<AppUser>> watchActiveTeachers() {
    return _firestore
        .collection('users')
        .where(
          'role',
          isEqualTo: 'teacher',
        )
        .where(
          'active',
          isEqualTo: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AppUser(
                  uid: doc.id,
                  firstName:
                      doc.data()['firstName'] ?? '',
                  lastName:
                      doc.data()['lastName'] ?? '',
                  email:
                      doc.data()['email'] ?? '',
                  role: AppUserRole.teacher,
                  active:
                      doc.data()['active'] ?? true,
                ),
              )
              .toList(),
        );
  }

Future<void> updateTeacher({
  required String uid,
  required String firstName,
  required String lastName,
  required String email,
  required bool active,
  required String updatedBy,
}) async {
  await _firestore
      .collection('users')
      .doc(uid)
      .update({
    'firstName': firstName.trim(),
    'lastName': lastName.trim(),
    'email': email.trim(),
    'active': active,
    'updatedAt': FieldValue.serverTimestamp(),
    'updatedBy': updatedBy,
  });
}

Future<AppUser?> getTeacher(
  String uid,
) async {
  final snapshot = await _firestore
      .collection('users')
      .doc(uid)
      .get();

  if (!snapshot.exists) {
    return null;
  }

  final data = snapshot.data()!;

  return AppUser(
    uid: snapshot.id,
    firstName: data['firstName'] ?? '',
    lastName: data['lastName'] ?? '',
    email: data['email'] ?? '',
    role: data['role'] == 'admin'
        ? AppUserRole.admin
        : AppUserRole.teacher,
    active: data['active'] ?? true,
  );
}

Future<void> deactivateTeacher({
  required String uid,
  required String updatedBy,
}) async {
  await _firestore
      .collection('users')
      .doc(uid)
      .update({
    'active': false,
    'updatedAt': FieldValue.serverTimestamp(),
    'updatedBy': updatedBy,
  });
}

Stream<List<AppUser>> watchInactiveTeachers() {
  return _firestore
      .collection('users')
      .where(
        'role',
        isEqualTo: 'teacher',
      )
      .where(
        'active',
        isEqualTo: false,
      )
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => AppUser(
                uid: doc.id,
                firstName:
                    doc.data()['firstName'] ?? '',
                lastName:
                    doc.data()['lastName'] ?? '',
                email:
                    doc.data()['email'] ?? '',
                role: AppUserRole.teacher,
                active:
                    doc.data()['active'] ?? false,
              ),
            )
            .toList(),
      );
}

Future<void> reactivateTeacher({
  required String uid,
  required String updatedBy,
}) async {
  await _firestore
      .collection('users')
      .doc(uid)
      .update({
    'active': true,
    'updatedAt': FieldValue.serverTimestamp(),
    'updatedBy': updatedBy,
  });
}

}