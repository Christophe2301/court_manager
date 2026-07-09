import 'package:flutter/material.dart';

import '../data/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();

  bool _loading = false;
  String? _error;


  Future<void> _login() async {

    setState(() {
      _loading = true;
      _error = null;
    });


    try {

      final user = await _authRepository.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );


      if (user == null) {
        setState(() {
          _error = "Utilisateur inconnu";
        });
      }

      else {

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
        );

      }

    }

    catch (e) {

      setState(() {
        _error = "Erreur de connexion";
      });

    }


    finally {

      setState(() {
        _loading = false;
      });

    }

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(
              "CourtManager",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(height: 40),


            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),


            const SizedBox(height: 16),


            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mot de passe",
              ),
            ),


            const SizedBox(height: 24),


            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),


            const SizedBox(height: 16),


            ElevatedButton(

              onPressed: _loading ? null : _login,

              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Se connecter"),

            ),

          ],

        ),

      ),

    );

  }
}