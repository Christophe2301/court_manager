import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/group.dart';
import '../../teachers/providers/teacher_provider.dart';
import '../../auth/models/app_user.dart';
import '../data/group_repository.dart';

class GroupFormScreen extends ConsumerStatefulWidget {
  final Group? group;

  const GroupFormScreen({
    super.key,
    this.group,
  });

  @override
  ConsumerState<GroupFormScreen> createState() =>
      _GroupFormScreenState();
}

class _GroupFormScreenState
    extends ConsumerState<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _seasonController =
      TextEditingController(
    text: '2026-2027',
  );

  final _startTimeController =
      TextEditingController();

  GroupType _type = GroupType.course;

  int _dayOfWeek = 1;

  int _durationMinutes = 60;

  final List<String> _selectedTeacherIds = [];

@override
void initState() {
  super.initState();

  final group = widget.group;

  if (group == null) {
    return;
  }

  _nameController.text = group.name;
  _seasonController.text = group.seasonId;
  _startTimeController.text = group.startTime;

  _type = group.type;
  _dayOfWeek = group.dayOfWeek;
  _durationMinutes = group.durationMinutes;

  _selectedTeacherIds.addAll(
    group.teacherIds,
  );
}

  @override
  void dispose() {
    _nameController.dispose();
    _seasonController.dispose();
    _startTimeController.dispose();

    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final parts =
        _startTimeController.text.split(':');

    TimeOfDay initialTime =
        const TimeOfDay(
      hour: 18,
      minute: 0,
    );

    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour != null && minute != null) {
        initialTime = TimeOfDay(
          hour: hour,
          minute: minute,
        );
      }
    }

    final selectedTime =
        await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final hour =
        selectedTime.hour.toString().padLeft(
              2,
              '0',
            );

    final minute =
        selectedTime.minute.toString().padLeft(
              2,
              '0',
            );

    setState(() {
      _startTimeController.text =
          '$hour:$minute';
    });
  }

Future<void> _save() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_selectedTeacherIds.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Sélectionnez au moins un professeur',
        ),
      ),
    );

    return;
  }

  final currentUser =
      FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Utilisateur non connecté',
        ),
      ),
    );

    return;
  }

  final now = DateTime.now();

  final existingGroup = widget.group;

  final Group group;

  if (existingGroup == null) {
    final groupId = FirebaseFirestore
        .instance
        .collection('groups')
        .doc()
        .id;

    group = Group(
      id: groupId,
      name: _nameController.text.trim(),
      type: _type,
      seasonId: _seasonController.text.trim(),
      dayOfWeek: _dayOfWeek,
      startTime: _startTimeController.text.trim(),
      durationMinutes: _durationMinutes,
      teacherIds: List<String>.from(
        _selectedTeacherIds,
      ),
      isActive: true,
      createdAt: now,
      updatedAt: now,
      createdBy: currentUser.uid,
      updatedBy: currentUser.uid,
    );
  } else {
    group = existingGroup.copyWith(
      name: _nameController.text.trim(),
      type: _type,
      seasonId: _seasonController.text.trim(),
      dayOfWeek: _dayOfWeek,
      startTime: _startTimeController.text.trim(),
      durationMinutes: _durationMinutes,
      teacherIds: List<String>.from(
        _selectedTeacherIds,
      ),
      updatedAt: now,
      updatedBy: currentUser.uid,
    );
  }

  try {
    final repository = GroupRepository();

    if (existingGroup == null) {
      await repository.createGroup(group);
    } else {
      await repository.updateGroup(group);
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existingGroup == null
              ? 'Groupe créé avec succès'
              : 'Groupe modifié avec succès',
        ),
      ),
    );

    Navigator.pop(context, group);
  } catch (e) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existingGroup == null
              ? 'Erreur lors de la création : $e'
              : 'Erreur lors de la modification : $e',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final teachers =
        ref.watch(activeTeachersProvider);

    return Scaffold(
      appBar: AppBar(
title: Text(
  widget.group == null
      ? 'Nouveau groupe'
      : 'Modifier le groupe',
),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du groupe *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Le nom est obligatoire';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<GroupType>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Type de groupe',
                border: OutlineInputBorder(),
              ),
              items: GroupType.values
                  .map(
                    (type) =>
                        DropdownMenuItem<GroupType>(
                      value: type,
                      child: Text(
                        _groupTypeLabel(type),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _type = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _seasonController,
              decoration: const InputDecoration(
                labelText: 'Saison *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'La saison est obligatoire';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: _dayOfWeek,
              decoration: const InputDecoration(
                labelText: 'Jour',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                7,
                (index) {
                  final day = index + 1;

                  return DropdownMenuItem<int>(
                    value: day,
                    child: Text(
                      _dayOfWeekLabel(day),
                    ),
                  );
                },
              ),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _dayOfWeek = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _startTimeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Heure de début',
                border: OutlineInputBorder(),
                suffixIcon: Icon(
                  Icons.access_time,
                ),
              ),
              onTap: _selectStartTime,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return "L'heure est obligatoire";
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: _durationMinutes,
              decoration: const InputDecoration(
                labelText: 'Durée',
                border: OutlineInputBorder(),
              ),
              items: const [
  DropdownMenuItem<int>(
    value: 45,
    child: Text('45 minutes'),
  ),
  DropdownMenuItem<int>(
    value: 60,
    child: Text('1 heure'),
  ),
  DropdownMenuItem<int>(
    value: 90,
    child: Text('1 heure 30'),
  ),
],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _durationMinutes = value;
                });
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Professeur(s)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            teachers.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Text(
                'Erreur : $error',
              ),
              data: (teachers) {
                if (teachers.isEmpty) {
                  return const Text(
                    'Aucun professeur actif',
                  );
                }

                return Column(
                  children: teachers
                      .map(
                        (AppUser teacher) {
                          final selected =
                              _selectedTeacherIds
                                  .contains(
                            teacher.uid,
                          );

                          return CheckboxListTile(
                            value: selected,
                            title: Text(
                              teacher.fullName,
                            ),
                            subtitle: Text(
                              teacher.email,
                            ),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedTeacherIds
                                      .add(
                                    teacher.uid,
                                  );
                                } else {
                                  _selectedTeacherIds
                                      .remove(
                                    teacher.uid,
                                  );
                                }
                              });
                            },
                          );
                        },
                      )
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Annuler',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
  widget.group == null
      ? 'Enregistrer'
      : 'Enregistrer les modifications',
),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _groupTypeLabel(
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

  String _dayOfWeekLabel(
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
}
