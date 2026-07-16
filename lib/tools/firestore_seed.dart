import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedFirestore() async {
  final firestore = FirebaseFirestore.instance;

  final now = DateTime.now();

  // -------------------------
  // TEACHERS
  // -------------------------

  await firestore.collection('teachers').doc('pierre').set({
    'firstName': 'Pierre',
    'lastName': 'Dupont',
    'email': 'pierre@courtmanager.fr',
    'role': 'teacher',
    'isActive': true,
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
    'createdBy': 'seed',
    'updatedBy': 'seed',
  });


  await firestore.collection('teachers').doc('marie').set({
    'firstName': 'Marie',
    'lastName': 'Martin',
    'email': 'marie@courtmanager.fr',
    'role': 'teacher',
    'isActive': true,
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
    'createdBy': 'seed',
    'updatedBy': 'seed',
  });


  // -------------------------
  // MEMBERS
  // -------------------------

  final members = [
    {
      'id': 'member-001',
      'firstName': 'Jean',
      'lastName': 'Durand',
      'licenseNumber': 'LIC001',
    },
    {
      'id': 'member-002',
      'firstName': 'Sophie',
      'lastName': 'Bernard',
      'licenseNumber': 'LIC002',
    },
    {
      'id': 'member-003',
      'firstName': 'Alain',
      'lastName': 'Moreau',
      'licenseNumber': 'LIC003',
    },
    {
      'id': 'member-004',
      'firstName': 'Claire',
      'lastName': 'Petit',
      'licenseNumber': 'LIC004',
    },
  ];


  for (final member in members) {
    await firestore
        .collection('members')
        .doc(member['id'] as String)
        .set({
          'licenseNumber': member['licenseNumber'],
          'firstName': member['firstName'],
          'lastName': member['lastName'],
          'birthDate': null,
          'email': null,
          'phone': null,
          'isActive': true,
          'notes': null,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'createdBy': 'seed',
          'updatedBy': 'seed',
        });
  }


  // -------------------------
  // GROUPS
  // -------------------------

  await firestore.collection('groups').doc('adultes-debutants').set({
    'name': 'Adultes débutants',
    'type': 'adultLeisure',
    'seasonId': '2026-2027',
    'dayOfWeek': 2,
    'startTime': '18:00',
    'durationMinutes': 60,
    'teacherIds': ['pierre'],
    'isActive': true,
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
    'createdBy': 'seed',
    'updatedBy': 'seed',
  });


  await firestore.collection('groups').doc('adultes-loisirs').set({
    'name': 'Adultes loisirs',
    'type': 'adultLeisure',
    'seasonId': '2026-2027',
    'dayOfWeek': 4,
    'startTime': '19:00',
    'durationMinutes': 90,
    'teacherIds': ['marie'],
    'isActive': true,
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
    'createdBy': 'seed',
    'updatedBy': 'seed',
  });


  // -------------------------
  // ENROLLMENTS
  // -------------------------

  await firestore.collection('enrollments').doc('enrollment-001').set({
    'memberId': 'member-001',
    'groupId': 'adultes-debutants',
    'seasonId': '2026-2027',
    'startDate': Timestamp.fromDate(now),
    'endDate': null,
    'isActive': true,
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
    'createdBy': 'seed',
    'updatedBy': 'seed',
  });


  await firestore.collection('enrollments').doc('enrollment-002').set({
    'memberId': 'member-002',
    'groupId': 'adultes-debutants',
    'seasonId': '2026-2027',
    'startDate': Timestamp.fromDate(now),
    'endDate': null,
    'isActive': true,
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
    'createdBy': 'seed',
    'updatedBy': 'seed',
  });


  // -------------------------
  // SESSIONS
  // -------------------------

  await firestore.collection('sessions').doc('session-001').set({
    'groupId': 'adultes-debutants',
    'date': Timestamp.fromDate(
      now.add(const Duration(days: 1)),
    ),
    'startTime': '18:00',
    'durationMinutes': 60,
    'teacherIds': ['pierre'],
    'status': 'planned',
    'cancellationReason': null,
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
    'createdBy': 'seed',
    'updatedBy': 'seed',
  });

}