import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/group.dart';
import '../../../core/models/member.dart';
import '../../members/providers/member_provider.dart';
import '../../teachers/data/teacher_repository.dart';
import '../../auth/models/app_user.dart';
import '../data/group_repository.dart';
import 'group_form_screen.dart';
import '../../enrollments/presentation/add_member_to_group_screen.dart';
import '../../../core/models/enrollment.dart';
import '../../members/presentation/member_group_transfer_screen.dart';

import '../../enrollments/providers/enrollment_provider.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final Group group;
  final bool teacherMode;

  const GroupDetailScreen({
  super.key,
  required this.group,
  this.teacherMode = false,
});

  @override
  ConsumerState<GroupDetailScreen> createState() =>
      _GroupDetailScreenState();
}

class _GroupDetailScreenState
    extends ConsumerState<GroupDetailScreen> {
  late Group _group;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
  }

  Future<void> _editGroup() async {
    final updatedGroup = await Navigator.push<Group>(
      context,
      MaterialPageRoute(
        builder: (context) => GroupFormScreen(
          group: _group,
        ),
      ),
    );

    if (updatedGroup == null || !mounted) {
      return;
    }

    setState(() {
      _group = updatedGroup;
    });
  }

Future<void> _deactivateGroup() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Désactiver le groupe',
        ),
        content: Text(
          'Voulez-vous vraiment désactiver le groupe '
          '« ${_group.name} » ?',
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
              'Désactiver',
            ),
          ),
        ],
      );
    },
  );

if (confirmed != true) {
  return;
}

final currentUser =
    FirebaseAuth.instance.currentUser;

if (currentUser == null) {
  if (!mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Utilisateur non connecté',
      ),
    ),
  );

  return;
}

try {
  await GroupRepository().deactivateGroup(
    groupId: _group.id,
    updatedBy: currentUser.uid,
  );

  if (!mounted) {
    return;
  }

  setState(() {
    _group = _group.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
      updatedBy: currentUser.uid,
    );
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Groupe désactivé avec succès',
      ),
    ),
  );
} catch (e) {
  if (!mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Erreur lors de la désactivation : $e',
      ),
    ),
  );
}
}

Future<void> _reactivateGroup() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Réactiver le groupe',
        ),
        content: Text(
          'Voulez-vous vraiment réactiver le groupe '
          '« ${_group.name} » ?',
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
              'Réactiver',
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  final currentUser =
      FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Utilisateur non connecté',
        ),
      ),
    );

    return;
  }

  try {
    await GroupRepository().reactivateGroup(
      groupId: _group.id,
      updatedBy: currentUser.uid,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _group = _group.copyWith(
        isActive: true,
        updatedAt: DateTime.now(),
        updatedBy: currentUser.uid,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Groupe réactivé avec succès',
        ),
      ),
    );
  } catch (e) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur lors de la réactivation : $e',
        ),
      ),
    );
  }
}

  @override
Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  title: const Text('Fiche groupe'),
actions: [
  if (!widget.teacherMode) ...[
  IconButton(
    icon: const Icon(
      Icons.edit,
    ),
    tooltip: 'Modifier',
    onPressed: _editGroup,
  ),

  if (_group.isActive)
    IconButton(
      icon: const Icon(
        Icons.block,
      ),
      tooltip: 'Désactiver',
      onPressed: _deactivateGroup,
    ),

  if (!_group.isActive)
    IconButton(
      icon: const Icon(
        Icons.check_circle,
      ),
      tooltip: 'Réactiver',
      onPressed: _reactivateGroup,
    ),
],
],
),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoSection(
            title: 'Groupe',
            children: [
              _InfoRow(
                label: 'Nom',
                value: _group.name,
              ),
              _InfoRow(
                label: 'Type',
                value: _groupTypeLabel(_group.type),
              ),
              _InfoRow(
                label: 'Saison',
                value: _group.seasonId,
              ),
              _InfoRow(
                label: 'Jour',
                value: _dayOfWeekLabel(
                  _group.dayOfWeek,
                ),
              ),
              _InfoRow(
                label: 'Horaire',
                value: _group.startTime,
              ),
              _InfoRow(
                label: 'Durée',
                value:
                    '${_group.durationMinutes} minutes',
              ),
              _InfoRow(
                label: 'Statut',
                value: _group.isActive
                    ? 'Actif'
                    : 'Inactif',
              ),
            ],
          ),

          const SizedBox(height: 16),

          _TeachersSection(
            teacherIds: _group.teacherIds,
          ),

          const SizedBox(height: 16),

          _InfoSection(
            title: 'Adhérents inscrits',
            children: [
              Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.person_add),
    label: const Text(
      'Ajouter un adhérent',
    ),
    onPressed: () async {
      final member =
          await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AddMemberToGroupScreen(
            groupId: _group.id,
            seasonId: _group.seasonId,
          ),
        ),
      );

      if (member != null && context.mounted) {
  await _addMemberToGroup(member);
}
    },
  ),
),
const SizedBox(height: 12),
SizedBox(
                height: 400,
                child: ref.watch(
                  groupMembersProvider(_group.id),
                ).when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Erreur : $error',
                    ),
                  ),
                  data: (members) {
                    if (members.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucun adhérent inscrit',
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member =
                            members[index];

                        return Card(
  child: ListTile(
    leading: const Icon(
      Icons.person,
    ),
    title: Text(
      member.fullName,
    ),
    subtitle: Text(
      member.licenseNumber,
    ),
    trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(
        Icons.swap_horiz,
      ),
      tooltip: 'Changer de groupe',
      onPressed: () =>
          _transferMember(member),
    ),
    IconButton(
      icon: const Icon(
        Icons.person_remove,
      ),
      tooltip: 'Retirer du groupe',
      onPressed: () =>
          _removeMemberFromGroup(member),
    ),
  ],
),
  ),
);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _groupTypeLabel(
    GroupType type,
  ) {
    switch (type) {
      case GroupType.tennisSchool:
        return 'École de tennis';
      case GroupType.adultLeisure:
        return 'Adultes loisirs';
      case GroupType.competition:
        return 'Compétition';
      case GroupType.team:
        return 'Équipe';
      case GroupType.course:
        return 'Cours';
      case GroupType.other:
        return 'Autre';
    }
  }

  static String _dayOfWeekLabel(
    int day,
  ) {
    switch (day) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return 'Non renseigné';
    }
  }

  Future<void> _addMemberToGroup(
  Member member,
) async {
  final currentUser =
      FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Utilisateur non connecté',
        ),
      ),
    );

    return;
  }

  final repository =
      ref.read(enrollmentRepositoryProvider);

  try {
    final exists =
        await repository.activeEnrollmentExists(
      memberId: member.id,
      groupId: _group.id,
      seasonId: _group.seasonId,
    );

    if (exists) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member.fullName} est déjà inscrit dans ce groupe',
          ),
        ),
      );

      return;
    }

    final now = DateTime.now();

    final enrollment = Enrollment(
      id: repository.newEnrollmentId(),
      memberId: member.id,
      groupId: _group.id,
      seasonId: _group.seasonId,
      startDate: now,
      endDate: null,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      createdBy: currentUser.uid,
      updatedBy: currentUser.uid,
    );

    await repository.createEnrollment(
      enrollment,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${member.fullName} a été ajouté au groupe',
        ),
      ),
    );
  } catch (e) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur lors de l’inscription : $e',
        ),
      ),
    );
  }
}

Future<void> _transferMember(
  Member member,
) async {
  final repository =
      ref.read(enrollmentRepositoryProvider);

  final enrollments =
      await repository
          .watchEnrollmentsForMember(
            member.id,
          )
          .first;

  Enrollment? enrollment;

  for (final item in enrollments) {
    if (item.groupId == _group.id &&
        item.seasonId == _group.seasonId) {
      enrollment = item;
      break;
    }
  }

  if (enrollment == null) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Inscription active introuvable.',
        ),
      ),
    );

    return;
  }

  if (!mounted) {
    return;
  }

  final changed =
      await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) =>
          MemberGroupTransferScreen(
        memberId: member.id,
        enrollment: enrollment!,
        currentGroup: _group,
      ),
    ),
  );

  if (changed == true && mounted) {
    ref.invalidate(
      groupMembersProvider(_group.id),
    );
  }
}

Future<void> _removeMemberFromGroup(
  Member member,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Retirer l\'adhérent',
        ),
        content: Text(
          'Voulez-vous vraiment retirer '
          '${member.fullName} du groupe '
          '« ${_group.name} » ?',
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
              'Retirer',
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  final currentUser =
      FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Utilisateur non connecté',
        ),
      ),
    );

    return;
  }

  try {
    final repository =
        ref.read(enrollmentRepositoryProvider);

    await repository.deactivateEnrollment(
      memberId: member.id,
      groupId: _group.id,
      seasonId: _group.seasonId,
      updatedBy: currentUser.uid,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${member.fullName} a été retiré du groupe',
        ),
      ),
    );
  } catch (e) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur lors du retrait : $e',
        ),
      ),
    );
  }
}

}



class _TeachersSection extends StatelessWidget {
  final List<String> teacherIds;

  const _TeachersSection({
    required this.teacherIds,
  });

  @override
  Widget build(BuildContext context) {
    if (teacherIds.isEmpty) {
      return const _InfoSection(
        title: 'Professeur(s)',
        children: [
          _InfoRow(
            label: 'Professeur(s)',
            value: 'Aucun professeur affecté',
          ),
        ],
      );
    }

    return FutureBuilder<List<AppUser>>(
      future: _loadTeachers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _InfoSection(
            title: 'Professeur(s)',
            children: [
              _InfoRow(
                label: 'Erreur',
                value: '${snapshot.error}',
              ),
            ],
          );
        }

        final teachers = snapshot.data ?? [];

        if (teachers.isEmpty) {
          return const _InfoSection(
            title: 'Professeur(s)',
            children: [
              _InfoRow(
                label: 'Professeur(s)',
                value: 'Aucun professeur trouvé',
              ),
            ],
          );
        }

        return _InfoSection(
          title: 'Professeur(s)',
          children: teachers
              .map(
                (teacher) => _InfoRow(
                  label: 'Professeur',
                  value: teacher.fullName,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<List<AppUser>> _loadTeachers() async {
    final repository = TeacherRepository();

    final teachers = <AppUser>[];

    for (final teacherId in teacherIds) {
      final teacher =
          await repository.getTeacher(teacherId);

      if (teacher != null) {
        teachers.add(teacher);
      }
    }

    return teachers;
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
