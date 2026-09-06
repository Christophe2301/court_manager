import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/member.dart';
import '../../../core/constants/app_constants.dart';

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
Stream<List<Member>> watchActiveMembers() {
  return _firestore
      .collection('members')
      .where('isActive', isEqualTo: true)
      .orderBy('lastName')
      .orderBy('firstName')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Member.fromFirestore(doc),
            )
            .toList(),
      );
}

Stream<List<Member>> watchMembersForSeason(
  String seasonId,
) {
  return _firestore
      .collection('members')
      .where(
        'seasonIds',
        arrayContains: seasonId,
      )
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Member.fromFirestore(doc),
            )
            .where(
              (member) => member.isActive,
            )
            .toList()
          ..sort(
            (a, b) {
              final lastNameCompare =
                  a.lastName.compareTo(
                b.lastName,
              );

              if (lastNameCompare != 0) {
                return lastNameCompare;
              }

              return a.firstName.compareTo(
                b.firstName,
              );
            },
          ),
      );
}

Stream<List<Member>> watchInactiveMembersForSeason(
  String seasonId,
) {
  return _firestore
      .collection('members')
      .where(
        'seasonIds',
        arrayContains: seasonId,
      )
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Member.fromFirestore(doc),
            )
            .where(
              (member) => !member.isActive,
            )
            .toList()
          ..sort(
            (a, b) {
              final lastNameCompare =
                  a.lastName.compareTo(
                b.lastName,
              );

              if (lastNameCompare != 0) {
                return lastNameCompare;
              }

              return a.firstName.compareTo(
                b.firstName,
              );
            },
          ),
      );
}

Future<bool> licenseNumberExists(
  String licenseNumber, {
  String? excludeMemberId,
}) async {
  final snapshot = await _firestore
      .collection('members')
      .where(
        'licenseNumber',
        isEqualTo: licenseNumber.trim(),
      )
      .limit(10)
      .get();

  for (final doc in snapshot.docs) {
    if (doc.id != excludeMemberId) {
      return true;
    }
  }

  return false;
}

Future<Member?> findMemberByLicenseNumber(
  String licenseNumber,
) async {
  final snapshot = await _firestore
      .collection('members')
      .where(
        'licenseNumber',
        isEqualTo: licenseNumber.trim(),
      )
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) {
    return null;
  }

  return Member.fromFirestore(
    snapshot.docs.first,
  );
}

Future<void> addSeasonToMember({
  required String memberId,
  required String seasonId,
}) async {
  await _firestore
      .collection('members')
      .doc(memberId)
      .update({
    'seasonIds': FieldValue.arrayUnion(
      [seasonId],
    ),
    'isActive': true,
    'updatedAt': Timestamp.now(),
  });
}

Future<void> createMember(
  Member member,
) async {
  final data = member.toFirestore();

  data['seasonIds'] = [currentSeasonId];

  await _firestore
      .collection('members')
      .doc(member.id)
      .set(data);
}

String newMemberId() {
  return _firestore
      .collection('members')
      .doc()
      .id;
}

Future<void> updateMember(
  Member member,
) async {
  await _firestore
      .collection('members')
      .doc(member.id)
      .update({
    'licenseNumber': member.licenseNumber,
    'firstName': member.firstName,
    'lastName': member.lastName,
    'birthDate': member.birthDate != null
        ? Timestamp.fromDate(member.birthDate!)
        : null,
    'email': member.email,
    'phone': member.phone,
    'isActive': member.isActive,
    'notes': member.notes,
    'updatedAt': Timestamp.fromDate(
      member.updatedAt,
    ),
    'updatedBy': member.updatedBy,
  });
}

Future<void> deactivateMember(
  String memberId,
  String updatedBy,
) async {
  await _firestore
      .collection('members')
      .doc(memberId)
      .update({
    'isActive': false,
    'updatedAt': Timestamp.fromDate(
      DateTime.now(),
    ),
    'updatedBy': updatedBy,
  });
}

Stream<List<Member>> watchInactiveMembers() {
  return _firestore
      .collection('members')
      .where('isActive', isEqualTo: false)
      .orderBy('lastName')
      .orderBy('firstName')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Member.fromFirestore(doc),
            )
            .toList(),
      );
}

Future<void> reactivateMember(
  String memberId,
  String updatedBy,
) async {
  await _firestore
      .collection('members')
      .doc(memberId)
      .update({
    'isActive': true,
    'updatedAt': Timestamp.fromDate(
      DateTime.now(),
    ),
    'updatedBy': updatedBy,
  });
}

}