import 'package:flutter/material.dart';

import '../data/session_repository.dart';
import '../../../core/models/session_model.dart';
import '../../../core/models/group.dart';
import '../../groups/data/group_repository.dart';
import 'attendance_screen.dart';

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

    _sessionsFuture =
        _sessionRepository.getSessionsByTeacher(
      widget.teacherId,
    );

    _groupsFuture =
        _groupRepository
            .watchGroupsForTeacher(widget.teacherId)
            .first;
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes séances'),
      ),
      body: FutureBuilder<List<SessionModel>>(
        future: _sessionsFuture,
        builder: (context, sessionSnapshot) {
          if (sessionSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (sessionSnapshot.hasError) {
            return Center(
              child: Text(
                'Erreur : ${sessionSnapshot.error}',
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
                  child: CircularProgressIndicator(),
                );
              }

              if (groupSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur lors du chargement des groupes : '
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

              return ListView.builder(
                padding:
                    const EdgeInsets.all(12),
                itemCount: sessions.length,
                itemBuilder: (
                  context,
                  index,
                ) {
                  final session =
                      sessions[index];

                  final group =
                      groupsById[session.groupId];

                  final groupName =
                      group?.name ??
                      session.groupId;

                  final statusColor =
                      _statusColor(
                    session.status,
                  );

                  return Card(
                    margin:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AttendanceScreen(
                              session: session,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 8,
                              ),
                              decoration:
                                  BoxDecoration(
                                borderRadius:
                                    BorderRadius
                                        .circular(10),
                                color: Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    session.date.day
                                        .toString()
                                        .padLeft(
                                          2,
                                          '0',
                                        ),
                                    style:
                                        const TextStyle(
                                      fontSize: 22,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                  Text(
                                    session.date.month
                                        .toString()
                                        .padLeft(
                                          2,
                                          '0',
                                        ),
                                    style:
                                        const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    groupName,
                                    style:
                                        const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .calendar_today,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        _formatDate(
                                          session.date,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '${session.startTime} • '
                                        '${session.durationMinutes} min',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          statusColor
                                              .withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        20,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                          MainAxisSize
                                              .min,
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
                                          style:
                                              TextStyle(
                                            color:
                                                statusColor,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            const Icon(
                              Icons.chevron_right,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}