import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/models/app_user.dart';
import '../data/teacher_repository.dart';

class TeacherFormScreen extends StatefulWidget {
  final AppUser teacher;

  const TeacherFormScreen({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherFormScreen> createState() =>
      _TeacherFormScreenState();
}

class _TeacherFormScreenState
    extends State<TeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _lastNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _emailController;

  late bool _active;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _lastNameController =
        TextEditingController(
      text: widget.teacher.lastName,
    );

    _firstNameController =
        TextEditingController(
      text: widget.teacher.firstName,
    );

    _emailController =
        TextEditingController(
      text: widget.teacher.email,
    );

    _active = widget.teacher.active;
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Utilisateur non connecté',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final repository =
          TeacherRepository();

      await repository.updateTeacher(
        uid: widget.teacher.uid,
        firstName:
            _firstNameController.text,
        lastName:
            _lastNameController.text,
        email:
            _emailController.text,
        active:
            _active,
        updatedBy:
            currentUser.uid,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l\'enregistrement : $error',
          ),
        ),
      );

      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier le professeur',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _lastNameController,
              textCapitalization:
                  TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Le nom est obligatoire';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _firstNameController,
              textCapitalization:
                  TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Prénom *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Le prénom est obligatoire';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'L\'e-mail est obligatoire';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,
              title: const Text(
                'Professeur actif',
              ),
              subtitle: Text(
                _active
                    ? 'Le professeur est actif'
                    : 'Le professeur est inactif',
              ),
              value: _active,
              onChanged: (value) {
                setState(() {
                  _active = value;
                });
              },
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saving
                  ? null
                  : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Enregistrer les modifications',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}