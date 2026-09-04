import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enrollments/data/enrollment_repository.dart';
import '../../enrollments/providers/enrollment_provider.dart';
import '../../groups/data/group_repository.dart';
import '../data/member_repository.dart';
import 'member_form_screen.dart';
import '../../../core/models/member.dart';
import '../../../core/models/group.dart';
import 'member_group_transfer_screen.dart';

class MemberDetailScreen extends ConsumerWidget {
  final Member member;

  const MemberDetailScreen({
    super.key,
    required this.member,
  });

Future<void> _deactivateMember(
  BuildContext context,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Désactiver l’adhérent ?',
        ),
        content: Text(
          'Voulez-vous vraiment désactiver '
          '${member.fullName} ?\n\n'
          'Cet adhérent ne sera plus proposé '
          'dans les listes d’adhérents actifs.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Désactiver'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Utilisateur non connecté'),
      ),
    );

    return;
  }

  try {
  await EnrollmentRepository()
      .deactivateEnrollmentsForMember(
    memberId: member.id,
    seasonId: '2026-2027',
    updatedBy: user.uid,
  );

  await MemberRepository().deactivateMember(
    member.id,
    user.uid,
  );

  if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
  } catch (error) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur lors de la désactivation : $error',
        ),
      ),
    );
  }
}

Future<void> _reactivateMember(
  BuildContext context,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Réactiver l’adhérent ?',
        ),
        content: Text(
          'Voulez-vous vraiment réactiver '
          '${member.fullName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Réactiver'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Utilisateur non connecté'),
      ),
    );

    return;
  }

  try {
    await MemberRepository().reactivateMember(
      member.id,
      user.uid,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
  } catch (error) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur lors de la réactivation : $error',
        ),
      ),
    );
  }
}

  @override
  Widget build(
  BuildContext context,
  WidgetRef ref,
)
 {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Fiche adhérent'),
actions: [
  IconButton(
    icon: const Icon(Icons.edit),
    tooltip: 'Modifier',
    onPressed: () async {
  final navigator = Navigator.of(context);

  final updatedMember =
      await navigator.push<Member>(
    MaterialPageRoute(
      builder: (context) =>
          MemberFormScreen(
        member: member,
      ),
    ),
  );

  if (!context.mounted) {
    return;
  }

  if (updatedMember != null) {
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            MemberDetailScreen(
          member: updatedMember,
        ),
      ),
    );
  }
},
  ),

PopupMenuButton<String>(
  onSelected: (value) {
  if (value == 'deactivate') {
    _deactivateMember(context);
  }

  if (value == 'reactivate') {
    _reactivateMember(context);
  }
},
  itemBuilder: (context) => [
    if (member.isActive)
      const PopupMenuItem<String>(
        value: 'deactivate',
        child: Text(
          "Désactiver l’adhérent",
        ),
      ),

    if (!member.isActive)
      const PopupMenuItem<String>(
        value: 'reactivate',
        child: Text(
          "Réactiver l’adhérent",
        ),
      ),
  ],
),
],
),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoSection(
            title: 'Identité',
            children: [
              _InfoRow(
                label: 'Nom',
                value: member.lastName,
              ),
              _InfoRow(
                label: 'Prénom',
                value: member.firstName,
              ),
              _InfoRow(
                label: 'Date de naissance',
                value: member.birthDate != null
                    ? _formatDate(member.birthDate!)
                    : 'Non renseignée',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Tennis',
            children: [
              _InfoRow(
                label: 'Licence FFT',
                value: member.licenseNumber,
              ),
            ],
          ),
          const SizedBox(height: 16),

_MemberGroupsSection(
  memberId: member.id,
),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Coordonnées',
            children: [
              _InfoRow(
                label: 'E-mail',
                value: member.email ?? 'Non renseigné',
              ),
              _InfoRow(
                label: 'Téléphone',
                value: member.phone ?? 'Non renseigné',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Gestion',
            children: [
              _InfoRow(
                label: 'Statut',
                value: member.isActive
                    ? 'Actif'
                    : 'Inactif',
              ),
              _InfoRow(
                label: 'Notes',
                value: member.notes ?? 'Aucune',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
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
      padding: const EdgeInsets.only(bottom: 8),
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

  class _MemberGroupsSection extends ConsumerWidget {
  final String memberId;

  const _MemberGroupsSection({
    required this.memberId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final enrollments =
        ref.watch(
      memberEnrollmentsProvider(memberId),
    );

    return _InfoSection(
      title: 'Groupes',
      children: [
        enrollments.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Text(
            'Erreur : $error',
          ),
          data: (enrollments) {
            if (enrollments.isEmpty) {
              return const _InfoRow(
                label: 'Inscription',
                value: 'Aucun groupe',
              );
            }

            return Column(
              children: enrollments.map(
                (enrollment) {
                  return FutureBuilder<Group?>(
                    future: GroupRepository()
                        .getGroup(
                      enrollment.groupId,
                    ),
                    builder: (
                      context,
                      snapshot,
                    ) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return _InfoRow(
                          label: 'Groupe',
                          value:
                              'Erreur : ${snapshot.error}',
                        );
                      }

                      final group = snapshot.data;

                      if (group == null) {
                        return _InfoRow(
                          label: 'Groupe',
                          value:
                              'Groupe introuvable',
                        );
                      }

                      return Padding(
  padding: const EdgeInsets.only(
    bottom: 8,
  ),
  child: Row(
    crossAxisAlignment:
        CrossAxisAlignment.center,
    children: [
      Expanded(
        child: _InfoRow(
          label: group.name,
          value:
              '${_dayOfWeekLabel(group.dayOfWeek)} '
              'à ${group.startTime}',
        ),
      ),

      const SizedBox(width: 8),

      TextButton.icon(
        onPressed: () async {
          final changed =
              await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MemberGroupTransferScreen(
                memberId: memberId,
                enrollment: enrollment,
                currentGroup: group,
              ),
            ),
          );

          if (changed == true) {
            ref.invalidate(
              memberEnrollmentsProvider(
                memberId,
              ),
            );
          }
        },
        icon: const Icon(
          Icons.swap_horiz,
        ),
        label: const Text(
          'Changer',
        ),
      ),
    ],
  ),
);
                    },
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }

  String _dayOfWeekLabel(int day) {
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
        return 'Jour inconnu';
    }
  }
}
