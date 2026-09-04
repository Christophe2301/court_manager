import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/models/group.dart';
import '../../../core/models/session_model.dart';
import '../../auth/models/app_user.dart';
import '../../groups/data/group_repository.dart';
import '../data/session_repository.dart';

class SessionFormScreen extends StatefulWidget {
  final String? teacherId;

  const SessionFormScreen({
    super.key,
    this.teacherId,
  });

  bool get isAdminMode => teacherId == null;

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

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  late Future<List<Group>> _groupsFuture;

  Group? _selectedGroup;

  DateTime _selectedDate = DateTime.now();

  List<AppUser> _teachers = [];

  final Set<String> _selectedTeacherIds =
      <String>{};

  bool _isLoadingTeachers = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.isAdminMode) {
      _groupsFuture =
          _groupRepository.watchActiveGroups().first;

      _loadTeachers();
    } else {
      _groupsFuture =
          _groupRepository
              .watchGroupsForTeacher(
                widget.teacherId!,
                '2026-2027',
              )
              .first;

      _selectedTeacherIds.add(
        widget.teacherId!,
      );
    }
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoadingTeachers = true;
    });

    try {
      final snapshot = await _firestore
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

      final teachers = snapshot.docs
          .map(
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
                role:
                    AppUserRole.teacher,
                active:
                    data['active'] ?? true,
              );
            },
          )
          .toList();

      teachers.sort(
        (a, b) =>
            a.lastName.compareTo(
          b.lastName,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _teachers = teachers;
        _isLoadingTeachers = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingTeachers = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement '
            'des professeurs : $error',
          ),
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('fr', 'FR'),
    );

    if (selected == null || !mounted) {
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

  void _onGroupChanged(Group? group) {
    setState(() {
      _selectedGroup = group;

      if (group == null) {
        return;
      }

      if (widget.isAdminMode) {
        _selectedTeacherIds
          ..clear()
          ..addAll(
            group.teacherIds,
          );
      } else {
        _selectedTeacherIds
          ..clear()
          ..add(
            widget.teacherId!,
          );
      }
    });
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final group = _selectedGroup;

    if (group == null) {
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
            'Veuillez sélectionner au moins '
            'un professeur.',
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
        seasonId: group.seasonId,
        teacherIds:
            _selectedTeacherIds.toList(),
        date: _selectedDate,
        startTime: group.startTime,
        durationMinutes:
            group.durationMinutes,
        status: 'planned',
      );

      await _sessionRepository
          .createSession(
        session,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la création : '
            '$error',
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

  String _teacherName(
    AppUser teacher,
  ) {
    return teacher.fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAdminMode
              ? 'Créer une séance'
              : 'Créer une séance',
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
              child:
                  CircularProgressIndicator(),
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

          final groups =
              snapshot.data ?? [];

          if (groups.isEmpty) {
            return const Center(
              child: Text(
                'Aucun groupe disponible.',
              ),
            );
          }

          return Form(
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
                  items: groups.map(
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

                const SizedBox(height: 20),

                Card(
                  child: ListTile(
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
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: _selectDate,
                  ),
                ),

                const SizedBox(height: 16),

                if (widget.isAdminMode) ...[
                  const Text(
                    'Professeur(s)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (_isLoadingTeachers)
                    const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  else if (_teachers.isEmpty)
                    const Text(
                      'Aucun professeur actif.',
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
                          title: Text(
                            _teacherName(
                              teacher,
                            ),
                          ),
                          value: selected,
                          onChanged: (value) {
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

                  const SizedBox(height: 16),
                ],

                if (_selectedGroup != null)
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'Informations de la séance',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          Text(
                            'Horaire : '
                            '${_selectedGroup!.startTime}',
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            'Durée : '
                            '${_selectedGroup!.durationMinutes} min',
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            'Professeur(s) : '
                            '${_selectedTeacherIds.length}',
                          ),

                          const SizedBox(
                            height: 6,
                          ),

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
                  child:
                      ElevatedButton.icon(
                    onPressed: _isSaving
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
                        : const Icon(
                            Icons.add,
                          ),
                    label: Text(
                      _isSaving
                          ? 'Création...'
                          : 'Créer la séance',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}