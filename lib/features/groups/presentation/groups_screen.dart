import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/group.dart';
import '../providers/group_provider.dart';
import 'group_detail_screen.dart';
import 'group_form_screen.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({
    super.key,
  });

  @override
  ConsumerState<GroupsScreen> createState() =>
      _GroupsScreenState();
}

class _GroupsScreenState
    extends ConsumerState<GroupsScreen> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final groups = _showInactive
        ? ref.watch(inactiveGroupsProvider)
        : ref.watch(activeGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showInactive
              ? 'Groupes inactifs'
              : 'Groupes',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showInactive
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            tooltip: _showInactive
                ? 'Afficher les groupes actifs'
                : 'Afficher les groupes inactifs',
            onPressed: () {
              setState(() {
                _showInactive = !_showInactive;
              });
            },
          ),
          if (!_showInactive)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Nouveau groupe',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const GroupFormScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: groups.when(
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
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Text(
                _showInactive
                    ? 'Aucun groupe inactif'
                    : 'Aucun groupe actif',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final Group group = groups[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      _showInactive
                          ? Icons.block
                          : Icons.groups,
                    ),
                  ),
                  title: Text(
                    group.name,
                  ),
                  subtitle: Text(
                    '${group.startTime} • '
                    '${group.durationMinutes} min',
                  ),
                  trailing: const Icon(
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
      ),
    );
  }
}