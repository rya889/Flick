import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../models/reader_sync.dart';
import '../state/flick_controller.dart';
import 'house_pro_prompt.dart';
import 'paywall_sheet.dart';
import 'sync_sheet.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const SettingsSheet(),
  );
}

/// Modal sheets cannot stack another sheet on iOS — pop settings, then present.
Future<void> _openProFromSettings(BuildContext sheetContext) async {
  final root = Navigator.of(sheetContext, rootNavigator: true).context;
  Navigator.pop(sheetContext);
  await Future<void>.delayed(Duration.zero);
  await showPaywallSheet(root, reason: PaywallReason.settings);
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
            const SizedBox(height: 6),
            Text(
              'Reading paper follows Light/Dark until you change it in the reader.',
              style: Theme.of(context).textTheme.bodySmall,
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
              title: Text(c.plusActive ? 'Flick Pro · active' : 'Flick Pro'),
              subtitle: Text(
                c.plusActive
                    ? '50 books · EPUB · unlimited Listen · voices'
                    : r'Free · 2 imports · 60 min Listen/day. Pro $4.99/mo or $29.99/yr.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openProFromSettings(context),
            ),
            if (!c.plusActive && c.listenVoiceIsBasic)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.record_voice_over_outlined),
                title: const Text('Natural Listen voices'),
                subtitle: const Text('Pro perk — public-domain text stays free'),
                onTap: () async {
                  final root = Navigator.of(context, rootNavigator: true).context;
                  Navigator.pop(context);
                  await Future<void>.delayed(Duration.zero);
                  await showHouseProPrompt(
                    root,
                    placement: HouseProPlacement.voiceTease,
                  );
                },
              ),
            if (c.plusActive && c.plusService.demoActive)
              TextButton(
                onPressed: () => c.setPlusDemo(false),
                child: const Text('Turn off Pro on this device'),
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
