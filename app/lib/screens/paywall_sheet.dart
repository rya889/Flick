import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/flick_controller.dart';

enum PaywallReason { listenCap, aiTldr, settings }

Future<void> showPaywallSheet(
  BuildContext context, {
  required PaywallReason reason,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => PaywallSheet(reason: reason),
  );
}

class PaywallSheet extends StatelessWidget {
  const PaywallSheet({super.key, required this.reason});
  final PaywallReason reason;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final headline = switch (reason) {
      PaywallReason.listenCap => 'Keep listening',
      PaywallReason.aiTldr => 'Unlock AI TLDR',
      PaywallReason.settings => 'Flick Plus',
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(headline, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'The anti-doomscroll reader.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Plus includes AI TLDR (Condense, Summary, Quotes) and unlimited Listen. Bounce stays free.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                await c.setPlusDemo(true);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text(r'Start Plus · $6.99/mo (demo)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                await c.setPlusDemo(true);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text(r'Yearly · $49.99 · 7-day trial (demo)'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not now'),
            ),
            if (c.plusActive)
              Text(
                'Plus demo is active on this device.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
