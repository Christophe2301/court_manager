import 'package:flutter/material.dart';

class TodaySummaryCard extends StatelessWidget {

  final int sessionCount;

  const TodaySummaryCard({
    super.key,
    required this.sessionCount,
  });


  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 2,

      child: ListTile(

        leading: const Icon(
          Icons.today,
        ),

        title: const Text(
          "Aujourd'hui",
        ),

        subtitle: Text(
          '$sessionCount séance(s) prévue(s)',
        ),
      ),
    );
  }
}