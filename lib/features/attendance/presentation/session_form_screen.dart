import 'package:flutter/material.dart';

import '../../../core/models/group.dart';
import '../../../core/models/session_model.dart';
import '../../groups/data/group_repository.dart';
import '../data/session_repository.dart';

class SessionFormScreen extends StatefulWidget {
  final String teacherId;

  const SessionFormScreen({
    super.key,
    required this.teacherId,
  });

  @override
  State<SessionFormScreen> createState() =>
      _SessionFormScreenState();
}

class _SessionFormScreenState
    extends State<SessionFormScreen> {
  final GroupRepository _groupRepository =
      GroupRepository();

  final SessionRepository _sessionRepository =
      SessionRepository();

  late Future<List<Group>> _groupsFuture;

  Group? _selectedGroup;

  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _groupsFuture = _groupRepository
        .watchGroupsForTeacher(widget.teacherId)
        .first;
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('fr', 'FR'),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedDate = selected;
    });
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _createSession() async {
    final group = _selectedGroup;

    if (group == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un groupe.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final session = SessionModel(
        id: '',
        groupId: group.id,
        teacherIds: group.teacherIds,
        date: _selectedDate,
        startTime: group.startTime,
        durationMinutes: group.durationMinutes,
        status: 'planned',
      );

      await _sessionRepository.createSession(
        session,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Séance créée avec succès.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la création : $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Créer une séance',
        ),
      ),
      body: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur lors du chargement '
                'des groupes : ${snapshot.error}',
              ),
            );
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return const Center(
              child: Text(
                'Aucun groupe disponible.',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<Group>(
                initialValue: _selectedGroup,
                decoration: const InputDecoration(
                  labelText: 'Groupe',
                  border: OutlineInputBorder(),
                ),
                items: groups.map(
                  (group) {
                    return DropdownMenuItem<Group>(
                      value: group,
                      child: Text(group.name),
                    );
                  },
                ).toList(),
                onChanged: (group) {
                  setState(() {
                    _selectedGroup = group;
                  });
                },
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                  ),
                  title: const Text('Date'),
                  subtitle: Text(
                    _formatDate(_selectedDate),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: _selectDate,
                ),
              ),

              const SizedBox(height: 12),

              if (_selectedGroup != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations de la séance',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Horaire : '
                          '${_selectedGroup!.startTime}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Durée : '
                          '${_selectedGroup!.durationMinutes} min',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Professeur(s) : '
                          '${_selectedGroup!.teacherIds.length}',
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Statut : Prévue',
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      _isSaving
                          ? null
                          : _createSession,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    _isSaving
                        ? 'Création...'
                        : 'Créer la séance',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}