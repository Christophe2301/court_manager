import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';

const String _teacherId = 'vLOZ73vvsLXbCaiGkXgPVJpxsTj2';

Future<void> seedFirestore() async {
  final firestore = FirebaseFirestore.instance;

  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    throw Exception(
      'Aucun utilisateur Firebase connecté.',
    );
  }

  final now = DateTime.now();

  final batch = firestore.batch();

  // ============================================================
  // 1. ADHERENTS
  // ============================================================

  final members = [
    ['01', 'Jean', 'Martin'],
    ['02', 'Pierre', 'Durand'],
    ['03', 'Michel', 'Bernard'],
    ['04', 'Philippe', 'Robert'],
    ['05', 'Laurent', 'Petit'],
    ['06', 'Nicolas', 'Thomas'],
    ['07', 'Christophe', 'Richard'],
    ['08', 'Olivier', 'Dubois'],
    ['09', 'Sébastien', 'Moreau'],
    ['10', 'François', 'Laurent'],
    ['11', 'Thomas', 'Simon'],
    ['12', 'Julien', 'Michel'],
    ['13', 'Antoine', 'Lefèvre'],
    ['14', 'David', 'Leroy'],
    ['15', 'Alexandre', 'Roux'],
    ['16', 'Sophie', 'Fournier'],
    ['17', 'Isabelle', 'Girard'],
    ['18', 'Valérie', 'Bonnet'],
    ['19', 'Catherine', 'Dupont'],
    ['20', 'Anne', 'Lambert'],
    ['21', 'Claire', 'Fontaine'],
    ['22', 'Julie', 'Chevalier'],
    ['23', 'Émilie', 'Robin'],
    ['24', 'Marie', 'Masson'],
    ['25', 'Nathalie', 'Garnier'],
  ];

  for (final member in members) {
    final id = 'test-member-${member[0]}';

    final ref = firestore
        .collection('members')
        .doc(id);

    batch.set(ref, {
      'licenseNumber': 'TEST${member[0]}',
      'firstName': member[1],
      'lastName': member[2],
      'birthDate': null,
      'email': 'test${member[0]}@courtmanager.test',
      'phone': null,
      'isActive': true,
      'notes': 'Donnée de test CourtManager',
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'createdBy': currentUser.uid,
      'updatedBy': currentUser.uid,
    });
  }

  // ============================================================
  // 2. GROUPES
  // ============================================================

  final groups = [
    {
      'id': 'test-group-adultes-debutants',
      'name': 'TEST Adultes débutants',
      'type': 'course',
      'dayOfWeek': 2,
      'startTime': '18:00',
      'durationMinutes': 60,
    },
    {
      'id': 'test-group-adultes-loisirs',
      'name': 'TEST Adultes loisirs',
      'type': 'adultLeisure',
      'dayOfWeek': 2,
      'startTime': '19:00',
      'durationMinutes': 60,
    },
    {
      'id': 'test-group-adultes-loisirs-2',
      'name': 'TEST Adultes loisirs 2',
      'type': 'adultLeisure',
      'dayOfWeek': 4,
      'startTime': '18:00',
      'durationMinutes': 90,
    },
    {
      'id': 'test-group-jeunes-10-12',
      'name': 'TEST Jeunes 10/12 ans',
      'type': 'tennisSchool',
      'dayOfWeek': 3,
      'startTime': '14:00',
      'durationMinutes': 60,
    },
    {
      'id': 'test-group-competition',
      'name': 'TEST Compétition',
      'type': 'competition',
      'dayOfWeek': 6,
      'startTime': '10:00',
      'durationMinutes': 90,
    },
  ];

  for (final group in groups) {
    final ref = firestore
        .collection('groups')
        .doc(group['id'] as String);

    batch.set(ref, {
      'name': group['name'],
      'type': group['type'],
      'seasonId': currentSeasonId,
      'dayOfWeek': group['dayOfWeek'],
      'startTime': group['startTime'],
      'durationMinutes':
          group['durationMinutes'],
      'teacherIds': [_teacherId],
      'isActive': true,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'createdBy': currentUser.uid,
      'updatedBy': currentUser.uid,
    });
  }

  // ============================================================
  // 3. INSCRIPTIONS
  // ============================================================

  final enrollments = <Map<String, String>>[];

  void addEnrollments({
    required String groupId,
    required int firstMember,
    required int count,
  }) {
    for (var i = 0; i < count; i++) {
      final memberNumber =
          (firstMember + i).toString().padLeft(2, '0');

      enrollments.add({
        'id':
            'test-enrollment-$groupId-$memberNumber',
        'memberId':
            'test-member-$memberNumber',
        'groupId': groupId,
      });
    }
  }

  addEnrollments(
    groupId: 'test-group-adultes-debutants',
    firstMember: 1,
    count: 8,
  );

  addEnrollments(
    groupId: 'test-group-adultes-loisirs',
    firstMember: 7,
    count: 10,
  );

  addEnrollments(
    groupId: 'test-group-adultes-loisirs-2',
    firstMember: 15,
    count: 8,
  );

  addEnrollments(
    groupId: 'test-group-jeunes-10-12',
    firstMember: 20,
    count: 6,
  );

  addEnrollments(
    groupId: 'test-group-competition',
    firstMember: 5,
    count: 7,
  );

  for (final enrollment in enrollments) {
    final ref = firestore
        .collection('enrollments')
        .doc(enrollment['id']);

    batch.set(ref, {
      'memberId': enrollment['memberId'],
      'groupId': enrollment['groupId'],
      'seasonId': currentSeasonId,
      'startDate': Timestamp.fromDate(
        DateTime(2026, 9, 1),
      ),
      'endDate': null,
      'isActive': true,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'createdBy': currentUser.uid,
      'updatedBy': currentUser.uid,
    });
  }

  // ============================================================
  // 4. SEANCES
  // ============================================================

  final sessions = <Map<String, dynamic>>[];

  void addSessions({
    required String groupId,
    required List<int> months,
    required int day,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
  }) {
    for (final month in months) {
      final dates = _datesForWeekday(
        2026,
        month,
        day,
      );

      for (final date in dates) {
        if (date.isBefore(
          DateTime(2026, 9, 8),
        )) {
          continue;
        }

        final dateId =
            '${date.year}'
            '${date.month.toString().padLeft(2, '0')}'
            '${date.day.toString().padLeft(2, '0')}';

        final sessionId =
            'test-session-$groupId-$dateId';

        sessions.add({
          'id': sessionId,
          'groupId': groupId,
          'date': date,
          'startTime':
              '${startHour.toString().padLeft(2, '0')}:'
              '${startMinute.toString().padLeft(2, '0')}',
          'durationMinutes': durationMinutes,
        });
      }
    }
  }

  // Septembre + octobre 2026.
  addSessions(
    groupId: 'test-group-adultes-debutants',
    months: [9, 10],
    day: 2,
    startHour: 18,
    startMinute: 0,
    durationMinutes: 60,
  );

  addSessions(
    groupId: 'test-group-adultes-loisirs',
    months: [9, 10],
    day: 2,
    startHour: 19,
    startMinute: 0,
    durationMinutes: 60,
  );

  addSessions(
    groupId: 'test-group-adultes-loisirs-2',
    months: [9, 10],
    day: 4,
    startHour: 18,
    startMinute: 0,
    durationMinutes: 90,
  );

  addSessions(
    groupId: 'test-group-jeunes-10-12',
    months: [9, 10],
    day: 3,
    startHour: 14,
    startMinute: 0,
    durationMinutes: 60,
  );

  addSessions(
    groupId: 'test-group-competition',
    months: [9, 10],
    day: 6,
    startHour: 10,
    startMinute: 0,
    durationMinutes: 90,
  );

  for (final session in sessions) {
    final ref = firestore
        .collection('sessions')
        .doc(session['id']);

    batch.set(ref, {
      'groupId': session['groupId'],
      'teacherIds': [_teacherId],
      'date': Timestamp.fromDate(
        session['date'] as DateTime,
      ),
      'startTime': session['startTime'],
      'durationMinutes':
          session['durationMinutes'],
      'status': 'planned',
    });
  }

  // ============================================================
  // 5. ECRITURE FIRESTORE
  // ============================================================

  await batch.commit();

}


// Retourne toutes les dates d'un mois correspondant
// au jour de la semaine demandé.
// Lundi = 1 ... Dimanche = 7.
List<DateTime> _datesForWeekday(
  int year,
  int month,
  int weekday,
) {
  final result = <DateTime>[];

  final daysInMonth =
      DateTime(year, month + 1, 0).day;

  for (var day = 1;
      day <= daysInMonth;
      day++) {
    final date =
        DateTime(year, month, day);

    if (date.weekday == weekday) {
      result.add(date);
    }
  }

  return result;
}