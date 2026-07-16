import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/group.dart';
import '../../members/providers/member_provider.dart';


class GroupDetailScreen extends ConsumerWidget {
  final Group group;

  const GroupDetailScreen({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              group.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Horaire : ${group.startTime}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            Text(
              'Durée : ${group.durationMinutes} minutes',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Adhérents inscrits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

           Expanded(
  child: ref.watch(
    groupMembersProvider(group.id),
  ).when(
    loading: () => const Center(
      child: CircularProgressIndicator(),
    ),

    error: (error, stack) => Center(
      child: Text(
        'Erreur : $error',
      ),
    ),

    data: (members) {

      if (members.isEmpty) {
        return const Center(
          child: Text(
            'Aucun adhérent inscrit',
          ),
        );
      }


      return ListView.builder(
        itemCount: members.length,

        itemBuilder: (context, index) {

          final member = members[index];

          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.person,
              ),

              title: Text(
                member.fullName,
              ),

              subtitle: Text(
                member.licenseNumber,
              ),
            ),
          );
        },
      );
    },
  ),
),
          ],
        ),
      ),
    );
  }
}