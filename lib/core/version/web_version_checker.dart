import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'web_reload_stub.dart'
    if (dart.library.js_interop) 'web_reload_browser.dart';

class WebVersionChecker extends StatefulWidget {
  final Widget child;

  const WebVersionChecker({super.key, required this.child});

  @override
  State<WebVersionChecker> createState() => _WebVersionCheckerState();
}

class _WebVersionCheckerState extends State<WebVersionChecker> {
  static const String _currentVersion = '1.0.0+3';

  Timer? _timer;
  bool _dialogDisplayed = false;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkVersion());

      _timer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _checkVersion(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVersion() async {
    if (!kIsWeb || _dialogDisplayed) {
      return;
    }

    try {
      final uri = Uri.parse(
        '/version.json?t=${DateTime.now().millisecondsSinceEpoch}',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return;
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        return;
      }

      final version = data['version']?.toString();
      final buildNumber = data['build_number']?.toString();

      final serverVersion = version != null && buildNumber != null
          ? '$version+$buildNumber'
          : version;

      if (serverVersion == null ||
          serverVersion.isEmpty ||
          serverVersion == _currentVersion) {
        return;
      }

      if (!mounted) {
        return;
      }

      _dialogDisplayed = true;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Nouvelle version disponible'),
            content: const Text(
              'Une mise à jour de CourtManager '
              'est disponible.',
            ),
            actions: [
              FilledButton.icon(
                onPressed: reloadWebApp,
                icon: const Icon(Icons.refresh),
                label: const Text('Mettre à jour'),
              ),
            ],
          );
        },
      );

      _dialogDisplayed = false;
    } catch (_) {
      // Une erreur réseau ne doit jamais bloquer
      // l'utilisation de CourtManager.
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
