import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/session_model.dart';
import '../../../core/models/group.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_screen_data.dart';
import '../../../core/models/attendance.dart';
import '../widgets/attendance_status_chip.dart';
import '../../groups/data/group_repository.dart';

class AttendanceScreen extends StatefulWidget {
  final SessionModel session;

  const AttendanceScreen({
    super.key,
    required this.session,
  });

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState
    extends State<AttendanceScreen> {
  final AttendanceRepository _repository =
      AttendanceRepository();

  final GroupRepository _groupRepository =
      GroupRepository();

  final Map<String, AttendanceStatus> _attendance = {};

  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();

    _loadAttendances();

    _groupsFuture =
        _groupRepository
            .watchGroupsForTeacher(
              widget.session.teacherIds.first,
            )
            .first;
  }

  Map<AttendanceStatus, int> _getStatusCounts() {
    final counts = <AttendanceStatus, int>{};

    for (final status in _attendance.values) {
      counts[status] =
          (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _confirmSave(
    BuildContext context,
  ) async {
    final counts = _getStatusCounts();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Enregistrer l\'appel ?',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '🟢 Présents : '
                '${counts[AttendanceStatus.present] ?? 0}',
              ),
              Text(
                '🔴 Absents : '
                '${counts[AttendanceStatus.absent] ?? 0}',
              ),
              Text(
                '🟠 Excusés : '
                '${counts[AttendanceStatus.excused] ?? 0}',
              ),
              Text(
                '🔵 Rattrapage : '
                '${counts[AttendanceStatus.makeup] ?? 0}',
              ),
              Text(
                '🟣 Essais : '
                '${counts[AttendanceStatus.trial] ?? 0}',
              ),
              Text(
                '🟦 Invités : '
                '${counts[AttendanceStatus.guest] ?? 0}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _repository.saveAttendances(
      sessionId: widget.session.id,
      attendance: _attendance,
      userId:
          FirebaseAuth.instance.currentUser!.uid,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appel enregistré'),
      ),
    );
  }

  Widget _buildSessionHeader(
    BuildContext context,
    Group? group,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        14,
      ),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            group?.name ?? widget.session.groupId,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(
                      widget.session.date,
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.session.startTime,
                  ),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timelapse,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.session.durationMinutes} min',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appel'),
      ),
      body: FutureBuilder<AttendanceScreenData>(
        future: _repository.getAttendanceScreenData(
          widget.session.id,
          widget.session.groupId,
        ),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur : ${snapshot.error}',
              ),
            );
          }

          final data = snapshot.data!;
          final members = data.members;

          if (_attendance.isEmpty) {
            for (final member in members) {
              final status =
                  data.attendances[member.id];

              _attendance[member.id] =
                  status ??
                      AttendanceStatus.absent;
            }
          }

          if (members.isEmpty) {
            return const Center(
              child: Text(
                'Aucun adhérent inscrit',
              ),
            );
          }

          final statusCounts =
              _getStatusCounts();

          return FutureBuilder<List<Group>>(
            future: _groupsFuture,
            builder: (
              context,
              groupSnapshot,
            ) {
              Group? group;

              if (groupSnapshot.hasData) {
                for (final item
                    in groupSnapshot.data!) {
                  if (item.id ==
                      widget.session.groupId) {
                    group = item;
                    break;
                  }
                }
              }

              return Column(
                children: [
                  _buildSessionHeader(
                    context,
                    group,
                  ),


// --------------------------------------------------
// Résumé
// --------------------------------------------------
Padding(
  padding: const EdgeInsets.fromLTRB(
    16,
    12,
    16,
    12,
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.stretch,
    children: [
      Text(
        '${members.length} adhérents',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 6),

      Wrap(
        spacing: 14,
        runSpacing: 4,
        children: [
          Text(
            '🟢 ${statusCounts[AttendanceStatus.present] ?? 0}',
          ),
          Text(
            '🔴 ${statusCounts[AttendanceStatus.absent] ?? 0}',
          ),
          Text(
            '🟠 ${statusCounts[AttendanceStatus.excused] ?? 0}',
          ),
        ],
      ),

      const SizedBox(height: 12),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(
            Icons.done_all,
          ),
          label: const Text(
            'Tous présents',
          ),
          onPressed: () {
            _markAllPresent(members);
          },
        ),
      ),

      const SizedBox(height: 8),

      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(
            Icons.remove_done,
          ),
          label: const Text(
            'Tous absents',
          ),
          onPressed: () {
            _markAllAbsent(members);
          },
        ),
      ),
    ],
  ),
),

const Divider(height: 1),

                  // --------------------------------------------------
                  // Liste des adhérents
                  // --------------------------------------------------
                  Expanded(
                    child: ListView.builder(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: members.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final member =
                            members[index];

                        final status =
                            _attendance[
                                    member.id] ??
                                AttendanceStatus
                                    .absent;

                        return Card(
                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 8,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  child: Icon(
                                    Icons.person,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        member.fullName,
                                        style:
                                            const TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Licence : ${member.licenseNumber}',
                                        style:
                                            TextStyle(
                                          color: Colors
                                              .grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                AttendanceStatusChip(
                                  status: status,
                                  onChanged:
                                      (newStatus) {
                                    setState(() {
                                      _attendance[
                                              member
                                                  .id] =
                                          newStatus;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // --------------------------------------------------
                  // Bouton d'enregistrement
                  // --------------------------------------------------
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child:
                            ElevatedButton.icon(
                          icon: const Icon(
                            Icons.save,
                          ),
                          onPressed: () {
                            _confirmSave(
                              context,
                            );
                          },
                          label: const Text(
                            'Valider l\'appel',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _loadAttendances() async {
    final saved =
        await _repository.getAttendancesBySession(
      widget.session.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _attendance.addAll(saved);
    });
  }

  void _markAllPresent(List members) {
    setState(() {
      for (final member in members) {
        _attendance[member.id] =
            AttendanceStatus.present;
      }
    });
  }
  void _markAllAbsent(List members) {
  setState(() {
    for (final member in members) {
      _attendance[member.id] =
          AttendanceStatus.absent;
    }
  });
}
}