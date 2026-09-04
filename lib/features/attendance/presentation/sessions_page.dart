import 'package:flutter/material.dart';

import '../data/session_repository.dart';
import '../../../core/models/session_model.dart';
import '../../../core/models/group.dart';
import '../../groups/data/group_repository.dart';
import 'attendance_screen.dart';
import 'session_edit_screen.dart';
import 'session_form_screen.dart';

class SessionsPage extends StatefulWidget {
  final String teacherId;

  const SessionsPage({
    super.key,
    required this.teacherId,
  });

  @override
  State<SessionsPage> createState() =>
      _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final SessionRepository _sessionRepository =
      SessionRepository();

  final GroupRepository _groupRepository =
      GroupRepository();

  late Future<List<SessionModel>> _sessionsFuture;
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  void _loadData() {
    _sessionsFuture =
        _sessionRepository.getSessionsByTeacher(
  widget.teacherId,
  '2026-2027',
);

    _groupsFuture =
        _groupRepository
            .watchGroupsForTeacher(
  widget.teacherId,
  '2026-2027',
)
            .first;
  }

  Future<void> _refreshSessions() async {
    setState(() {
      _loadData();
    });

    await _sessionsFuture;
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  bool _isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
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

  Color _statusColor(String status) {
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'planned':
        return Icons.schedule;

      case 'completed':
        return Icons.check_circle;

      case 'cancelled':
        return Icons.cancel;

      default:
        return Icons.info_outline;
    }
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        top: 12,
        bottom: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

Future<void> _cancelSession(
  BuildContext context,
  SessionModel session,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Annuler la séance ?'),
        content: const Text(
          'Cette séance sera marquée comme annulée. '
          'Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Annuler la séance'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  try {
    final cancelledSession = SessionModel(
  id: session.id,
  groupId: session.groupId,
  seasonId: session.seasonId,
  teacherIds: session.teacherIds,
  date: session.date,
  startTime: session.startTime,
  durationMinutes: session.durationMinutes,
  status: 'cancelled',
);

    await _sessionRepository.updateSession(
      cancelledSession,
    );

    if (!context.mounted) {
      return;
    }

    await _refreshSessions();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La séance a été annulée.'),
      ),
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur lors de l’annulation : $error',
        ),
      ),
    );
  }
}

  Future<void> _editSession(
    BuildContext context,
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

    if (!context.mounted) {
      return;
    }

    await _refreshSessions();
  }

  void _openAttendance(
    BuildContext context,
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

  Widget _buildSessionCard(
    BuildContext context,
    SessionModel session,
    Map<String, Group> groupsById,
    bool isToday,
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
      elevation: isToday ? 4 : 1,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: () {
          _openAttendance(
            context,
            session,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 58,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(10),
                  color: isToday
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                      : Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                ),
                child: Column(
                  children: [
                    Text(
                      session.date.day
                          .toString()
                          .padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                        color: isToday
                            ? Colors.white
                            : null,
                      ),
                    ),
                    Text(
                      session.date.month
                          .toString()
                          .padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday
                            ? Colors.white
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            groupName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                              color: isToday
                                  ? Theme.of(
                                      context,
                                    )
                                      .colorScheme
                                      .primary
                                  : null,
                            ),
                          ),
                        ),

                        if (isToday)
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .primary
                                  .withValues(
                                alpha: 0.12,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child: const Text(
                              "Aujourd'hui",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(
                            session.date,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${session.startTime} • '
                          '${session.durationMinutes} min',
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color: statusColor
                            .withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            _statusIcon(
                              session.status,
                            ),
                            size: 16,
                            color:
                                statusColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            _formatStatus(
                              session.status,
                            ),
                            style: TextStyle(
                              color:
                                  statusColor,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              PopupMenuButton<String>(
                tooltip: 'Actions',
                onSelected: (value) async {
                  switch (value) {
                    case 'attendance':
                      _openAttendance(
                        context,
                        session,
                      );
                      break;

                    case 'edit':
                      await _editSession(
                        context,
                        session,
                      );
                      break;

                      case 'cancel':
      await _cancelSession(
        context,
        session,
      );
      break;

      case 'complete':
      await _completeSession(
        context,
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
                  if (session.status == 'planned')
  const PopupMenuItem<String>(
    value: 'complete',
    child: Row(
      children: [
        Icon(
          Icons.check_circle_outline,
        ),
        SizedBox(width: 10),
        Text(
          'Marquer comme terminée',
        ),
      ],
    ),
  ),

if (session.status == 'planned')
  const PopupMenuItem<String>(
    value: 'cancel',
    child: Row(
      children: [
        Icon(
          Icons.cancel_outlined,
        ),
        SizedBox(width: 10),
        Text(
          'Annuler la séance',
        ),
      ],
    ),
  ),
  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Mes séances'),
  actions: [
    IconButton(
      icon: const Icon(
        Icons.add,
      ),
      tooltip: 'Créer une séance',
      onPressed: () {
        _createSession(context);
      },
    ),
  ],
),
      body: FutureBuilder<List<SessionModel>>(
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

          if (!sessionSnapshot.hasData ||
              sessionSnapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aucune séance prévue',
              ),
            );
          }

          final sessions =
              sessionSnapshot.data!;

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

              final now = DateTime.now();

              final today = <SessionModel>[];
              final upcoming = <SessionModel>[];
              final past = <SessionModel>[];

              for (final session in sessions) {
                if (_isSameDay(
                  session.date,
                  now,
                )) {
                  today.add(session);
                } else if (session.date
                    .isAfter(now)) {
                  upcoming.add(session);
                } else {
                  past.add(session);
                }
              }

              return RefreshIndicator(
                onRefresh: _refreshSessions,
                child: ListView(
                  padding:
                      const EdgeInsets.all(12),
                  children: [
                    if (today.isNotEmpty) ...[
                      _buildSectionTitle(
                        "Aujourd'hui",
                        Icons.today,
                      ),
                      ...today.map(
                        (session) =>
                            _buildSessionCard(
                          context,
                          session,
                          groupsById,
                          true,
                        ),
                      ),
                    ],

                    if (upcoming.isNotEmpty) ...[
                      _buildSectionTitle(
                        'À venir',
                        Icons.event,
                      ),
                      ...upcoming.map(
                        (session) =>
                            _buildSessionCard(
                          context,
                          session,
                          groupsById,
                          false,
                        ),
                      ),
                    ],

                    if (past.isNotEmpty) ...[
                      _buildSectionTitle(
                        'Passées',
                        Icons.history,
                      ),
                      ...past.map(
                        (session) =>
                            _buildSessionCard(
                          context,
                          session,
                          groupsById,
                          false,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

Future<void> _completeSession(
  BuildContext context,
  SessionModel session,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Terminer la séance ?',
        ),
        content: const Text(
          'Voulez-vous marquer cette séance '
          'comme terminée ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Terminer'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  try {
    final completedSession = SessionModel(
  id: session.id,
  groupId: session.groupId,
  seasonId: session.seasonId,
  teacherIds: session.teacherIds,
  date: session.date,
  startTime: session.startTime,
  durationMinutes: session.durationMinutes,
  status: 'completed',
);

    await _sessionRepository.updateSession(
      completedSession,
    );

    if (!context.mounted) {
      return;
    }

    await _refreshSessions();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La séance est maintenant terminée.',
        ),
      ),
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur lors de la clôture de la séance : $error',
        ),
      ),
    );
  }
}

Future<void> _createSession(
  BuildContext context,
) async {
  final created = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) =>
          SessionFormScreen(
        teacherId: widget.teacherId,
      ),
    ),
  );

  if (!context.mounted) {
    return;
  }

  if (created == true) {
    await _refreshSessions();
  }
}

}