import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/listen_cap.dart';
import '../state/flick_controller.dart';
import 'house_pro_prompt.dart';
import 'paywall_sheet.dart';
import 'settings_sheet.dart';
import 'shell.dart';

/// Shared header + footer for Story shorts and Page reading on the Now tab.
class ReadingChrome extends StatelessWidget {
  const ReadingChrome({
    super.key,
    required this.item,
    required this.onShowChapters,
    required this.onShowReaderMenu,
    this.pageLabel,
    this.chapterTitle,
  });

  final FeedItem item;
  final VoidCallback onShowChapters;
  final VoidCallback onShowReaderMenu;
  final String? pageLabel;
  final String? chapterTitle;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final progress = c.bookProgressFraction;
    final shortLabel = c.queue.isEmpty
        ? ''
        : 'Short ${c.queueIndex + 1} of ${c.queue.length}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      c.playing ? 'Playing' : 'Paused · tap center to play',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: c.playing ? 'Pause' : 'Play',
                onPressed: c.togglePlay,
                icon: Icon(
                  c.playing ? Icons.pause_circle : Icons.play_circle,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SegmentedButton<ReadingLayout>(
            segments: const [
              ButtonSegment(
                value: ReadingLayout.shorts,
                label: Text('Shorts'),
                icon: Icon(Icons.view_agenda_outlined, size: 18),
              ),
              ButtonSegment(
                value: ReadingLayout.pages,
                label: Text('Pages'),
                icon: Icon(Icons.menu_book_outlined, size: 18),
              ),
            ],
            selected: {c.readingLayout},
            onSelectionChanged: (set) {
              final layout = set.first;
              c.setReadingLayout(layout);
            },
          ),
        ),
        const SizedBox(height: 4),
        const ChapterPips(),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: c.playMode == PlayMode.story
                    ? () => c.jumpChapter(-1)
                    : null,
                icon: const Icon(Icons.chevron_left, size: 22),
                tooltip: 'Previous chapter',
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onShowChapters,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        Text(
                          chapterTitle ?? item.short.chapterTitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        if (pageLabel != null && c.readingLayout == ReadingLayout.pages)
                          Text(
                            pageLabel!,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: c.playMode == PlayMode.story
                    ? () => c.jumpChapter(1)
                    : null,
                icon: const Icon(Icons.chevron_right, size: 22),
                tooltip: 'Next chapter',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            '$shortLabel · ${(progress * 100).round()}% through book',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

class ReadingActionBar extends StatelessWidget {
  const ReadingActionBar({
    super.key,
    required this.item,
    required this.onShowReaderMenu,
  });

  final FeedItem item;
  final VoidCallback onShowReaderMenu;

  @override
  Widget build(BuildContext context) {
    return _ReadingActionBar(
      item: item,
      onShowReaderMenu: onShowReaderMenu,
    );
  }
}

class _ReadingActionBar extends StatelessWidget {
  const _ReadingActionBar({
    required this.item,
    required this.onShowReaderMenu,
  });

  final FeedItem item;
  final VoidCallback onShowReaderMenu;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final hearted = c.hearts.contains(item.short.id);
    final saved = c.saves.contains(item.short.id);
    final listenLabel = !c.plusActive
        ? (c.listenCapped
            ? 'Listen cap — Pro'
            : formatListenRemaining(c.listenRemainingSeconds))
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (listenLabel != null)
                Expanded(
                  child: Text(
                    listenLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                )
              else
                const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: c.muted ? 'Unmute / Listen' : 'Mute',
                onPressed: () async {
                  final ok = await c.toggleMute();
                  if (!context.mounted) return;
                  if (!ok) {
                    await showPaywallSheet(
                      context,
                      reason: PaywallReason.listenCap,
                    );
                    return;
                  }
                  if (!c.muted && c.listenVoiceIsBasic && !c.plusActive) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Basic Listen voice on free tier. Pro unlocks enhanced on-device voices.',
                        ),
                        action: SnackBarAction(
                          label: 'Pro',
                          onPressed: () => showHouseProPrompt(
                            context,
                            placement: HouseProPlacement.voiceTease,
                          ),
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(
                  c.muted ? Icons.volume_off : Icons.volume_up,
                  size: 22,
                ),
              ),
              if (c.readingLayout == ReadingLayout.pages)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Page settings',
                  onPressed: onShowReaderMenu,
                  icon: const Icon(Icons.tune, size: 22),
                ),
              PopupMenuButton<double>(
                tooltip: 'Speed',
                padding: EdgeInsets.zero,
                initialValue: c.playbackSpeed,
                onSelected: (v) => c.setPlaybackSpeed(v),
                itemBuilder: (context) => [
                  for (final speed in const [0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0])
                    CheckedPopupMenuItem(
                      value: speed,
                      checked: (c.playbackSpeed - speed).abs() < 0.01,
                      child: Text('${speed}x'),
                    ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Text(
                    '${c.playbackSpeed}x',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: 'Settings',
                onPressed: () => showSettingsSheet(context),
                icon: const Icon(Icons.settings_outlined, size: 22),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
                onPressed: () => c.toggleHeart(),
                icon: Icon(
                  hearted ? Icons.favorite : Icons.favorite_border,
                  size: 22,
                  color: hearted ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
                onPressed: () => c.toggleSave(),
                icon: Icon(
                  saved ? Icons.bookmark : Icons.bookmark_border,
                  size: 22,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
                onPressed: () => c.shareCurrent(),
                icon: const Icon(Icons.ios_share, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
