import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/member_repository.dart';
import 'member_form_screen.dart';
import '../../../core/models/member.dart';

class MemberDetailScreen extends StatelessWidget {
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
    builder: (context) {
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
              Navigator.pop(context, false);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
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
        content: Text(
          'Utilisateur non connecté',
        ),
      ),
    );

    return;
  }

  try {
    final repository = MemberRepository();

    await repository.deactivateMember(
      member.id,
      user.uid,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Fiche adhérent'),
actions: [
  IconButton(
    icon: const Icon(Icons.edit),
    tooltip: 'Modifier',
    onPressed: () async {
      final updatedMember =
          await Navigator.push<Member>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MemberFormScreen(
            member: member,
          ),
        ),
      );

      if (updatedMember != null &&
          context.mounted) {
        Navigator.pushReplacement(
          context,
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
    onSelected: (value) async {
      if (value == 'deactivate') {
        await _deactivateMember(context);
      }
    },
    itemBuilder: (context) => [
      const PopupMenuItem<String>(
        value: 'deactivate',
        child: Text(
          'Désactiver l’adhérent',
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