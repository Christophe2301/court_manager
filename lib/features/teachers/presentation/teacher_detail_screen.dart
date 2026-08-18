import 'package:flutter/material.dart';

import '../../auth/models/app_user.dart';
import '../data/teacher_repository.dart';
import 'teacher_form_screen.dart';

class TeacherDetailScreen extends StatefulWidget {
  final AppUser teacher;

  const TeacherDetailScreen({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherDetailScreen> createState() =>
      _TeacherDetailScreenState();
}

class _TeacherDetailScreenState
    extends State<TeacherDetailScreen> {
  late AppUser _teacher;

  @override
  void initState() {
    super.initState();

    _teacher = widget.teacher;
  }

  Future<void> _editTeacher() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherFormScreen(
          teacher: _teacher,
        ),
      ),
    );

    if (updated != true) {
      return;
    }

    final repository = TeacherRepository();

    final refreshed =
        await repository.getTeacher(
      _teacher.uid,
    );

    if (refreshed == null || !mounted) {
      return;
    }

    setState(() {
      _teacher = refreshed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: const Text(
    'Fiche professeur',
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.edit),
      tooltip: 'Modifier',
      onPressed: _editTeacher,
    ),
    PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'deactivate') {
          // Désactivation à ajouter à l'étape suivante.
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'deactivate',
          child: Text(
            'Désactiver le professeur',
          ),
        ),
      ],
    ),
  ],
),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoSection(
            title: 'Identité',
            children: [
              _InfoRow(
                label: 'Nom',
                value: _teacher.lastName,
              ),
              _InfoRow(
                label: 'Prénom',
                value: _teacher.firstName,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _InfoSection(
            title: 'Coordonnées',
            children: [
              _InfoRow(
                label: 'E-mail',
                value: _teacher.email,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _InfoSection(
            title: 'Gestion',
            children: [
              _InfoRow(
                label: 'Rôle',
                value: _teacher.isAdmin
                    ? 'Administrateur'
                    : 'Professeur',
              ),
              _InfoRow(
                label: 'Statut',
                value: _teacher.active
                    ? 'Actif'
                    : 'Inactif',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}