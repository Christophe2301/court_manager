import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/group.dart';
import '../../../core/models/session_model.dart';
import '../../auth/models/app_user.dart';
import '../../groups/data/group_repository.dart';
import '../data/session_repository.dart';

class SessionEditScreen extends StatefulWidget {
  final SessionModel session;

  const SessionEditScreen({
    super.key,
    required this.session,
  });

  @override
  State<SessionEditScreen> createState() =>
      _SessionEditScreenState();
}

class _SessionEditScreenState
    extends State<SessionEditScreen> {
  final SessionRepository _sessionRepository =
      SessionRepository();

  final GroupRepository _groupRepository =
      GroupRepository();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _selectedDuration;

  Group? _selectedGroup;

  List<Group> _groups = [];
  List<AppUser> _teachers = [];

  final Set<String> _selectedTeacherIds =
      <String>{};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.session.date;

    _selectedTime = _parseTime(
      widget.session.startTime,
    );

    _selectedDuration =
        widget.session.durationMinutes;

    _selectedTeacherIds.addAll(
      widget.session.teacherIds,
    );

    _loadData();
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');

    if (parts.length != 2) {
      return const TimeOfDay(
        hour: 18,
        minute: 0,
      );
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return const TimeOfDay(
        hour: 18,
        minute: 0,
      );
    }

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _loadData() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'Utilisateur non connecté.',
        );
      }

      final userDoc = await _firestore
    .collection('users')
    .doc(user.uid)
    .get();

final userData = userDoc.data();

final isAdmin =
    userData?['role'] == 'admin';

final groups = isAdmin
    ? await _groupRepository
        .watchActiveGroups()
        .first
    : await _groupRepository
        .watchGroupsForTeacher(
          user.uid,
          widget.session.seasonId,
        )
        .first;

      final teacherSnapshot = await _firestore
          .collection('users')
          .where(
            'role',
            isEqualTo: 'teacher',
          )
          .where(
            'active',
            isEqualTo: true,
          )
          .get();

      final teachers =
          teacherSnapshot.docs.map(
        (doc) {
          final data = doc.data();

          return AppUser(
            uid: doc.id,
            firstName:
                data['firstName'] ?? '',
            lastName:
                data['lastName'] ?? '',
            email:
                data['email'] ?? '',
            role: AppUserRole.teacher,
            active:
                data['active'] ?? true,
          );
        },
      ).toList();

      Group? selectedGroup;

      for (final group in groups) {
        if (group.id ==
            widget.session.groupId) {
          selectedGroup = group;
          break;
        }
      }

      if (selectedGroup != null &&
          _selectedTeacherIds.isEmpty) {
        _selectedTeacherIds.addAll(
          selectedGroup.teacherIds,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _groups = groups;
        _teachers = teachers;
        _selectedGroup = selectedGroup;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement : $error',
          ),
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );

    if (date == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time == null || !mounted) {
      return;
    }

    setState(() {
      _selectedTime = time;
    });
  }

  void _onGroupChanged(Group? group) {
    if (group == null) {
      return;
    }

    setState(() {
      _selectedGroup = group;

      _selectedDuration =
          group.durationMinutes;

      _selectedTeacherIds
        ..clear()
        ..addAll(group.teacherIds);

      _selectedTime =
          _parseTime(group.startTime);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un groupe.',
          ),
        ),
      );

      return;
    }

    if (_selectedTeacherIds.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner au moins un professeur.',
          ),
        ),
      );

      return;
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Utilisateur non connecté.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedSession =
          SessionModel(
        id: widget.session.id,
        groupId: _selectedGroup!.id,
        seasonId: widget.session.seasonId,
        teacherIds:
            _selectedTeacherIds.toList(),
        date: _selectedDate,
        startTime:
            _formatTime(_selectedTime),
        durationMinutes:
            _selectedDuration,
        status: widget.session.status,
      );

      await _sessionRepository
          .updateSession(
        updatedSession,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Séance modifiée avec succès.',
          ),
        ),
      );

      Navigator.of(context).pop(
        updatedSession,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la modification : $error',
          ),
        ),
      );
    }
  }

  String _teacherName(AppUser teacher) {
    return teacher.fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier la séance',
        ),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding:
                    const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<Group>(
                    initialValue:
                        _selectedGroup,
                    decoration:
                        const InputDecoration(
                      labelText: 'Groupe',
                      border:
                          OutlineInputBorder(),
                    ),
                    items: _groups.map(
                      (group) {
                        return DropdownMenuItem<
                            Group>(
                          value: group,
                          child:
                              Text(group.name),
                        );
                      },
                    ).toList(),
                    onChanged:
                        _onGroupChanged,
                    validator: (value) {
                      if (value == null) {
                        return 'Sélectionnez un groupe.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today,
                    ),
                    title:
                        const Text('Date'),
                    subtitle: Text(
                      _formatDate(
                        _selectedDate,
                      ),
                    ),
                    trailing:
                        const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: _selectDate,
                  ),

                  const Divider(),

                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: const Icon(
                      Icons.schedule,
                    ),
                    title:
                        const Text('Heure'),
                    subtitle: Text(
                      _formatTime(
                        _selectedTime,
                      ),
                    ),
                    trailing:
                        const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: _selectTime,
                  ),

                  const Divider(),

                  DropdownButtonFormField<int>(
                    initialValue:
                        _selectedDuration,
                    decoration:
                        const InputDecoration(
                      labelText: 'Durée',
                      border:
                          OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 60,
                        child:
                            Text('1 heure'),
                      ),
                      DropdownMenuItem(
                        value: 90,
                        child:
                            Text('1 h 30'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedDuration =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(
                    'Professeur(s)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  if (_teachers.isEmpty)
                    const Text(
                      'Aucun professeur disponible.',
                    )
                  else
                    ..._teachers.map(
                      (teacher) {
                        final selected =
                            _selectedTeacherIds
                                .contains(
                          teacher.uid,
                        );

                        return CheckboxListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          value: selected,
                          title: Text(
                            _teacherName(
                              teacher,
                            ),
                          ),
                          onChanged:
                              (value) {
                            setState(() {
                              if (value ==
                                  true) {
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
                    ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    height: 50,
                    child:
                        ElevatedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.save,
                            ),
                      label: Text(
                        _isSaving
                            ? 'Enregistrement...'
                            : 'Enregistrer',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}