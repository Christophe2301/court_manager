import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;


  Future<AppUser?> signIn(
    String email,
    String password,
  ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      return null;
    }

    return _loadUser(firebaseUser.uid);
  }


  Future<AppUser?> _loadUser(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data()!;

    return AppUser(
      uid: uid,
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      role: data['role'] == 'admin'
          ? AppUserRole.admin
          : AppUserRole.teacher,
      active: data['active'] ?? true,
    );
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }
}