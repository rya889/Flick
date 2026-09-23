import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';
import 'screens/shell.dart';
import 'services/catalog_store.dart';
import 'state/flick_controller.dart';
import 'theme/flick_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = CatalogStore();
  final controller = FlickController(store);
  await controller.bootstrap();
  runApp(FlickApp(controller: controller));
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
            home: const FlickShell(),
          );
        },
      ),
    );
  }
}
