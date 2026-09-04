import 'package:flutter/material.dart';

import '../../members/data/member_repository.dart';
import '../../members/presentation/members_screen.dart';
import '../../teachers/data/teacher_repository.dart';
import '../../teachers/presentation/teachers_screen.dart';
import '../../groups/data/group_repository.dart';
import '../../groups/presentation/groups_screen.dart';
import '../../enrollments/data/enrollment_repository.dart';
import 'admin_sessions_screen.dart';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({
    super.key,
  });

  @override
  State<AdministrationScreen> createState() =>
      _AdministrationScreenState();
}

class _AdministrationScreenState
    extends State<AdministrationScreen> {
  final MemberRepository _memberRepository =
      MemberRepository();

  final TeacherRepository _teacherRepository =
      TeacherRepository();

  final GroupRepository _groupRepository =
      GroupRepository();

  final EnrollmentRepository _enrollmentRepository =
      EnrollmentRepository();

  late Future<int> _membersCountFuture;
  late Future<int> _teachersCountFuture;
  late Future<int> _groupsCountFuture;
  late Future<int> _enrollmentsCountFuture;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  void _loadCounts() {
    _membersCountFuture =
    _memberRepository
        .watchMembersForSeason(
          '2026-2027',
        )
        .first
        .then(
          (members) => members.length,
        );

    _teachersCountFuture =
        _teacherRepository.watchActiveTeachers().first.then(
              (teachers) => teachers.length,
            );

    _groupsCountFuture =
    _groupRepository
        .watchActiveGroupsForSeason(
          '2026-2027',
        )
        .first
        .then(
          (groups) => groups.length,
        );

    _enrollmentsCountFuture =
    _enrollmentRepository
        .watchEnrollmentsForSeason(
          '2026-2027',
        )
        .first
        .then(
          (enrollments) => enrollments.length,
        );
  }

    Future<void> _refresh() async {
    setState(() {
      _loadCounts();
    });

    await Future.wait([
      _membersCountFuture,
      _teachersCountFuture,
      _groupsCountFuture,
      _enrollmentsCountFuture,
    ]);
  }

  Future<void> _openScreen(
    BuildContext context,
    Widget screen,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );

    if (!context.mounted) {
      return;
    }

    await _refresh();
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Future<int> future,
    required Color color,
  }) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        final value = snapshot.data;

        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color:
                        color.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (snapshot.connectionState ==
                          ConnectionState.waiting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else if (snapshot.hasError)
                        const Text(
                          'Erreur',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          '${value ?? 0}',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        top: 20,
        bottom: 10,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {
          _openScreen(
            context,
            screen,
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
          'Administration',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24,
          ),
          children: [
            const Text(
              'Vue d’ensemble',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gestion du club',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),

            _buildStatCard(
              context: context,
              icon: Icons.people,
              title: 'Adhérents actifs',
              future: _membersCountFuture,
              color: Colors.blue,
            ),

            _buildStatCard(
              context: context,
              icon: Icons.school,
              title: 'Professeurs actifs',
              future: _teachersCountFuture,
              color: Colors.green,
            ),

            _buildStatCard(
              context: context,
              icon: Icons.groups,
              title: 'Groupes actifs',
              future: _groupsCountFuture,
              color: Colors.orange,
            ),

            _buildStatCard(
              context: context,
              icon: Icons.assignment_ind,
              title: 'Inscriptions actives',
              future: _enrollmentsCountFuture,
              color: Colors.purple,
            ),

            _buildSectionTitle(
              'Gestion',
              Icons.settings,
            ),

            _buildManagementCard(
              context: context,
              icon: Icons.people,
              title: 'Adhérents',
              subtitle:
                  'Gérer les adhérents du club',
              screen: const MembersScreen(),
            ),

            _buildManagementCard(
              context: context,
              icon: Icons.school,
              title: 'Professeurs',
              subtitle:
                  'Gérer les professeurs du club',
              screen: const TeachersScreen(),
            ),

            _buildManagementCard(
              context: context,
              icon: Icons.groups,
              title: 'Groupes',
              subtitle:
                  'Gérer les groupes du club',
              screen: const GroupsScreen(),
            ),
_buildManagementCard(
  context: context,
  icon: Icons.calendar_month,
  title: 'Séances',
  subtitle: 'Gérer les séances du club',
  screen: const AdminSessionsScreen(),
),
            _buildSectionTitle(
              'Prochaine version',
              Icons.upcoming,
            ),

            Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: const CircleAvatar(
                  child: Icon(
                    Icons.calendar_month,
                  ),
                ),
                title: const Text(
                  'Saisons',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Gestion des saisons du club',
                ),
                trailing: const Chip(
                  label: Text('V2'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}