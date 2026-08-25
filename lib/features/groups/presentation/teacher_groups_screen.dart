import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/group_provider.dart';
import 'group_detail_screen.dart';

class TeacherGroupsScreen
    extends ConsumerWidget {
  final String teacherId;

  const TeacherGroupsScreen({
    super.key,
    required this.teacherId,
  });

  String _dayLabel(int day) {
    switch (day) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return 'Jour inconnu';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(
      teacherGroupsProvider(teacherId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes groupes',
        ),
      ),
      body: groupsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Erreur : $error',
          ),
        ),
        data: (groups) {
          final activeGroups = groups
              .where(
                (group) => group.isActive,
              )
              .toList();

          activeGroups.sort((a, b) {
            final dayComparison =
                a.dayOfWeek.compareTo(
              b.dayOfWeek,
            );

            if (dayComparison != 0) {
              return dayComparison;
            }

            return a.startTime.compareTo(
              b.startTime,
            );
          });

          if (activeGroups.isEmpty) {
            return const Center(
              child: Text(
                'Aucun groupe affecté.',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount:
                activeGroups.length,
            itemBuilder:
                (context, index) {
              final group =
                  activeGroups[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.groups,
                    ),
                  ),
                  title: Text(
                    group.name,
                  ),
                  subtitle: Text(
                    '${_dayLabel(group.dayOfWeek)} '
                    'à ${group.startTime} '
                    '• ${group.durationMinutes} min',
                  ),
                  trailing:
                      const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GroupDetailScreen(
                          group: group,
                          teacherMode: true,
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