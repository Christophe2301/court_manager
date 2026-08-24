import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/group.dart';
import '../../../core/models/session_model.dart';

import '../../auth/models/app_user.dart';
import '../../admin/presentation/administration_screen.dart';
import '../../attendance/data/session_repository.dart';
import '../../attendance/presentation/attendance_screen.dart';
import '../../attendance/presentation/sessions_page.dart';
import '../../groups/providers/group_provider.dart';

import '../widgets/welcome_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const DashboardScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends ConsumerState<DashboardScreen> {
  final SessionRepository _sessionRepository =
      SessionRepository();

  late Future<List<SessionModel>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    if (widget.user.isAdmin) {
      _sessionsFuture =
          _sessionRepository.getAllSessions();
    } else {
      _sessionsFuture =
          _sessionRepository.getSessionsByTeacher(
        widget.user.uid,
      );
    }
  }

  bool _isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Future<void> _confirmLogout(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Déconnexion',
          ),
          content: const Text(
            'Voulez-vous vraiment vous déconnecter ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Annuler',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Déconnexion',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await FirebaseAuth.instance.signOut();
  }

  Future<void> _openSessions() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SessionsPage(
          teacherId: widget.user.uid,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _loadSessions();
    });
  }

  Future<void> _openAttendance(
    SessionModel session,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AttendanceScreen(
          session: session,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _loadSessions();
    });
  }

  Widget _buildTodaySessionCard(
    SessionModel session,
    Map<String, Group> groupsById,
  ) {
    final group =
        groupsById[session.groupId];

    final groupName =
        group?.name ?? session.groupId;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: () {
          _openAttendance(session);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Text(
                  session.startTime,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${session.durationMinutes} minutes',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final groupsAsync = widget.user.isAdmin
        ? ref.watch(
            activeGroupsProvider,
          )
        : ref.watch(
            teacherGroupsProvider(
              widget.user.uid,
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CourtManager 🎾',
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Menu',
            onSelected: (value) async {
              if (value == 'logout') {
                await _confirmLogout(
                  context,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Déconnexion',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            WelcomeCard(
              firstName:
                  widget.user.firstName,
              lastName:
                  widget.user.lastName,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.calendar_month,
                ),
                label: const Text(
                  'Mes séances',
                ),
                onPressed: _openSessions,
              ),
            ),

            const SizedBox(height: 20),

            if (widget.user.isAdmin) ...[
              SizedBox(
                width:
                    double.infinity,
                child:
                    OutlinedButton.icon(
                  icon: const Icon(
                    Icons
                        .admin_panel_settings,
                  ),
                  label: const Text(
                    'Administration',
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (
                          context,
                        ) =>
                            const AdministrationScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],

            const Text(
              "Aujourd'hui",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: groupsAsync.when(
                loading: () =>
                    const Center(
                  child:
                      CircularProgressIndicator(),
                ),

                error: (
                  error,
                  stack,
                ) =>
                    Center(
                  child: Text(
                    'Erreur : $error',
                  ),
                ),

                data: (groups) {
                  final groupsById = {
                    for (final group
                        in groups)
                      group.id: group,
                  };

                  return FutureBuilder<
                      List<SessionModel>>(
                    future:
                        _sessionsFuture,
                    builder: (
                      context,
                      sessionSnapshot,
                    ) {
                      if (sessionSnapshot
                              .connectionState ==
                          ConnectionState
                              .waiting) {
                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      if (sessionSnapshot
                          .hasError) {
                        return Center(
                          child: Text(
                            'Erreur : '
                            '${sessionSnapshot.error}',
                          ),
                        );
                      }

                      final now =
                          DateTime.now();

                      final todaySessions =
                          (sessionSnapshot
                                      .data ??
                                  [])
                              .where(
                                (
                                  session,
                                ) =>
                                    _isSameDay(
                                  session
                                      .date,
                                  now,
                                ),
                              )
                              .toList();

                      todaySessions.sort(
                        (a, b) =>
                            a.startTime
                                .compareTo(
                          b.startTime,
                        ),
                      );

                      if (todaySessions
                          .isEmpty) {
                        return const Center(
                          child: Text(
                            'Aucune séance prévue aujourd’hui',
                          ),
                        );
                      }

                      return ListView(
                        children: [
                          Card(
                            child: ListTile(
                              leading:
                                  const Icon(
                                Icons.today,
                              ),
                              title:
                                  const Text(
                                "Aujourd'hui",
                              ),
                              subtitle: Text(
                                '${todaySessions.length} '
                                'séance(s) prévue(s)',
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          ...todaySessions.map(
                            (session) =>
                                _buildTodaySessionCard(
                              session,
                              groupsById,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}