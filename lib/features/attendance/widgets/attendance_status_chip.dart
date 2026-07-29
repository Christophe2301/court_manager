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

    switch (status) {

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


  @override
  Widget build(BuildContext context) {

    return PopupMenuButton<AttendanceStatus>(

      initialValue: status,

      onSelected: onChanged,

      itemBuilder: (context) {

        return AttendanceStatus.values
            .map(
              (value) {

                return PopupMenuItem<AttendanceStatus>(
                  value: value,

                  child: Text(
                    _labelFor(value),
                  ),
                );

              },
            )
            .toList();
      },

      child: Chip(

        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),

        backgroundColor: color,
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
}