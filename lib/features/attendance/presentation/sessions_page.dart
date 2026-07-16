import 'package:flutter/material.dart';

import '../data/session_repository.dart';
import '../../../core/models/session_model.dart';


class SessionsPage extends StatefulWidget {
  final String teacherId;

  const SessionsPage({
    super.key,
    required this.teacherId,
  });

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}


class _SessionsPageState extends State<SessionsPage> {

  final SessionRepository _repository = SessionRepository();

  late Future<List<SessionModel>> _sessionsFuture;


  @override
  void initState() {
    super.initState();

    _sessionsFuture =
        _repository.getSessionsByTeacher(widget.teacherId);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes séances'),
      ),

      body: FutureBuilder<List<SessionModel>>(
        future: _sessionsFuture,

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }


          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {

            return const Center(
              child: Text(
                'Aucune séance prévue',
              ),
            );
          }


          final sessions = snapshot.data!;


          return ListView.builder(
            itemCount: sessions.length,

            itemBuilder: (context, index) {

              final session = sessions[index];


              return Card(
                margin: const EdgeInsets.all(8),

                child: ListTile(

                  title: Text(
                    session.groupId,
                  ),

                  subtitle: Text(
                    '${session.date.day}/${session.date.month}/${session.date.year}'
                    ' - ${session.startTime}'
                    ' (${session.durationMinutes} min)',
                  ),

                  trailing: Text(
                    session.status,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}