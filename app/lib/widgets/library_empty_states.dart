import 'package:flutter/material.dart';

/// Bite-size empty / error copy (T13). No funnel — one obvious next step.
class LibraryEmptyState extends StatelessWidget {
  const LibraryEmptyState({
    super.key,
    required this.onStartBartleby,
    required this.onAddSamples,
    required this.onAddBook,
  });

  final VoidCallback onStartBartleby;
  final VoidCallback onAddSamples;
  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Finish a free book',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start with Bartleby — swipe Story shorts, Listen, and reach Finished. No account, no paywall on public-domain text.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onStartBartleby,
              child: const Text('Start with Bartleby'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onAddSamples,
              child: const Text('Add all public-domain samples'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onAddBook,
              child: const Text('Import your own TXT or paste'),
            ),
          ],
        ),
      ),
    );
  }
}

class CatalogEmptyResults extends StatelessWidget {
  const CatalogEmptyResults({
    super.key,
    required this.onTrySamples,
  });

  final VoidCallback onTrySamples;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No matches',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try another search, or use the bundled seed shelf offline.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onTrySamples,
            child: const Text('Back to seed shelf'),
          ),
        ],
      ),
    );
  }
}

class InlineErrorBanner extends StatelessWidget {
  const InlineErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: scheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: Theme.of(context).textTheme.bodySmall),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
