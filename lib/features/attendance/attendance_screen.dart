import 'package:flutter/material.dart';

import 'adherent.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState
    extends State<AttendanceScreen> {

  final List<Adherent> adherents = [
    Adherent(
      firstName: 'Arthur',
      lastName: 'DUPONT',
    ),
    Adherent(
      firstName: 'Emma',
      lastName: 'MARTIN',
    ),
    Adherent(
      firstName: 'Lucas',
      lastName: 'BERNARD',
    ),
    Adherent(
      firstName: 'Léa',
      lastName: 'PETIT',
    ),
  ];

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
        ],
      ),
    );
  }
}