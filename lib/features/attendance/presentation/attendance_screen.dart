import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/session_model.dart';
import '../../../core/models/group.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_screen_data.dart';
import '../../../core/models/attendance.dart';
import '../../../core/models/member.dart';
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

  bool _hasSavedAttendance = false;
  bool _hasUnsavedChanges = false;

  late Future<List<Group>> _groupsFuture;
  List<Member> _members = [];
  final Set<String> _temporaryMemberIds = {};

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

setState(() {
  _hasSavedAttendance = true;
  _hasUnsavedChanges = false;
});

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

return PopScope(
  canPop: !_hasUnsavedChanges,
  onPopInvokedWithResult: (
    didPop,
    result,
  ) async {
    if (didPop) {
      return;
    }

    final shouldLeave =
        await _confirmLeave();

    if (!context.mounted || !shouldLeave) {
      return;
    }

    Navigator.of(context).pop();
  },
  child: Scaffold(
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

if (_members.isEmpty) {
  _members = List<Member>.from(data.members);
}

// Reconstitution des adhérents ponctuels après
// fermeture puis réouverture de la séance.
_temporaryMemberIds.addAll(
  data.temporaryMemberIds,
);
final members = _members;
if (_attendance.isEmpty) {
  for (final member in members) {
    final status =
        data.attendances[member.id];

    _attendance[member.id] =
        status ??
            AttendanceStatus.absent;
  }
}


_members.sort(
  (a, b) =>
      a.lastName.compareTo(b.lastName),
);          if (members.isEmpty) {
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
  'Résumé de l\'appel — ${members.length} adhérents',
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 6),

_buildAttendanceStatus(),

      Wrap(
  spacing: 14,
  runSpacing: 4,
  children: [
    Text(
      '🟢 Présents : '
      '${statusCounts[AttendanceStatus.present] ?? 0}',
    ),
    Text(
      '🔴 Absents : '
      '${statusCounts[AttendanceStatus.absent] ?? 0}',
    ),
    Text(
      '🟠 Excusés : '
      '${statusCounts[AttendanceStatus.excused] ?? 0}',
    ),
    Text(
      '🔵 Rattrapage : '
      '${statusCounts[AttendanceStatus.makeup] ?? 0}',
    ),
    Text(
      '🟣 Essais : '
      '${statusCounts[AttendanceStatus.trial] ?? 0}',
    ),
    Text(
      '🟦 Invités : '
      '${statusCounts[AttendanceStatus.guest] ?? 0}',
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
  _confirmMarkAllAbsent(members);
},
        ),
      ),
      const SizedBox(height: 8),

SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    icon: const Icon(
      Icons.person_add,
    ),
    label: const Text(
      'Ajouter un adhérent',
    ),
    onPressed: () {
      _addMember(
        data.availableMembers,
      );
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
                                      Row(
  children: [
    Expanded(
      child: Text(
        member.fullName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    if (_temporaryMemberIds.contains(
      member.id,
    ))
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: const Text(
          'Ponctuel',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
  ],
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
                                  onChanged: (newStatus) {
  setState(() {
    _attendance[member.id] =
        newStatus;

    _hasUnsavedChanges = true;
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
  ),
    );
  }

Widget _buildAttendanceStatus() {
  if (_hasUnsavedChanges) {
    return const Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 18,
        ),
        SizedBox(width: 6),
        Text(
          'Modifications non enregistrées',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  if (_hasSavedAttendance) {
    return const Row(
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 18,
        ),
        SizedBox(width: 6),
        Text(
          'Appel enregistré',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  return const Row(
    children: [
      Icon(
        Icons.radio_button_unchecked,
        color: Colors.grey,
        size: 18,
      ),
      SizedBox(width: 6),
      Text(
        'Appel non effectué',
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

Future<bool> _confirmLeave() async {
  if (!_hasUnsavedChanges) {
    return true;
  }

  if (!mounted) {
    return false;
  }

  final shouldLeave = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Modifications non enregistrées',
        ),
        content: const Text(
          'Vous avez modifié l\'appel sans '
          'l\'enregistrer.\n\n'
          'Voulez-vous quitter sans enregistrer ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text(
              'Rester',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text(
              'Quitter',
            ),
          ),
        ],
      );
    },
  );

  return shouldLeave ?? false;
}

Future<void> _addMember(List<Member> availableMembers) async {
  final alreadyPresentIds =
      _attendance.keys.toSet();

  final candidates = availableMembers
      .where(
        (member) =>
            !alreadyPresentIds.contains(member.id),
      )
      .toList();

  if (candidates.isEmpty) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tous les adhérents sont déjà présents dans cet appel.',
        ),
      ),
    );

    return;
  }

  final selectedMember =
      await showDialog<Member>(
    context: context,
    builder: (dialogContext) {
      String search = '';

      return StatefulBuilder(
        builder: (
          context,
          setDialogState,
        ) {
          final filteredMembers = candidates
              .where(
                (member) {
                  final text =
                      '${member.firstName} '
                      '${member.lastName} '
                      '${member.licenseNumber}'
                          .toLowerCase();

                  return text.contains(
                    search.toLowerCase(),
                  );
                },
              )
              .toList();

          return AlertDialog(
            title: const Text(
              'Ajouter un adhérent',
            ),
            content: SizedBox(
              width: 450,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration:
                        const InputDecoration(
                      labelText: 'Rechercher',
                      hintText:
                          'Nom, prénom ou licence',
                      prefixIcon:
                          Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        search = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredMembers.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun adhérent trouvé',
                            ),
                          )
                        : ListView.builder(
                            itemCount:
                                filteredMembers.length,
                            itemBuilder:
                                (context, index) {
                              final member =
                                  filteredMembers[
                                      index];

                              return ListTile(
                                leading:
                                    const CircleAvatar(
                                  child: Icon(
                                    Icons.person,
                                  ),
                                ),
                                title: Text(
                                  member.fullName,
                                ),
                                subtitle: Text(
                                  'Licence : '
                                  '${member.licenseNumber}',
                                ),
                                onTap: () {
                                  Navigator.of(
                                    dialogContext,
                                  ).pop(member);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child: const Text('Annuler'),
              ),
            ],
          );
        },
      );
    },
  );

  if (selectedMember == null) {
    return;
  }

setState(() {
  _members.add(selectedMember);

  _members.sort(
    (a, b) =>
        a.lastName.compareTo(b.lastName),
  );

  _attendance[selectedMember.id] =
      AttendanceStatus.makeup;

  _temporaryMemberIds.add(
    selectedMember.id,
  );

  _hasUnsavedChanges = true;
});}

Future<void> _loadAttendances() async {
  final saved =
      await _repository.getAttendancesBySession(
    widget.session.id,
  );

  if (!mounted) {
    return;
  }

setState(() {
  _attendance
    ..clear()
    ..addAll(saved);

  _hasSavedAttendance = saved.isNotEmpty;
  _hasUnsavedChanges = false;
});
}
void _markAllPresent(List members) {
  setState(() {
    for (final member in members) {
      _attendance[member.id] =
          AttendanceStatus.present;
    }

    _hasUnsavedChanges = true;
  });
}
Future<void> _confirmMarkAllAbsent(
  List members,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Mettre tous les adhérents absents ?',
        ),
        content: Text(
          '${members.length} adhérents seront '
          'marqués comme absents.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text(
              'Annuler',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text(
              'Confirmer',
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  _markAllAbsent(members);
}

void _markAllAbsent(List members) {
  setState(() {
    for (final member in members) {
      _attendance[member.id] =
          AttendanceStatus.absent;
    }

    _hasUnsavedChanges = true;
  });
}
}