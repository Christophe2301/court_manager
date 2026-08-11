import 'package:flutter/material.dart';

import '../../../core/models/attendance.dart';

class AttendanceStatusChip extends StatelessWidget {
  final AttendanceStatus status;

  final ValueChanged<AttendanceStatus> onChanged;

  const AttendanceStatusChip({
    super.key,
    required this.status,
    required this.onChanged,
  });

  String get label {
    return _labelFor(status);
  }

  Color get color {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;

      case AttendanceStatus.absent:
        return Colors.red;

      case AttendanceStatus.excused:
        return Colors.orange;

      case AttendanceStatus.makeup:
        return Colors.blue;

      case AttendanceStatus.trial:
        return Colors.purple;

      case AttendanceStatus.guest:
        return Colors.teal;
    }
  }

  IconData get icon {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;

      case AttendanceStatus.absent:
        return Icons.cancel;

      case AttendanceStatus.excused:
        return Icons.event_busy;

      case AttendanceStatus.makeup:
        return Icons.autorenew;

      case AttendanceStatus.trial:
        return Icons.person_search;

      case AttendanceStatus.guest:
        return Icons.person_add;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Modifier le statut',
      child: PopupMenuButton<AttendanceStatus>(
        initialValue: status,
        onSelected: onChanged,
        tooltip: 'Modifier le statut',
        itemBuilder: (context) {
          return AttendanceStatus.values.map(
            (value) {
              return PopupMenuItem<AttendanceStatus>(
                value: value,
                child: Row(
                  children: [
                    Icon(
                      _iconFor(value),
                      size: 20,
                      color: _colorFor(value),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _labelFor(value),
                    ),
                  ],
                ),
              );
            },
          ).toList();
        },
        child: Chip(
          avatar: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
          ),
        ),
      ),
    );
  }

  String _labelFor(
    AttendanceStatus value,
  ) {
    switch (value) {
      case AttendanceStatus.present:
        return 'Présent';

      case AttendanceStatus.absent:
        return 'Absent';

      case AttendanceStatus.excused:
        return 'Excusé';

      case AttendanceStatus.makeup:
        return 'Rattrapage';

      case AttendanceStatus.trial:
        return 'Essai';

      case AttendanceStatus.guest:
        return 'Invité';
    }
  }

  IconData _iconFor(
    AttendanceStatus value,
  ) {
    switch (value) {
      case AttendanceStatus.present:
        return Icons.check_circle;

      case AttendanceStatus.absent:
        return Icons.cancel;

      case AttendanceStatus.excused:
        return Icons.event_busy;

      case AttendanceStatus.makeup:
        return Icons.autorenew;

      case AttendanceStatus.trial:
        return Icons.person_search;

      case AttendanceStatus.guest:
        return Icons.person_add;
    }
  }

  Color _colorFor(
    AttendanceStatus value,
  ) {
    switch (value) {
      case AttendanceStatus.present:
        return Colors.green;

      case AttendanceStatus.absent:
        return Colors.red;

      case AttendanceStatus.excused:
        return Colors.orange;

      case AttendanceStatus.makeup:
        return Colors.blue;

      case AttendanceStatus.trial:
        return Colors.purple;

      case AttendanceStatus.guest:
        return Colors.teal;
    }
  }
}

