import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/member.dart';
import '../../members/providers/member_provider.dart';

class AddMemberToGroupScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String seasonId;

  const AddMemberToGroupScreen({
    super.key,
    required this.groupId,
    required this.seasonId,
  });

  @override
  ConsumerState<AddMemberToGroupScreen> createState() =>
      _AddMemberToGroupScreenState();
}

class _AddMemberToGroupScreenState
    extends ConsumerState<AddMemberToGroupScreen> {
  final _searchController =
      TextEditingController();

  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Member member) {
    final search =
        _searchText.trim().toLowerCase();

    if (search.isEmpty) {
      return true;
    }

    return member.firstName
            .toLowerCase()
            .contains(search) ||
        member.lastName
            .toLowerCase()
            .contains(search) ||
        member.licenseNumber
            .toLowerCase()
            .contains(search);
  }

  @override
  Widget build(BuildContext context) {
    final members =
        ref.watch(activeMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un adhérent',
        ),
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
          final filteredMembers = members
              .where(_matchesSearch)
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Rechercher un adhérent',
                    hintText:
                        'Nom, prénom ou numéro de licence',
                    prefixIcon: Icon(
                      Icons.search,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                ),
              ),

              Expanded(
                child: filteredMembers.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun adhérent trouvé',
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        itemCount:
                            filteredMembers.length,
                        itemBuilder:
                            (context, index) {
                          final Member member =
                              filteredMembers[index];

                          return Card(
                            child: ListTile(
                              leading:
                                  const CircleAvatar(
                                child: Icon(
                                  Icons.person,
                                ),
                              ),
                              title: Text(
                                member.fullName,
                              ),
                              subtitle: Text(
                                member.licenseNumber,
                              ),
                              trailing:
                                  const Icon(
                                Icons.chevron_right,
                              ),
                              onTap: () {
                                Navigator.pop(
                                  context,
                                  member,
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
    );
  }
}