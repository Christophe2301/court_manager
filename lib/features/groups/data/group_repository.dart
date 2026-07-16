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
}