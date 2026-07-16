import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/app_user.dart';

import '../../groups/presentation/group_detail_screen.dart';
import '../../groups/providers/group_provider.dart';
import '../../attendance/presentation/sessions_page.dart';

class DashboardScreen extends ConsumerWidget {
  final AppUser user;

  const DashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final groups = ref.watch(activeGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CourtManager 🎾'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

Text(
  'Bonjour ${user.firstName} ${user.lastName}',
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.calendar_month),
    label: const Text('Mes séances'),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SessionsPage(
            teacherId: user.uid,
          ),
        ),
      );
    },
  ),
),

const SizedBox(height: 20),

const Text(
  "Aujourd'hui",
  style: TextStyle(
    fontSize: 18,
  ),
),

const SizedBox(height: 10),
            const SizedBox(height: 10),

            Expanded(
              child: groups.when(
                data: (groups) {

                  if (groups.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucun groupe prévu aujourd’hui',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {

                      final group = groups[index];

                      return Card(
                        child: ListTile(
                          title: Text(
                            group.name,
                          ),
                          subtitle: Text(
                            '${group.startTime} - ${group.durationMinutes} min',
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
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },

                loading: () =>
                    const Center(
                  child:
                      CircularProgressIndicator(),
                ),

                error: (error, stack) =>
                    Center(
                  child: Text(
                    'Erreur : $error',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}