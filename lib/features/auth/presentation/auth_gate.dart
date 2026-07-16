import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/user_repository.dart';
import '../models/app_user.dart';

import 'login_page.dart';
import '../../dashboard/presentation/dashboard_screen.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});


  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, authSnapshot) {


        if (authSnapshot.connectionState ==
            ConnectionState.waiting) {

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }


        if (!authSnapshot.hasData) {
          return const LoginPage();
        }


        return FutureBuilder<AppUser?>(
          future: UserRepository()
              .getUser(authSnapshot.data!.uid),

          builder: (context, userSnapshot) {


            if (userSnapshot.connectionState ==
                ConnectionState.waiting) {

              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }


            final user = userSnapshot.data;


            if (user == null) {

              return const Scaffold(
                body: Center(
                  child: Text(
                    "Profil utilisateur introuvable",
                  ),
                ),
              );

            }


            return DashboardScreen(
              user: user,
            );
          },
        );
      },
    );
  }
}