import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/flick_controller.dart';

enum PaywallReason { listenCap, libraryCap, epub, settings }

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
      PaywallReason.listenCap => 'Listen',
      PaywallReason.libraryCap => 'Library is full',
      PaywallReason.epub => 'EPUB is Premium',
      PaywallReason.settings => 'Flick Premium',
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
              'Free includes 2 books as TXT or pasted text, the page reader, follow-along, and Listen. Premium raises the library to 50 books and adds EPUB.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy || c.plusActive
                  ? null
                  : () => _run(c.purchasePremium),
              child: Text(
                demo ? 'Unlock Premium on this device' : 'Unlock Premium',
              ),
            ),
            const SizedBox(height: 8),
            if (!demo && !c.plusActive) ...[
              OutlinedButton(
                onPressed: _busy ? null : () => _run(c.purchasePlusYearly),
                child: const Text(r'Or yearly · $49.99'),
              ),
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
                    ? 'Premium is unlocked on this device.'
                    : 'Flick Premium is active.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
