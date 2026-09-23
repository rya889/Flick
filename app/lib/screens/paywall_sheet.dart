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

class PaywallSheet extends StatefulWidget {
  const PaywallSheet({super.key, required this.reason});
  final PaywallReason reason;

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<bool> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await action();
    if (!mounted) return;
    final c = context.read<FlickController>();
    setState(() {
      _busy = false;
      if (!ok) {
        _error = c.plusService.lastError ?? 'Purchase unavailable';
      }
    });
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final demo = c.plusService.usesDemo;
    final headline = switch (widget.reason) {
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
              onPressed: _busy ? null : () => _run(c.purchasePlusMonthly),
              child: Text(
                demo
                    ? r'Start Plus · $6.99/mo (demo)'
                    : r'Start Plus · $6.99/mo',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : () => _run(c.purchasePlusYearly),
              child: Text(
                demo
                    ? r'Yearly · $49.99 · 7-day trial (demo)'
                    : r'Yearly · $49.99 · 7-day trial',
              ),
            ),
            if (!demo) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : () => _run(c.restorePurchases),
                child: const Text('Restore purchases'),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: const Text('Not now'),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            if (c.plusActive)
              Text(
                demo
                    ? 'Plus demo is active on this device.'
                    : 'Flick Plus is active.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
