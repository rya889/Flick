import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/flick_controller.dart';
import 'paywall_sheet.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const SettingsSheet(),
  );
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final remaining = Duration(seconds: c.listenRemainingSeconds);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<ThemePreference>(
              segments: const [
                ButtonSegment(
                  value: ThemePreference.system,
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemePreference.light,
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemePreference.dark,
                  label: Text('Dark'),
                ),
              ],
              selected: {c.themePreference},
              onSelectionChanged: (set) => c.setThemePreference(set.first),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Listen today'),
              subtitle: Text(
                c.plusActive
                    ? 'Unlimited (Plus)'
                    : '${remaining.inMinutes} min left of 60',
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(c.plusActive ? 'Flick Plus · active' : 'Flick Plus'),
              subtitle: const Text(r'$6.99/mo · $49.99/yr'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showPaywallSheet(
                context,
                reason: PaywallReason.settings,
              ),
            ),
            if (c.plusActive)
              TextButton(
                onPressed: () => c.setPlusDemo(false),
                child: const Text('Turn off Plus demo'),
              ),
            const SizedBox(height: 8),
            Text(
              'Prototype · OS TTS · extractive TLDR · no accounts',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
