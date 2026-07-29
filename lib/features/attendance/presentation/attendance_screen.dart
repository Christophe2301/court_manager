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


          return Column(
            children: [

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

                    onPressed: () async {

  final repository =
      AttendanceRepository();


  await repository.saveAttendances(
    sessionId: widget.session.id,
    attendance: _attendance,
    userId:
    FirebaseAuth.instance.currentUser!.uid,
  );


  if (context.mounted) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Appel enregistré',
        ),
      ),
    );

  }

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
}