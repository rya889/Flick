import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/reader_sync.dart';
import '../services/library_export_share.dart';
import '../state/flick_controller.dart';

Future<void> showSyncSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const SyncSheet(),
  );
}

class SyncSheet extends StatefulWidget {
  const SyncSheet({super.key});

  @override
  State<SyncSheet> createState() => _SyncSheetState();
}

class _SyncSheetState extends State<SyncSheet> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final backup = c.lastLibraryBackup == null
        ? 'No backup yet'
        : 'Last backup ${DateFormat.yMMMd().add_jm().format(c.lastLibraryBackup!.toLocal())}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sync library', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Books and reading places move as one Flick file. The newest place wins when you restore.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(backup, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            _targetTile(
              context,
              c,
              target: SyncTarget.device,
              title: 'This device',
              subtitle: 'Library and progress stay on this phone.',
            ),
            _targetTile(
              context,
              c,
              target: SyncTarget.googleDrive,
              title: 'Google Drive',
              subtitle:
                  'Back up saves flick-library.json. In the share sheet, choose Google Drive.',
            ),
            _targetTile(
              context,
              c,
              target: SyncTarget.files,
              title: 'iCloud or Files',
              subtitle:
                  'Same file, saved to iCloud Drive or On My iPhone. Use this to move between Apple devices.',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : () => _backup(context),
              child: Text(_busy ? 'Working…' : _backupLabel(c.syncTarget)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : () => _restore(context),
              child: const Text('Restore from a Flick file'),
            ),
          ],
        ),
      ),
    );
  }

  String _backupLabel(SyncTarget target) {
    return switch (target) {
      SyncTarget.device => 'Copy library file',
      SyncTarget.googleDrive => 'Save to Google Drive',
      SyncTarget.files => 'Save to iCloud or Files',
    };
  }

  Widget _targetTile(
    BuildContext context,
    FlickController c, {
    required SyncTarget target,
    required String title,
    required String subtitle,
  }) {
    final selected = c.syncTarget == target;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: _busy ? null : () => c.setSyncTarget(target),
    );
  }

  Future<void> _backup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<FlickController>();
    setState(() => _busy = true);
    try {
      final json = await controller.exportLibraryJson();
      await shareLibraryJson(json);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(BuildContext context) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final bytes = picked.files.first.bytes;
    if (bytes == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<FlickController>();
    setState(() => _busy = true);
    try {
      final message = await controller.restoreLibraryJson(utf8.decode(bytes));
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
