import 'package:flutter/material.dart';

import '../../members/presentation/members_screen.dart';
import '../../teachers/presentation/teachers_screen.dart';

class AdministrationScreen extends StatelessWidget {
  const AdministrationScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Adhérents'),
              subtitle: const Text(
                'Gérer les adhérents du club',
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MembersScreen(),
                  ),
                );
              },
            ),
          ),
          Card(
  child: ListTile(
    leading: const Icon(Icons.school),
    title: const Text('Professeurs'),
    subtitle: const Text(
      'Gérer les professeurs du club',
    ),
    trailing: const Icon(
      Icons.chevron_right,
    ),
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const TeachersScreen(),
    ),
  );
},
  ),
),
        ],
      ),
    );
  }
}