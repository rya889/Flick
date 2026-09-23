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
    final health = c.tldrHealth;
    final providers = health == null
        ? 'checking…'
        : health.anyProvider
            ? [
                if (health.groq) 'Groq',
                if (health.gemini) 'Gemini',
                if (health.gateway) 'Gateway',
              ].join(' · ')
            : 'no AI keys on server';

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
              subtitle: Text(
                c.plusService.usesDemo
                    ? r'$6.99/mo · $49.99/yr · demo / web'
                    : r'$6.99/mo · $49.99/yr · RevenueCat',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showPaywallSheet(
                context,
                reason: PaywallReason.settings,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('AI TLDR proxy'),
              subtitle: Text(providers),
            ),
            if (c.plusActive && c.plusService.demoActive)
              TextButton(
                onPressed: () => c.setPlusDemo(false),
                child: const Text('Turn off Plus demo'),
              ),
            const SizedBox(height: 8),
            Text(
              'Local-first · OS TTS · Plus gates AI TLDR',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
