import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/member.dart';

class MemberRepository {
  final FirebaseFirestore _firestore;

  MemberRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;


  Stream<List<Member>> watchMembersForGroup(
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
        .asyncMap(
          (snapshot) async {

            final members = <Member>[];

            for (final enrollment in snapshot.docs) {

              final memberId =
                  enrollment['memberId'] as String;


              final memberSnapshot =
                  await _firestore
                      .collection('members')
                      .doc(memberId)
                      .get();


              if (memberSnapshot.exists) {

                members.add(
                  Member.fromFirestore(
                    memberSnapshot,
                  ),
                );

              }
            }

            return members;
          },
        );
  }
}