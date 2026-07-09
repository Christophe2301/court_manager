import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;


  Future<AppUser?> getUser(String uid) async {

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
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] == 'admin'
          ? AppUserRole.admin
          : AppUserRole.teacher,
      active: data['active'] ?? true,
    );
  }
}