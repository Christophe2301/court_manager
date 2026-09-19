import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'web_reload_stub.dart'
    if (dart.library.js_interop) 'web_reload_browser.dart';

class WebVersionChecker extends StatefulWidget {
  final Widget child;

  const WebVersionChecker({super.key, required this.child});

  @override
  State<WebVersionChecker> createState() => _WebVersionCheckerState();
}

class _WebVersionCheckerState extends State<WebVersionChecker> {
  Timer? _timer;
  bool _dialogDisplayed = false;
  String? _runningVersion;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _initializeVersionChecker();
    }
  }

  Future<void> _initializeVersionChecker() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      _runningVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      if (!mounted) {
        return;
      }

      await _checkVersion();

      _timer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _checkVersion(),
      );
    } catch (_) {
      // Un problème de détection de version ne doit jamais
      // empêcher CourtManager de fonctionner.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVersion() async {
    if (!kIsWeb || _dialogDisplayed || _runningVersion == null) {
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
          serverVersion == _runningVersion) {
        debugPrint(
          'Version CourtManager : '
          'application=$_runningVersion, '
          'serveur=$serverVersion',
        );
        return;
      }
      debugPrint(
        'Version CourtManager : '
        'application=$_runningVersion, '
        'serveur=$serverVersion',
      );
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
