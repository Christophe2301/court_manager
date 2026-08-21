import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/auth/presentation/auth_gate.dart';
import 'theme.dart';

class CourtManagerApp extends StatelessWidget {
  const CourtManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CourtManager',
      debugShowCheckedModeBanner: false,
      theme: appTheme,

      locale: const Locale('fr', 'FR'),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('fr', 'FR'),
      ],

      home: const AuthGate(),
    );
  }
}