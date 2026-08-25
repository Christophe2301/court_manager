import 'package:flutter/material.dart';

import '../../../core/models/group.dart';
import '../../../core/models/session_model.dart';
import '../../attendance/data/session_repository.dart';
import '../../attendance/presentation/attendance_screen.dart';
import '../../attendance/presentation/session_edit_screen.dart';
import '../../attendance/presentation/session_form_screen.dart';
import '../../groups/data/group_repository.dart';
import '../../auth/models/app_user.dart';
import '../../teachers/data/teacher_repository.dart';

enum _SessionPeriodFilter {
  upcoming,
  past,
  all,
}

class AdminSessionsScreen extends StatefulWidget {
  const AdminSessionsScreen({
    super.key,
  });

  @override
  State<AdminSessionsScreen> createState() =>
      _AdminSessionsScreenState();
}

class _AdminSessionsScreenState
    extends State<AdminSessionsScreen> {
  final SessionRepository _sessionRepository =
      SessionRepository();

  final GroupRepository _groupRepository =
      GroupRepository();

final TeacherRepository _teacherRepository =
    TeacherRepository();

late Future<List<AppUser>> _teachersFuture;

_SessionPeriodFilter _periodFilter =
    _SessionPeriodFilter.upcoming;

String? _selectedGroupId;
String? _selectedTeacherId;

  late Future<List<SessionModel>> _sessionsFuture;
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
  _sessionsFuture =
      _sessionRepository.getAllSessions();

  _groupsFuture =
      _groupRepository.watchActiveGroups().first;

  _teachersFuture =
      _teacherRepository.watchActiveTeachers().first;
}

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });

    await _sessionsFuture;
  }

  Future<void> _createSession() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SessionFormScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (created == true) {
      await _refresh();
    }
  }

  Future<void> _editSession(
    SessionModel session,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SessionEditScreen(
          session: session,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _refresh();
  }

  void _openAttendance(
    SessionModel session,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AttendanceScreen(
          session: session,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

DateTime _dateOnly(DateTime date) {
  return DateTime(
    date.year,
    date.month,
    date.day,
  );
}

bool _matchesPeriod(
  SessionModel session,
) {
  final today =
      _dateOnly(DateTime.now());

  final sessionDate =
      _dateOnly(session.date);

  switch (_periodFilter) {
    case _SessionPeriodFilter.upcoming:
      return !sessionDate.isBefore(today);

    case _SessionPeriodFilter.past:
      return sessionDate.isBefore(today);

    case _SessionPeriodFilter.all:
      return true;
  }
}

List<SessionModel> _filterSessions(
  List<SessionModel> sessions,
) {
  return sessions.where((session) {
    if (!_matchesPeriod(session)) {
      return false;
    }

    if (_selectedGroupId != null &&
        session.groupId !=
            _selectedGroupId) {
      return false;
    }

    if (_selectedTeacherId != null &&
        !session.teacherIds.contains(
          _selectedTeacherId,
        )) {
      return false;
    }

    return true;
  }).toList();
}

  String _formatStatus(String status) {
    switch (status) {
      case 'planned':
        return 'Prévue';

      case 'completed':
        return 'Terminée';

      case 'cancelled':
        return 'Annulée';

      default:
        return status;
    }
  }

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'planned':
        return Colors.blue;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  Widget _buildSessionCard(
    BuildContext context,
    SessionModel session,
    Map<String, Group> groupsById,
  ) {
    final group =
        groupsById[session.groupId];

    final groupName =
        group?.name ?? session.groupId;

    final statusColor =
        _statusColor(session.status);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Text(
            session.date.day
                .toString()
                .padLeft(2, '0'),
          ),
        ),
        title: Text(
          groupName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text(
  '${session.startTime} '
  '• ${session.durationMinutes} min',
),

            const SizedBox(height: 6),

            Text(
              _formatStatus(
                session.status,
              ),
              style: TextStyle(
                color: statusColor,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing:
            PopupMenuButton<String>(
          tooltip: 'Actions',
          onSelected: (value) async {
            switch (value) {
              case 'attendance':
                _openAttendance(
                  session,
                );
                break;

              case 'edit':
                await _editSession(
                  session,
                );
                break;

                case 'delete':
  await _deleteSession(
    session,
  );
  break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'attendance',
              child: Row(
                children: [
                  Icon(
                    Icons.fact_check_outlined,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Feuille de présence',
                  ),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Modifier la séance',
                  ),
                ],
              ),
            ),
            const PopupMenuItem<String>(
  value: 'delete',
  child: Row(
    children: [
      Icon(
        Icons.delete_outline,
      ),
      SizedBox(width: 10),
      Text(
        'Supprimer la séance',
      ),
    ],
  ),
),
          ],
        ),
        onTap: () {
          _openAttendance(
            session,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Séances',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
            ),
            tooltip:
                'Créer une séance',
            onPressed: _createSession,
          ),
        ],
      ),
      body:
          FutureBuilder<List<SessionModel>>(
        future: _sessionsFuture,
        builder: (
          context,
          sessionSnapshot,
        ) {
          if (sessionSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (sessionSnapshot.hasError) {
            return Center(
              child: Text(
                'Erreur : '
                '${sessionSnapshot.error}',
              ),
            );
          }

          final sessions =
              sessionSnapshot.data ?? [];

          if (sessions.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 160),
                  Center(
                    child: Text(
                      'Aucune séance',
                    ),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<List<Group>>(
            future: _groupsFuture,
            builder: (
              context,
              groupSnapshot,
            ) {
              if (groupSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              if (groupSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur lors du chargement '
                    'des groupes : '
                    '${groupSnapshot.error}',
                  ),
                );
              }

              final groups =
                  groupSnapshot.data ?? [];

              final groupsById = {
                for (final group in groups)
                  group.id: group,
              };

return FutureBuilder<List<AppUser>>(
  future: _teachersFuture,
  builder: (
    context,
    teacherSnapshot,
  ) {
    if (teacherSnapshot.connectionState ==
        ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (teacherSnapshot.hasError) {
      return Center(
        child: Text(
          'Erreur lors du chargement '
          'des professeurs : '
          '${teacherSnapshot.error}',
        ),
      );
    }

    final teachers =
        teacherSnapshot.data ?? [];

    final filteredSessions =
        _filterSessions(sessions);

    final sortedSessions =
    [...filteredSessions];

final today =
    _dateOnly(DateTime.now());

int category(
  SessionModel session,
) {
  final sessionDate =
      _dateOnly(session.date);

  if (sessionDate == today) {
    return 0;
  }

  if (sessionDate.isAfter(today)) {
    return 1;
  }

  return 2;
}

sortedSessions.sort((a, b) {
  final categoryA = category(a);
  final categoryB = category(b);

  if (categoryA != categoryB) {
    return categoryA.compareTo(
      categoryB,
    );
  }

  final dateA =
      _dateOnly(a.date);

  final dateB =
      _dateOnly(b.date);

  if (categoryA == 2) {
    final comparison =
        dateB.compareTo(dateA);

    if (comparison != 0) {
      return comparison;
    }
  } else {
    final comparison =
        dateA.compareTo(dateB);

    if (comparison != 0) {
      return comparison;
    }
  }

  return a.startTime.compareTo(
    b.startTime,
  );
});

final widgets = <Widget>[];

DateTime? previousDate;

for (final session in sortedSessions) {
  final currentDate =
      _dateOnly(session.date);

  if (previousDate == null ||
      currentDate != previousDate) {
    if (widgets.isNotEmpty) {
      widgets.add(
        const SizedBox(height: 12),
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
          _formatDate(session.date),
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

    previousDate = currentDate;
  }

  widgets.add(
    _buildSessionCard(
      context,
      session,
      groupsById,
    ),
  );
}

return Column(
  children: [
    Padding(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        4,
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 190,
            child:
                DropdownButtonFormField<
                    _SessionPeriodFilter>(
                      isExpanded: true,
              initialValue:
                  _periodFilter,
              decoration:
                  const InputDecoration(
                labelText: 'Période',
                border:
                    OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value:
                      _SessionPeriodFilter
                          .upcoming,
                  child: Text(
                    'À venir',
                  ),
                ),
                DropdownMenuItem(
                  value:
                      _SessionPeriodFilter
                          .past,
                  child: Text(
                    'Passées',
                  ),
                ),
                DropdownMenuItem(
                  value:
                      _SessionPeriodFilter
                          .all,
                  child: Text(
                    'Toutes',
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _periodFilter =
                      value;
                });
              },
            ),
          ),

          SizedBox(
            width: 260,
            child:
                DropdownButtonFormField<
                    String?>(
                      isExpanded: true,
              initialValue:
                  _selectedGroupId,
              decoration:
                  const InputDecoration(
                labelText: 'Groupe',
                border:
                    OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<
                    String?>(
                  value: null,
                  child: Text(
                    'Tous les groupes',
                  ),
                ),
                ...groups.map(
                  (group) =>
                      DropdownMenuItem<
                          String?>(
                    value: group.id,
                    child: Text(
                      group.name,
                      overflow:
                          TextOverflow
                              .ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGroupId =
                      value;
                });
              },
            ),
          ),

          SizedBox(
            width: 220,
            child:
                DropdownButtonFormField<
                    String?>(
                      isExpanded: true,
              initialValue:
                  _selectedTeacherId,
              decoration:
                  const InputDecoration(
                labelText: 'Professeur',
                border:
                    OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<
                    String?>(
                  value: null,
                  child: Text(
                    'Tous les professeurs',
                  ),
                ),
                ...teachers.map(
                  (teacher) =>
                      DropdownMenuItem<
                          String?>(
                    value:
                        teacher.uid,
                    child: Text(
                      '${teacher.firstName} '
                      '${teacher.lastName}',
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTeacherId =
                      value;
                });
              },
            ),
          ),
        ],
      ),
    ),

    const SizedBox(height: 4),

    Expanded(
      child: sortedSessions.isEmpty
          ? const Center(
              child: Text(
                'Aucune séance ne correspond '
                'aux filtres sélectionnés.',
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding:
                    const EdgeInsets.all(
                  12,
                ),
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: widgets,
              ),
            ),
    ),
  ],
);
  },
);


            },
          );
        },
      ),
    );
  }

Future<void> _deleteSession(
  SessionModel session,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Supprimer la séance ?',
        ),
        content: const Text(
          'Cette action est irréversible.\n\n'
          'Une séance ayant déjà un appel enregistré '
          'ne peut pas être supprimée.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text(
              'Annuler',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text(
              'Supprimer',
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  try {
    await _sessionRepository.deleteSession(
      session.id,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Séance supprimée.',
        ),
      ),
    );

    await _refresh();
  } on StateError catch (error) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.message,
        ),
      ),
    );
  } catch (error) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur lors de la suppression : $error',
        ),
      ),
    );
  }
}

}