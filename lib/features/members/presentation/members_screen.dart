import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/member_provider.dart';
import 'member_form_screen.dart';
import 'member_detail_screen.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final members = ref.watch(activeMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adhérents'),
      ),
      body: members.when(
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
                'Aucun adhérent actif',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
    trailing: const Icon(
      Icons.chevron_right,
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MemberDetailScreen(
            member: member,
          ),
        ),
      );
    },
  ),
);            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const MemberFormScreen(),
      ),
    );
  },
  icon: const Icon(Icons.person_add),
  label: const Text('Nouvel adhérent'),
),
    );
  }
}