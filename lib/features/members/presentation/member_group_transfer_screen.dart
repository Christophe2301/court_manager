import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/enrollment.dart';
import '../../../core/models/group.dart';
import '../../enrollments/data/enrollment_repository.dart';
import '../../groups/data/group_repository.dart';

class MemberGroupTransferScreen extends StatefulWidget {
  final String memberId;
  final Enrollment enrollment;
  final Group currentGroup;

  const MemberGroupTransferScreen({
    super.key,
    required this.memberId,
    required this.enrollment,
    required this.currentGroup,
  });

  @override
  State<MemberGroupTransferScreen> createState() =>
      _MemberGroupTransferScreenState();
}

class _MemberGroupTransferScreenState
    extends State<MemberGroupTransferScreen> {
  final GroupRepository _groupRepository =
      GroupRepository();

  final EnrollmentRepository _enrollmentRepository =
      EnrollmentRepository();

  late Future<List<Group>> _groupsFuture;

  Group? _selectedGroup;

  DateTime _transferDate = DateTime.now();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _groupsFuture =
        _groupRepository.watchActiveGroups().first;
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _dayLabel(int day) {
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

  Future<void> _selectTransferDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _transferDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('fr', 'FR'),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _transferDate = selected;
    });
  }

  Future<void> _transfer() async {
    final selectedGroup =
        _selectedGroup;

    if (selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un nouveau groupe.',
          ),
        ),
      );

      return;
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Utilisateur non connecté.',
          ),
        ),
      );

      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirmer le changement de groupe ?',
          ),
          content: Text(
            '${widget.currentGroup.name}\n'
            '→ ${selectedGroup.name}\n\n'
            'Date d’effet : '
            '${_formatDate(_transferDate)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Annuler',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Changer',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _enrollmentRepository
          .transferEnrollment(
        memberId: widget.memberId,
        fromGroupId:
            widget.currentGroup.id,
        toGroupId:
            selectedGroup.id,
        seasonId:
            widget.enrollment.seasonId,
        transferDate:
            _transferDate,
        updatedBy:
            user.uid,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Changement de groupe effectué.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du changement de groupe : '
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Changer de groupe',
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

          final groups =
              (snapshot.data ?? [])
                  .where(
                    (group) =>
                        group.id !=
                        widget.currentGroup.id,
                  )
                  .toList();

          groups.sort((a, b) {
            final dayComparison =
                a.dayOfWeek.compareTo(
              b.dayOfWeek,
            );

            if (dayComparison != 0) {
              return dayComparison;
            }

            return a.startTime.compareTo(
              b.startTime,
            );
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Groupe actuel',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.currentGroup.name,
                      ),
                      Text(
                        '${_dayLabel(widget.currentGroup.dayOfWeek)} '
                        'à ${widget.currentGroup.startTime}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<Group>(
                initialValue:
                    _selectedGroup,
                isExpanded: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Nouveau groupe',
                  border:
                      OutlineInputBorder(),
                ),
                items: groups.map(
                  (group) {
                    return DropdownMenuItem<Group>(
                      value: group,
                      child: Text(
                        '${group.name} — '
                        '${_dayLabel(group.dayOfWeek)} '
                        '${group.startTime}',
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),
                onChanged: (group) {
                  setState(() {
                    _selectedGroup = group;
                  });
                },
              ),

              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                  ),
                  title: const Text(
                    'Date du changement',
                  ),
                  subtitle: Text(
                    _formatDate(
                      _transferDate,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap:
                      _selectTransferDate,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      _isSaving
                          ? null
                          : _transfer,
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
                          Icons.swap_horiz,
                        ),
                  label: Text(
                    _isSaving
                        ? 'Changement...'
                        : 'Changer de groupe',
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