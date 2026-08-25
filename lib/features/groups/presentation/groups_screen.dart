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

  String _dayLabel(int dayOfWeek) {
    switch (dayOfWeek) {
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

  List<Group> _sortGroups(
    List<Group> groups,
  ) {
    final sorted = [...groups];

    sorted.sort((a, b) {
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

    return sorted;
  }

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
                _showInactive =
                    !_showInactive;
              });
            },
          ),
          if (!_showInactive)
            IconButton(
              icon: const Icon(
                Icons.add,
              ),
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

          final sortedGroups =
              _sortGroups(groups);

          final widgets = <Widget>[];

          int? previousDay;

          for (final group in sortedGroups) {
            if (previousDay !=
                group.dayOfWeek) {
              if (widgets.isNotEmpty) {
                widgets.add(
                  const SizedBox(
                    height: 12,
                  ),
                );
              }

              widgets.add(
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    4,
                    8,
                    4,
                    6,
                  ),
                  child: Text(
                    _dayLabel(
                      group.dayOfWeek,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),
              );

              previousDay =
                  group.dayOfWeek;
            }

            widgets.add(
              Card(
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
              ),
            );
          }

          return ListView(
            padding:
                const EdgeInsets.all(16),
            children: widgets,
          );
        },
      ),
    );
  }
}