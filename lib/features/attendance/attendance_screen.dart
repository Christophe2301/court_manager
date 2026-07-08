import 'package:flutter/material.dart';

import 'adherent_repository.dart';
import 'session.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState
    extends State<AttendanceScreen> {

    final adherents = AdherentRepository().getAdherentsForCourse();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appel - Mini Tennis'),
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: adherents.length,
              itemBuilder: (context, index) {

                final adherent = adherents[index];

                return CheckboxListTile(
                  title: Text(
                    adherent.fullName,
                  ),

                  value: adherent.present,

                  onChanged: (value) {

                    setState(() {
                      adherent.present = value ?? false;
                    });

                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: Text(
              'Présents : ${adherents.where((a) => a.present).length} / ${adherents.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {

              final session = Session(
                date: DateTime.now(),
                courseName: 'Mini Tennis',
                presentAdherents: adherents
                    .where((a) => a.present)
                    .map((a) => a.fullName)
                    .toList(),
              );

              debugPrint(
                'Séance enregistrée : ${session.presentAdherents}',
              );

            },
            child: const Text(
              'Valider la séance',
            ),
          ),
        ],
      ),
    );
  }
}