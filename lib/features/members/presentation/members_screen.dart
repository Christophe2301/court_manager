import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/member_provider.dart';
import 'member_form_screen.dart';
import 'member_detail_screen.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({
    super.key,
  });

  @override
  ConsumerState<MembersScreen> createState() =>
      _MembersScreenState();
}

class _MembersScreenState
    extends ConsumerState<MembersScreen> {
  bool _showInactive = false;

final TextEditingController _searchController =
    TextEditingController();

String _searchQuery = '';

@override
void dispose() {
  _searchController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    final members = _showInactive
        ? ref.watch(inactiveMembersProvider)
        : ref.watch(activeMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showInactive
              ? 'Adhérents inactifs'
              : 'Adhérents',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showInactive
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            tooltip: _showInactive
                ? 'Afficher les actifs'
                : 'Afficher les inactifs',
            onPressed: () {
              setState(() {
                _showInactive = !_showInactive;
              });
            },
          ),
        ],
      ),
      body: members.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Erreur : $error',
            ),
          ),
        ),
        data: (members) {
          if (members.isEmpty) {

            return Center(
              child: Text(
                _showInactive
                    ? 'Aucun adhérent inactif'
                    : 'Aucun adhérent actif',
              ),
            );
          }
            final query =
    _searchQuery.trim().toLowerCase();

final filteredMembers = query.isEmpty
    ? members
    : members.where((member) {
        final firstName =
            member.firstName.toLowerCase();

        final lastName =
            member.lastName.toLowerCase();

        final fullName =
            member.fullName.toLowerCase();

        final license =
            member.licenseNumber.toLowerCase();

        return firstName.contains(query) ||
            lastName.contains(query) ||
            fullName.contains(query) ||
            license.contains(query);
      }).toList();
          return Column(
  children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Rechercher un adhérent',
          hintText: 'Nom, prénom ou licence',
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Effacer',
                  icon: const Icon(
                    Icons.clear,
                  ),
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    ),

    if (filteredMembers.isEmpty)
      Expanded(
        child: Center(
          child: Text(
            'Aucun adhérent trouvé pour '
            '"${_searchController.text.trim()}".',
          ),
        ),
      )
    else
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
          itemCount: filteredMembers.length,
          itemBuilder: (context, index) {
            final member =
                filteredMembers[index];

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    member.isActive
                        ? Icons.person
                        : Icons.person_off,
                  ),
                ),
                title: Text(
                  member.fullName,
                ),
                subtitle: Text(
                  member.licenseNumber,
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MemberDetailScreen(
                        member: member,
                      ),
                    ),
                  );

                  if (!context.mounted) {
                    return;
                  }

                  ref.invalidate(
                    _showInactive
                        ? inactiveMembersProvider
                        : activeMembersProvider,
                  );
                },
              ),
            );
          },
        ),
      ),
  ],
);
        },
      ),
      floatingActionButton: _showInactive
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MemberFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Nouvel adhérent'),
            ),
    );
  }
}