import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/session_model.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_screen_data.dart';
import '../../../core/models/attendance.dart';
import '../widgets/attendance_status_chip.dart';


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

  final Map<String, AttendanceStatus> _attendance = {};

@override
void initState() {
  super.initState();

  _loadAttendances();
}

Map<AttendanceStatus, int> _getStatusCounts() {
  final counts = <AttendanceStatus, int>{};

  for (final status in _attendance.values) {
    counts[status] = (counts[status] ?? 0) + 1;
  }

  return counts;
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
            child: const Text(
              'Annuler',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text(
              'Enregistrer',
            ),
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
      content: Text(
        'Appel enregistré',
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appel',
        ),
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


final data =
    snapshot.data!;

final members =
    data.members;



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

final statusCounts = _getStatusCounts();

return Column(
  children: [

    Padding(
      padding: const EdgeInsets.all(8),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${members.length} adhérents',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Wrap(
        spacing: 12,
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
    ],
  ),
),
          ElevatedButton.icon(
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

        ],
      ),
    ),


    Expanded(
      child: ListView.builder(
                  itemCount: members.length,

                  itemBuilder: (
                    context,
                    index,
                  ) {

                    final member =
                        members[index];


                    
    _attendance[member.id] ??
    AttendanceStatus.absent;


                   return ListTile(

  leading: const Icon(
    Icons.person,
  ),

  title: Text(
    member.fullName,
  ),

  subtitle: Text(
    member.licenseNumber,
  ),

  trailing: AttendanceStatusChip(

    status:
        _attendance[member.id] ??
        AttendanceStatus.absent,

    onChanged: (status) {

      setState(() {

        _attendance[member.id] =
            status;

      });

    },
  ),
);
                  },
                ),
              ),


              Padding(
                padding:
                    const EdgeInsets.all(16),

                child: SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

onPressed: () {
  _confirmSave(context);
},
                    child: const Text(
                      'Valider l\'appel',
                    ),
                  ),
                ),
              ),
            ],
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
}