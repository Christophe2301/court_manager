import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/session_model.dart';
import '../data/attendance_repository.dart';


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

  final Map<String, bool> _attendance = {};


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appel',
        ),
      ),

      body: FutureBuilder(
        future: _repository.getMembersByGroup(
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


          final members =
              snapshot.data ?? [];


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


                    final isPresent =
                        _attendance[member.id] ??
                        false;


                    return CheckboxListTile(

                      value: isPresent,

                      title: Text(
                        member.fullName,
                      ),

                      subtitle: Text(
                        member.licenseNumber,
                      ),

                      secondary:
                          const Icon(
                        Icons.person,
                      ),

                      onChanged: (value) {

                        setState(() {

                          _attendance[member.id] =
                              value ?? false;

                        });
                      },
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
}