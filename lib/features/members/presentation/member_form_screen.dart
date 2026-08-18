import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/member_repository.dart';
import '../../../core/models/member.dart';

class MemberFormScreen extends StatefulWidget {
  final Member? member;

  const MemberFormScreen({
    super.key,
    this.member,
  });

  @override
  State<MemberFormScreen> createState() =>
      _MemberFormScreenState();
}
class _MemberFormScreenState
    extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _birthDate;

@override
void initState() {
  super.initState();

  final member = widget.member;

  if (member == null) {
    return;
  }

  _lastNameController.text = member.lastName;
  _firstNameController.text = member.firstName;
  _licenseController.text = member.licenseNumber;
  _emailController.text = member.email ?? '';
  _phoneController.text = member.phone ?? '';
  _notesController.text = member.notes ?? '';

  _birthDate = member.birthDate;
}

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _licenseController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _birthDate = selectedDate;
      });
    }
  }

Future<void> _save() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
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

  final repository = MemberRepository();

  final licenseNumber =
      _licenseController.text.trim();

  final currentMember = widget.member;

  final exists =
      await repository.licenseNumberExists(
    licenseNumber,
    excludeMemberId: currentMember?.id,
  );

  if (exists) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Un adhérent possède déjà ce numéro de licence.',
        ),
      ),
    );

    return;
  }

  final now = DateTime.now();

  if (currentMember == null) {
    // -------------------------
    // CRÉATION
    // -------------------------

    final member = Member(
      id: repository.newMemberId(),
      licenseNumber: licenseNumber,
      firstName:
          _firstNameController.text.trim(),
      lastName:
          _lastNameController.text.trim(),
      birthDate: _birthDate,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      isActive: true,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
      createdBy: user.uid,
      updatedBy: user.uid,
    );

    await repository.createMember(member);

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    return;
  }

  // -------------------------
  // MODIFICATION
  // -------------------------

  final updatedMember = currentMember.copyWith(
    licenseNumber: licenseNumber,
    firstName:
        _firstNameController.text.trim(),
    lastName:
        _lastNameController.text.trim(),
    birthDate: _birthDate,
    email: _emailController.text.trim().isEmpty
        ? null
        : _emailController.text.trim(),
    phone: _phoneController.text.trim().isEmpty
        ? null
        : _phoneController.text.trim(),
    notes: _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim(),
    updatedAt: now,
    updatedBy: user.uid,
  );

  await repository.updateMember(
    updatedMember,
  );

  if (!mounted) {
    return;
  }

  Navigator.pop(
    context,
    updatedMember,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
  widget.member == null
      ? 'Nouvel adhérent'
      : 'Modifier l’adhérent',
),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _lastNameController,
              textCapitalization:
                  TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Nom *',
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

            TextFormField(
              controller: _firstNameController,
              textCapitalization:
                  TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Prénom *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Le prénom est obligatoire';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _licenseController,
              decoration: const InputDecoration(
                labelText: 'N° de licence FFT *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Le numéro de licence est obligatoire';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de naissance',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.calendar_month,
                  ),
                ),
                child: Text(
                  _birthDate == null
                      ? 'Non renseignée'
                      : _formatDate(_birthDate!),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                   child: Text(
  widget.member == null
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}