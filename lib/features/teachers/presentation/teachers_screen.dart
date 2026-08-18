import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/app_user.dart';
import '../providers/teacher_provider.dart';
import 'teacher_detail_screen.dart';

class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final teachers =
        ref.watch(activeTeachersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professeurs'),
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
            return const Center(
              child: Text(
                'Aucun professeur actif',
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
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
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
                  onTap: () {
                    Navigator.push(
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