import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/flick_controller.dart';
import 'paywall_sheet.dart';

enum HouseProPlacement { finish, settings, voiceTease }

/// v1 ads: house Pro soft prompts only — never during Listen/karaoke/Finish animation.
Future<void> showHouseProPrompt(
  BuildContext context, {
  required HouseProPlacement placement,
}) async {
  final c = context.read<FlickController>();
  if (c.plusActive) return;
  if (c.playing || c.showFinishCelebration) return;

  final title = switch (placement) {
    HouseProPlacement.finish => 'You finished a book',
    HouseProPlacement.settings => 'Flick Pro',
    HouseProPlacement.voiceTease => 'Natural Listen voices',
  };
  final body = switch (placement) {
    HouseProPlacement.finish =>
      'Pro unlocks unlimited Listen, premium voices, and EPUB — public-domain books stay free to read.',
    HouseProPlacement.settings =>
      'Pro is \$4.99/mo or \$29.99/yr. Voices and ad-free Listen included; chapters are never paywalled.',
    HouseProPlacement.voiceTease =>
      'Download a premium English voice in iOS Settings, or unlock Pro when cloud voices ship.',
  };

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                showPaywallSheet(context, reason: PaywallReason.settings);
              },
              child: const Text('See Pro'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    ),
  );
}
