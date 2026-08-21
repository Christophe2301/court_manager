import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/group.dart';

class GroupRepository {
  final FirebaseFirestore _firestore;

  GroupRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;


  Stream<List<Group>> watchActiveGroups() {
    return _firestore
        .collection('groups')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Group.fromFirestore(doc),
              )
              .toList(),
        );
  }

Stream<List<Group>> watchInactiveGroups() {
  return _firestore
      .collection('groups')
      .where(
        'isActive',
        isEqualTo: false,
      )
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Group.fromFirestore(doc),
            )
            .toList(),
      );
}

  Stream<List<Group>> watchGroupsForTeacher(
    String teacherId,
  ) {
    return _firestore
        .collection('groups')
        .where(
          'teacherIds',
          arrayContains: teacherId,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Group.fromFirestore(doc),
              )
              .toList(),
        );
  }


  Future<void> createGroup(Group group) async {
    await _firestore
        .collection('groups')
        .doc(group.id)
        .set(
          group.toFirestore(),
        );
  }

Future<void> updateGroup(Group group) async {
  await _firestore
      .collection('groups')
      .doc(group.id)
      .update(
    group.toFirestore(),
  );
}

Future<void> deactivateGroup({
  required String groupId,
  required String updatedBy,
}) async {
  await _firestore
      .collection('groups')
      .doc(groupId)
      .update({
    'isActive': false,
    'updatedAt': FieldValue.serverTimestamp(),
    'updatedBy': updatedBy,
  });
}

Future<void> reactivateGroup({
  required String groupId,
  required String updatedBy,
}) async {
  await _firestore
      .collection('groups')
      .doc(groupId)
      .update({
    'isActive': true,
    'updatedAt': FieldValue.serverTimestamp(),
    'updatedBy': updatedBy,
  });
}

Future<Group?> getGroup(String groupId) async {
  final doc = await _firestore
      .collection('groups')
      .doc(groupId)
      .get();

  if (!doc.exists) {
    return null;
  }

  return Group.fromFirestore(doc);
}

}