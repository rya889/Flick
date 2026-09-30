import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../models/reader_sync.dart';
import '../state/flick_controller.dart';
import 'paywall_sheet.dart';
import 'sync_sheet.dart';

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
              leading: const Icon(Icons.sync),
              title: const Text('Sync library'),
              subtitle: Text(switch (c.syncTarget) {
                SyncTarget.device => 'This device',
                SyncTarget.googleDrive => 'Google Drive',
                SyncTarget.files => 'iCloud or Files',
              }),
              onTap: () {
                final host = Navigator.of(context).context;
                Navigator.pop(context);
                showSyncSheet(host);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Listen'),
              subtitle: const Text('Included with the reader'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(c.plusActive ? 'Flick Premium · active' : 'Flick Premium'),
              subtitle: Text(
                c.plusActive
                    ? '50 books · EPUB, TXT, and paste'
                    : 'Free · 2 books · TXT and paste. Premium adds EPUB and a larger library.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showPaywallSheet(
                context,
                reason: PaywallReason.settings,
              ),
            ),
            if (c.plusActive && c.plusService.demoActive)
              TextButton(
                onPressed: () => c.setPlusDemo(false),
                child: const Text('Turn off Premium on this device'),
              ),
            const SizedBox(height: 8),
            Text(
              'Page reader and follow-along share one place in the book.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
