import 'package:flutter/material.dart';
import '../auth/models/app_user.dart';
import '../attendance/attendance_screen.dart';
import 'course.dart';

class DashboardScreen extends StatelessWidget {
  final AppUser user;

  const DashboardScreen({
    super.key,
    required this.user,
  });

  static const courses = [
    Course(
      name: 'Mini Tennis',
      time: '15h30',
      playersCount: 12,
    ),
    Course(
      name: 'Adultes débutants',
      time: '18h00',
      playersCount: 8,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CourtManager 🎾'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour ${user.fullName}',
               style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Aujourd'hui",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];

                  return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AttendanceScreen(),
                            ),
                          );
                        },
                      title: Text(course.name),
                      subtitle: Text(
                        '${course.time} - ${course.playersCount} adhérents',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}