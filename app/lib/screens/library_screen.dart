import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/flick_controller.dart';

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
              Text('Library', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'The anti-doomscroll reader',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
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
              OutlinedButton.icon(
                onPressed: () => _showBookmarks(context),
                icon: const Icon(Icons.bookmark_outline),
                label: Text('Saves (${c.saves.length})'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: c.books.isEmpty
              ? _EmptyLibrary(
                  onAddBook: () => _showAddBook(context),
                  onAddSamples: () => c.seedSamples(),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Text(
                      'Samples',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final sample in sampleLibrary)
                      _SampleTile(sample: sample),
                    const SizedBox(height: 20),
                    Text(
                      'Your books',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final book in c.books) _BookTile(book: book),
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
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('EPUB file'),
                subtitle: const Text('Import a .epub from your device'),
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
    switch (choice) {
      case 'epub':
        await _pickEpub(context);
      case 'txt':
        await _pickTxt(context);
      case 'paste':
        await _showPasteSheet(context);
    }
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

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({
    required this.onAddBook,
    required this.onAddSamples,
  });

  final VoidCallback onAddBook;
  final VoidCallback onAddSamples;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Flick',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a book to start. Or load free public-domain samples.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onAddBook,
              child: const Text('Add book'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAddSamples,
              child: const Text('Add sample library'),
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
      leading: _Cover(hue: sample.hue),
      title: Text(sample.title),
      subtitle: Text(sample.author),
      trailing: Text(inLibrary ? 'Open' : 'Add'),
      onTap: () => c.addSample(sample),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});
  final LibraryBook book;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final prog = c.progress[book.id];
    final shorts = c.shortsByBook[book.id]?.length ?? book.shortCount;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _Cover(hue: book.coverHue),
      title: Text(book.title),
      subtitle: Text(
        [
          if (book.author != null) book.author!,
          book.source.name.toUpperCase(),
          '$shorts shorts',
          if (prog != null) 'Resume #${prog.shortIndex + 1}',
        ].join(' · '),
      ),
      onTap: () async {
        await c.openBook(book);
        c.setTab(0);
      },
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.hue});
  final double hue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue % 360, 0.55, 0.42).toColor(),
            HSLColor.fromAHSL(1, (hue + 40) % 360, 0.45, 0.28).toColor(),
          ],
        ),
      ),
    );
  }
}
