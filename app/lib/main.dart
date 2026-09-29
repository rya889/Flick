import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';
import 'screens/shell.dart';
import 'services/catalog_store.dart';
import 'state/flick_controller.dart';
import 'theme/flick_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught async error: $error\n$stack');
    return true;
  };

  await runZonedGuarded(() async {
    final store = CatalogStore();
    final controller = FlickController(store);
    runApp(FlickApp(controller: controller));
    try {
      await controller.bootstrap();
    } catch (e, st) {
      debugPrint('Flick bootstrap failed: $e\n$st');
      controller.reportBootstrapError(e);
    }
  }, (error, stack) {
    debugPrint('Flick zone error: $error\n$stack');
  });
}

class FlickApp extends StatelessWidget {
  const FlickApp({super.key, required this.controller});

  final FlickController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<FlickController>(
        builder: (context, c, _) {
          final mode = switch (c.themePreference) {
            ThemePreference.system => ThemeMode.system,
            ThemePreference.light => ThemeMode.light,
            ThemePreference.dark => ThemeMode.dark,
          };
          return MaterialApp(
            title: 'Flick',
            debugShowCheckedModeBanner: false,
            theme: buildFlickTheme(Brightness.light),
            darkTheme: buildFlickTheme(Brightness.dark),
            themeMode: mode,
            home: c.bootstrapError != null
                ? _BootstrapError(message: c.bootstrapError!)
                : const FlickShell(),
          );
        },
      ),
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Flick failed to start',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'On web, ensure sqlite3.wasm and drift_worker.js are in app/web/. '
                'Prefer flutter run on iOS/Android for the full prototype.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
