import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/app_user.dart';
import '../providers/teacher_provider.dart';
import 'teacher_detail_screen.dart';

class TeachersScreen extends ConsumerStatefulWidget {
  const TeachersScreen({
    super.key,
  });

  @override
  ConsumerState<TeachersScreen> createState() =>
      _TeachersScreenState();
}

class _TeachersScreenState
    extends ConsumerState<TeachersScreen> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final teachers = _showInactive
        ? ref.watch(inactiveTeachersProvider)
        : ref.watch(activeTeachersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showInactive
              ? 'Professeurs inactifs'
              : 'Professeurs',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showInactive
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            tooltip: _showInactive
                ? 'Afficher les actifs'
                : 'Afficher les inactifs',
            onPressed: () {
              setState(() {
                _showInactive = !_showInactive;
              });
            },
          ),
        ],
      ),
      body: teachers.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Erreur : $error',
            ),
          ),
        ),

        data: (teachers) {
          if (teachers.isEmpty) {
            return Center(
              child: Text(
                _showInactive
                    ? 'Aucun professeur inactif'
                    : 'Aucun professeur actif',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final AppUser teacher =
                  teachers[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      teacher.active
                          ? Icons.person
                          : Icons.person_off,
                    ),
                  ),
                  title: Text(
                    teacher.fullName,
                  ),
                  subtitle: Text(
                    teacher.email,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TeacherDetailScreen(
                          teacher: teacher,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}