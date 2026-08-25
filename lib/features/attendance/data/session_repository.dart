import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/session_model.dart';

class SessionRepository {
  final FirebaseFirestore _firestore;

  SessionRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;


  Future<String> createSession(SessionModel session) async {
    final doc = await _firestore
        .collection('sessions')
        .add(session.toFirestore());

    return doc.id;
  }

Future<void> updateSession(
  SessionModel session,
) async {
  await _firestore
      .collection('sessions')
      .doc(session.id)
      .update(
        session.toFirestore(),
      );
}

Future<List<SessionModel>> getAllSessions() async {
  final snapshot = await _firestore
      .collection('sessions')
      .orderBy('date')
      .get();

  return snapshot.docs
      .map(
        (doc) => SessionModel.fromFirestore(
          doc.data(),
          doc.id,
        ),
      )
      .toList();
}

Future<List<SessionModel>> getSessionsByTeacher(
    String teacherId) async {
  final snapshot = await _firestore
      .collection('sessions')
      .where(
        'teacherIds',
        arrayContains: teacherId,
      )
      .orderBy('date')
      .get();

  return snapshot.docs
      .map(
        (doc) => SessionModel.fromFirestore(
          doc.data(),
          doc.id,
        ),
      )
      .toList();
}

Future<List<SessionModel>> getSessionsByGroup(
    String groupId) async {

  final snapshot = await _firestore
      .collection('sessions')
      .where(
        'groupId',
        isEqualTo: groupId,
      )
      .orderBy('date')
      .get();

  return snapshot.docs
      .map(
        (doc) => SessionModel.fromFirestore(
          doc.data(),
          doc.id,
        ),
      )
      .toList();
}

Future<void> deleteSession(String sessionId) async {
  final attendanceSnapshot = await _firestore
      .collection('attendance')
      .where(
        'sessionId',
        isEqualTo: sessionId,
      )
      .limit(1)
      .get();

  if (attendanceSnapshot.docs.isNotEmpty) {
    throw StateError(
      'Impossible de supprimer une séance '
      'pour laquelle un appel a été enregistré.',
    );
  }

  await _firestore
      .collection('sessions')
      .doc(sessionId)
      .delete();
}

}