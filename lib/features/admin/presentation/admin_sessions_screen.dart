import 'package:flutter/material.dart';

import '../../../core/models/group.dart';
import '../../../core/models/session_model.dart';
import '../../attendance/data/session_repository.dart';
import '../../attendance/presentation/attendance_screen.dart';
import '../../attendance/presentation/session_edit_screen.dart';
import '../../attendance/presentation/session_form_screen.dart';
import '../../groups/data/group_repository.dart';

class AdminSessionsScreen extends StatefulWidget {
  const AdminSessionsScreen({
    super.key,
  });

  @override
  State<AdminSessionsScreen> createState() =>
      _AdminSessionsScreenState();
}

class _AdminSessionsScreenState
    extends State<AdminSessionsScreen> {
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
        _sessionRepository.getAllSessions();

    _groupsFuture =
        _groupRepository.watchActiveGroups().first;
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });

    await _sessionsFuture;
  }

  Future<void> _createSession() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SessionFormScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (created == true) {
      await _refresh();
    }
  }

  Future<void> _editSession(
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

    if (!mounted) {
      return;
    }

    await _refresh();
  }

  void _openAttendance(
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

  Color _statusColor(
    String status,
  ) {
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

  Widget _buildSessionCard(
    BuildContext context,
    SessionModel session,
    Map<String, Group> groupsById,
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
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Text(
            session.date.day
                .toString()
                .padLeft(2, '0'),
          ),
        ),
        title: Text(
          groupName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text(
              '${_formatDate(session.date)} '
              '• ${session.startTime} '
              '• ${session.durationMinutes} min',
            ),

            const SizedBox(height: 6),

            Text(
              _formatStatus(
                session.status,
              ),
              style: TextStyle(
                color: statusColor,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing:
            PopupMenuButton<String>(
          tooltip: 'Actions',
          onSelected: (value) async {
            switch (value) {
              case 'attendance':
                _openAttendance(
                  session,
                );
                break;

              case 'edit':
                await _editSession(
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
          ],
        ),
        onTap: () {
          _openAttendance(
            session,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Séances',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
            ),
            tooltip:
                'Créer une séance',
            onPressed: _createSession,
          ),
        ],
      ),
      body:
          FutureBuilder<List<SessionModel>>(
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

          final sessions =
              sessionSnapshot.data ?? [];

          if (sessions.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 160),
                  Center(
                    child: Text(
                      'Aucune séance',
                    ),
                  ),
                ],
              ),
            );
          }

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

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.all(12),
                  itemCount:
                      sessions.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final session =
                        sessions[index];

                    return _buildSessionCard(
                      context,
                      session,
                      groupsById,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}