import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/listen_cap.dart';
import '../state/flick_controller.dart';
import '../theme/reader_paper.dart';
import 'house_pro_prompt.dart';
import 'paywall_sheet.dart';
import 'settings_sheet.dart';

/// Compact shared header for Story shorts and Page reading on the Now tab.
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
    final paper = readerPaperColors(
      c.paperForBrightness(Theme.of(context).brightness),
    );
    final progress = c.bookProgressFraction.clamp(0.0, 1.0);
    final place = [
      chapterTitle ?? item.short.chapterTitle,
      if (c.readingLayout == ReadingLayout.pages && pageLabel != null) pageLabel!,
      if (c.queue.isNotEmpty)
        c.readingLayout == ReadingLayout.pages
            ? '${(progress * 100).round()}%'
            : 'Short ${c.queueIndex + 1}/${c.queue.length}',
    ].where((s) => s.trim().isNotEmpty).join(' · ');

    return Material(
      color: paper.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 8, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: paper.ink,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: c.playing ? 'Pause' : 'Play',
                  onPressed: c.togglePlay,
                  icon: Icon(
                    c.playing ? Icons.pause_circle : Icons.play_circle,
                    size: 30,
                    color: paper.ink,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<ReadingLayout>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: const [
                      ButtonSegment(
                        value: ReadingLayout.shorts,
                        label: Text('Shorts'),
                        icon: Icon(Icons.view_agenda_outlined, size: 16),
                      ),
                      ButtonSegment(
                        value: ReadingLayout.pages,
                        label: Text('Pages'),
                        icon: Icon(Icons.menu_book_outlined, size: 16),
                      ),
                    ],
                    selected: {c.readingLayout},
                    onSelectionChanged: (set) => c.setReadingLayout(set.first),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  tooltip: 'Chapters',
                  visualDensity: VisualDensity.compact,
                  onPressed: onShowChapters,
                  icon: const Icon(Icons.list_alt_outlined, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (c.readingLayout == ReadingLayout.shorts)
              const ChapterPips()
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor: paper.ink.withValues(alpha: 0.16),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              place,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: paper.mutedInk,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented progress across shorts in the current chapter.
class ChapterPips extends StatelessWidget {
  const ChapterPips({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final item = c.current;
    if (item == null) return const SizedBox.shrink();
    final shorts = c.shortsByBook[item.book.id] ?? [];
    final inChapter = shorts
        .where((s) => s.chapterIndex == item.short.chapterIndex)
        .toList();
    if (inChapter.isEmpty) return const SizedBox.shrink();
    final localIndex = inChapter
        .indexWhere((s) => s.id == item.short.id)
        .clamp(0, inChapter.length - 1);
    final signal = Theme.of(context).colorScheme.primary;
    final paper = readerPaperColors(
      c.paperForBrightness(Theme.of(context).brightness),
    );

    return Row(
      children: [
        for (var i = 0; i < inChapter.length; i++)
          Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: i <= localIndex
                    ? signal
                    : paper.ink.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}

/// Single-row footer: listen + tools + social.
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
    final c = context.watch<FlickController>();
    final paper = readerPaperColors(
      c.paperForBrightness(Theme.of(context).brightness),
    );
    final hearted = c.hearts.contains(item.short.id);
    final saved = c.saves.contains(item.short.id);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: paper.background,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: paper.border)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 2),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: c.muted ? 'Listen' : 'Mute',
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
                            'Basic Listen voice — Pro unlocks enhanced voices.',
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
                    color: paper.ink,
                  ),
                ),
                if (!c.plusActive)
                  Flexible(
                    child: Text(
                      c.listenCapped
                          ? 'Listen cap'
                          : formatListenRemaining(c.listenRemainingSeconds),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: paper.mutedInk,
                          ),
                    ),
                  ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: hearted ? 'Unheart' : 'Heart',
                  onPressed: () => c.toggleHeart(),
                  icon: Icon(
                    hearted ? Icons.favorite : Icons.favorite_border,
                    size: 22,
                    color: hearted ? scheme.primary : paper.ink,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: saved ? 'Unsave' : 'Save',
                  onPressed: () => c.toggleSave(),
                  icon: Icon(
                    saved ? Icons.bookmark : Icons.bookmark_border,
                    size: 22,
                    color: paper.ink,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Share',
                  onPressed: () => c.shareCurrent(),
                  icon: Icon(Icons.ios_share, size: 20, color: paper.ink),
                ),
                if (c.readingLayout == ReadingLayout.pages)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Text & theme',
                    onPressed: onShowReaderMenu,
                    icon: Icon(Icons.text_fields, size: 22, color: paper.ink),
                  ),
                PopupMenuButton<double>(
                  tooltip: 'Speed',
                  padding: EdgeInsets.zero,
                  initialValue: c.playbackSpeed,
                  onSelected: c.setPlaybackSpeed,
                  itemBuilder: (context) => [
                    for (final speed in const [
                      0.75,
                      1.0,
                      1.25,
                      1.5,
                      2.0,
                      2.5,
                      3.0,
                    ])
                      CheckedPopupMenuItem(
                        value: speed,
                        checked: (c.playbackSpeed - speed).abs() < 0.01,
                        child: Text('${speed}x'),
                      ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      '${c.playbackSpeed}x',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: paper.ink,
                          ),
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Settings',
                  onPressed: () => showSettingsSheet(context),
                  icon: Icon(Icons.settings_outlined, size: 22, color: paper.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
