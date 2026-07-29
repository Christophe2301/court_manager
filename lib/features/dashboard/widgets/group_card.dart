import 'package:flutter/material.dart';

import '../../../core/models/group.dart';


class GroupCard extends StatelessWidget {

  final Group group;
  final VoidCallback onTap;


  const GroupCard({
    super.key,
    required this.group,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      elevation: 2,

      child: ListTile(

        title: Text(
          group.startTime,

          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 6),

            Text(
              group.name,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Row(
              children: [

                const Icon(
                  Icons.schedule,
                  size: 16,
                ),

                const SizedBox(width: 4),

                Text(
                  '${group.durationMinutes} minutes',
                ),
              ],
            ),
          ],
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap: onTap,
      ),
    );
  }
}