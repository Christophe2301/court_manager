import 'package:flutter/material.dart';

import 'theme.dart';

class CourtManagerApp extends StatelessWidget {
  const CourtManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CourtManager',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const Scaffold(
        body: Center(
          child: Text(
            '🎾 CourtManager',
            style: TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}