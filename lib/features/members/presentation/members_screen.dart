import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/member_provider.dart';
import 'member_form_screen.dart';
import 'member_detail_screen.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({
    super.key,
  });

  @override
  ConsumerState<MembersScreen> createState() =>
      _MembersScreenState();
}

class _MembersScreenState
    extends ConsumerState<MembersScreen> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final members = _showInactive
        ? ref.watch(inactiveMembersProvider)
        : ref.watch(activeMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showInactive
              ? 'Adhérents inactifs'
              : 'Adhérents',
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
      body: members.when(
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
        data: (members) {
          if (members.isEmpty) {
            return Center(
              child: Text(
                _showInactive
                    ? 'Aucun adhérent inactif'
                    : 'Aucun adhérent actif',
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
                  leading: CircleAvatar(
                    child: Icon(
                      member.isActive
                          ? Icons.person
                          : Icons.person_off,
                    ),
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
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MemberDetailScreen(
                          member: member,
                        ),
                      ),
                    );

                    if (!context.mounted) {
                      return;
                    }

                    ref.invalidate(
                      _showInactive
                          ? inactiveMembersProvider
                          : activeMembersProvider,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _showInactive
          ? null
          : FloatingActionButton.extended(
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