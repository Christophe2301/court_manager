import 'package:flutter/material.dart';

class WelcomeCard extends StatelessWidget {

  final String firstName;
  final String lastName;

  const WelcomeCard({
    super.key,
    required this.firstName,
    required this.lastName,
  });


  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 2,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              'Bonjour $firstName $lastName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Bienvenue dans CourtManager',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}