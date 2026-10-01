import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/library_access.dart';
import '../state/flick_controller.dart';
import 'ebook_reader.dart';
import 'paywall_sheet.dart';
import 'pd_catalog_screen.dart';
import 'settings_sheet.dart';
import '../widgets/flick_book_cover.dart';
import '../widgets/library_empty_states.dart';
import 'sync_sheet.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _importing = false;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Library',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () => showSettingsSheet(context),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                c.plusActive
                    ? '${c.importedBookCount} of ${c.libraryBookLimit} books · Pro'
                    : '${c.importedBookCount} of ${c.libraryBookLimit} imports · samples free',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _importing ? null : () => _showAddBook(context),
                      icon: _importing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(_importing ? 'Importing…' : 'Add book'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showBookmarks(context),
                      icon: const Icon(Icons.bookmark_outline),
                      label: Text('Saves (${c.saves.length})'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showSyncSheet(context),
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PdCatalogScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.public),
                      label: const Text('Browse PD'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: c.books.isEmpty
              ? LibraryEmptyState(
                  onAddBook: () => _showAddBook(context),
                  onAddSamples: () => c.seedSamples(),
                  onStartBartleby: () => c.openBartlebyStory(),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    if (c.continueReadingBook != null)
                      _ContinueReadingCard(book: c.continueReadingBook!),
                    if (c.books.any((b) => b.id == kBartlebySampleId) &&
                        c.continueReadingBook?.id != kBartlebySampleId)
                      _BartlebyDogfoodCard(
                        completed: c.isBookCompleted(kBartlebySampleId),
                        onStory: () async {
                          final book = c.books
                              .firstWhere((b) => b.id == kBartlebySampleId);
                          await c.openBook(book);
                        },
                      ),
                    if (c.continueReadingBook != null ||
                        c.books.any((b) => b.id == kBartlebySampleId))
                      const SizedBox(height: 4),
                    Text(
                      'On your shelf',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _ShelfCoverGrid(books: c.books),
                    const SizedBox(height: 20),
                    Text(
                      'Add samples',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final sample in sampleLibrary)
                      _SampleTile(sample: sample),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _showAddBook(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        final premium = context.read<FlickController>().plusActive;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('EPUB file'),
                subtitle: Text(
                  premium
                      ? 'Import a .epub from your device'
                      : 'Premium · EPUB import',
                ),
                onTap: () => Navigator.pop(context, 'epub'),
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('TXT file'),
                onTap: () => Navigator.pop(context, 'txt'),
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('Paste text'),
                onTap: () => Navigator.pop(context, 'paste'),
              ),
            ],
          ),
        );
      },
    );
    if (!context.mounted || choice == null) return;
    final source = switch (choice) {
      'epub' => BookSource.epub,
      'txt' => BookSource.txt,
      _ => BookSource.paste,
    };
    if (!await _allowImport(context, source)) return;
    if (!context.mounted) return;
    switch (choice) {
      case 'epub':
        await _pickEpub(context);
      case 'txt':
        await _pickTxt(context);
      case 'paste':
        await _showPasteSheet(context);
    }
  }

  Future<bool> _allowImport(BuildContext context, BookSource source) async {
    final c = context.read<FlickController>();
    final block = c.blockFor(source);
    if (block == null) return true;
    if (c.plusActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This library holds ${c.libraryBookLimit} books.'),
        ),
      );
      return false;
    }
    await showPaywallSheet(
      context,
      reason: block == LibraryBlock.extensionLocked
          ? PaywallReason.epub
          : PaywallReason.libraryCap,
    );
    return false;
  }

  Future<void> _pickEpub(BuildContext context) async {
    final c = context.read<FlickController>();
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['epub'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read EPUB bytes.')),
        );
      }
      return;
    }
    setState(() => _importing = true);
    try {
      await c.importEpubFile(file.name, Uint8List.fromList(bytes));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('EPUB import failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _pickTxt(BuildContext context) async {
    final c = context.read<FlickController>();
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    final text = String.fromCharCodes(bytes);
    setState(() => _importing = true);
    try {
      await c.importTxtFile(file.name, text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TXT import failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _showPasteSheet(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Paste a book', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Max 500KB and ~100k words.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                minLines: 8,
                maxLines: 14,
                decoration: const InputDecoration(
                  labelText: 'Text',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Add to library'),
              ),
            ],
          ),
        );
      },
    );
    if (ok == true && context.mounted) {
      setState(() => _importing = true);
      try {
        await context.read<FlickController>().importPaste(
              titleCtrl.text,
              bodyCtrl.text,
            );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e')),
          );
        }
      } finally {
        if (mounted) setState(() => _importing = false);
      }
    }
  }

  Future<void> _showBookmarks(BuildContext context) async {
    final c = context.read<FlickController>();
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final items = c.savedItems;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Saved shorts', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Text('No saves yet — tap bookmark on a short.'),
              for (final item in items)
                ListTile(
                  title: Text(item.book.title),
                  subtitle: Text(
                    item.short.original,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await c.openBook(item.book, shortIndex: item.short.index);
                    c.setTab(0);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LibraryHeroCard extends StatelessWidget {
  const _LibraryHeroCard({
    required this.leadingWidth,
    required this.leadingHeight,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.detail,
    required this.trailing,
    required this.onTap,
  });

  final double leadingWidth;
  final double leadingHeight;
  final Widget leading;
  final String title;
  final String subtitle;
  final String? detail;
  final Widget trailing;
  final VoidCallback onTap;

  static const _coverWidth = 44.0;
  static const _coverHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1, maxScaleFactor: 1.15);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.primaryContainer.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: leadingWidth,
                  height: leadingHeight,
                  child: leading,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: textScaler,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.72),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: textScaler,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (detail != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          detail!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: textScaler,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BartlebyDogfoodCard extends StatelessWidget {
  const _BartlebyDogfoodCard({
    required this.completed,
    required this.onStory,
  });

  final bool completed;
  final VoidCallback onStory;

  @override
  Widget build(BuildContext context) {
    final bartleby = sampleLibrary.firstWhere((s) => s.id == kBartlebySampleId);
    final book = LibraryBook(
      id: bartleby.id,
      title: bartleby.title,
      author: bartleby.author,
      source: BookSource.sample,
      text: '',
      addedAt: DateTime(2026),
      coverHue: bartleby.hue,
    );
    final scheme = Theme.of(context).colorScheme;
    return _LibraryHeroCard(
      leadingWidth: _LibraryHeroCard._coverWidth,
      leadingHeight: _LibraryHeroCard._coverHeight,
      leading: FlickBookCover(
        book: book,
        width: _LibraryHeroCard._coverWidth,
        height: _LibraryHeroCard._coverHeight,
        layout: BookCoverLayout.chip,
      ),
      title: completed ? 'Bartleby — finished' : 'Start with Bartleby',
      subtitle: completed
          ? 'Replay Story shorts or open the full reader.'
          : 'One tap: Story, Listen, Finish.',
      trailing: Icon(
        completed ? Icons.check_circle : Icons.play_circle_fill,
        color: scheme.primary,
        size: 36,
      ),
      onTap: onStory,
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.book});
  final LibraryBook book;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final chip = c.continueReadingLabel(book.id);
    final scheme = Theme.of(context).colorScheme;
    return _LibraryHeroCard(
      leadingWidth: _LibraryHeroCard._coverWidth,
      leadingHeight: _LibraryHeroCard._coverHeight,
      leading: FlickBookCover(
        book: book,
        width: _LibraryHeroCard._coverWidth,
        height: _LibraryHeroCard._coverHeight,
        layout: BookCoverLayout.chip,
      ),
      title: 'Continue reading',
      subtitle: book.title,
      detail: chip,
      trailing: Icon(
        Icons.play_arrow_rounded,
        color: scheme.primary,
        size: 32,
      ),
      onTap: () async {
        await c.openBook(book);
        c.setTab(0);
      },
    );
  }
}

class _ShelfCoverGrid extends StatelessWidget {
  const _ShelfCoverGrid({required this.books});
  final List<LibraryBook> books;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.52,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => _ShelfBookCard(book: books[index]),
    );
  }
}

class _ShelfBookCard extends StatelessWidget {
  const _ShelfBookCard({required this.book});
  final LibraryBook book;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final prog = c.progress[book.id];
    final meta = [
      if (book.author != null) book.author!,
      if (c.isBookCompleted(book.id)) 'Finished',
      if (prog != null) 'Short ${prog.shortIndex + 1}',
    ].join(' · ');

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await c.openBook(book);
          c.setTab(0);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => FlickBookCover(
                  book: book,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  borderRadius: 0,
                  layout: BookCoverLayout.poster,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 4, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (meta.isNotEmpty)
                          Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EbookReaderScreen(book: book),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.auto_stories_outlined, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleTile extends StatelessWidget {
  const _SampleTile({required this.sample});
  final SampleMeta sample;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final inLibrary = c.books.any((b) => b.id == sample.id);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: FlickBookCover(
        book: LibraryBook(
          id: sample.id,
          title: sample.title,
          author: sample.author,
          source: BookSource.sample,
          text: '',
          addedAt: DateTime(2026),
          coverHue: sample.hue,
        ),
        width: 44,
        height: 58,
        layout: BookCoverLayout.chip,
      ),
      title: Text(sample.title),
      subtitle: Text(
        sample.id == kBartlebySampleId
            ? '${sample.author} · recommended start'
            : sample.author,
      ),
      trailing: inLibrary
          ? IconButton(
              tooltip: 'Read',
              onPressed: () {
                final book = c.books.firstWhere((b) => b.id == sample.id);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EbookReaderScreen(book: book),
                  ),
                );
              },
              icon: const Icon(Icons.auto_stories_outlined),
            )
          : const Text('Add'),
      onTap: () => c.addSample(sample),
    );
  }
}

