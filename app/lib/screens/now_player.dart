import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/listen_cap.dart';
import '../state/flick_controller.dart';
import 'house_pro_prompt.dart';
import 'paywall_sheet.dart';
import 'settings_sheet.dart';
import 'shell.dart';

class NowPlayer extends StatefulWidget {
  const NowPlayer({super.key});

  @override
  State<NowPlayer> createState() => _NowPlayerState();
}

class _NowPlayerState extends State<NowPlayer> {
  late final PageController _pageController;
  bool _syncingPage = false;

  @override
  void initState() {
    super.initState();
    final c = context.read<FlickController>();
    _pageController = PageController(initialPage: c.queueIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncControllerToPage(FlickController c) {
    if (!_pageController.hasClients) return;
    final page = _pageController.page?.round() ?? c.queueIndex;
    if (page == c.queueIndex) return;
    _syncingPage = true;
    _pageController.jumpToPage(
      c.queueIndex.clamp(0, c.queue.isEmpty ? 0 : c.queue.length - 1),
    );
    _syncingPage = false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();

    if (c.playMode == PlayMode.bounce && c.books.length < 3) {
      return const _BounceSoftPrompt();
    }

    final item = c.current;
    if (item == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Nothing open',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Open a book from Library. Read it page by page, or flick through it here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => c.setTab(1),
                child: const Text('Go to Library'),
              ),
            ],
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_syncingPage) _syncControllerToPage(c);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 4, 0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                          c.playing ? 'Playing' : 'Paused · tap to play',
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
              const SizedBox(height: 4),
              const ChapterPips(),
              const SizedBox(height: 2),
              Row(
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
                    child: Text(
                      item.short.chapterTitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
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
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: c.queue.length,
                onPageChanged: (index) {
                  if (_syncingPage) return;
                  c.goToIndex(index);
                },
                itemBuilder: (context, index) {
                  final feed = c.queue[index];
                  final active = index == c.queueIndex;
                  final text = active
                      ? c.displayText
                      : feed.short.original;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onDoubleTap: () => c.toggleHeart(feed.short.id),
                    onTapUp: (details) {
                      final width = MediaQuery.sizeOf(context).width;
                      final x = details.globalPosition.dx;
                      if (x < width * 0.28) {
                        c.prevShort();
                      } else if (x > width * 0.72) {
                        c.nextShort();
                      } else {
                        c.togglePlay();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                      child: SizedBox.expand(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.08),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                            child: KaraokeText(
                            text: text,
                            activeIndex: active
                                ? c.karaokeWord
                                : wordsOf(text).length,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const HeartBurstOverlay(),
              if (c.showFinishCelebration) const _FinishCelebrationOverlay(),
              if (!c.playing)
                const IgnorePointer(
                  child: _PausePlayOverlay(),
                ),
            ],
          ),
        ),
        _ChromeBar(item: item),
      ],
    );
  }
}

List<String> wordsOf(String text) =>
    text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

class _PausePlayOverlay extends StatelessWidget {
  const _PausePlayOverlay();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.scrim.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(
            Icons.play_arrow_rounded,
            size: 44,
            color: scheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

String _formatSpeed(double speed) {
  if (speed == speed.roundToDouble()) return speed.toStringAsFixed(0);
  return speed.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

class _ChromeBar extends StatelessWidget {
  const _ChromeBar({required this.item});
  final FeedItem item;

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
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
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
                  if (!c.muted && c.listenVoiceIsBasic) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Basic voice — download a premium voice in iOS Settings → Spoken Content, or try Pro later.',
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
                      child: Text('${_formatSpeed(speed)}x'),
                    ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Text(
                    '${_formatSpeed(c.playbackSpeed)}x',
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

class _FinishCelebrationOverlay extends StatelessWidget {
  const _FinishCelebrationOverlay();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final title = c.finishCelebrationTitle ?? 'This book';
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.scrim.withValues(alpha: 0.72),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration_outlined, size: 56, color: scheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Finished!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You made it through every short. Anti-doomscroll win.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      c.dismissFinishCelebration();
                      if (context.mounted && !c.plusActive) {
                        await showHouseProPrompt(
                          context,
                          placement: HouseProPlacement.finish,
                        );
                      }
                      if (context.mounted) c.setTab(1);
                    },
                    child: const Text('Back to Library'),
                  ),
                  TextButton(
                    onPressed: () async {
                      c.dismissFinishCelebration();
                      if (context.mounted && !c.plusActive) {
                        await showHouseProPrompt(
                          context,
                          placement: HouseProPlacement.finish,
                        );
                      }
                    },
                    child: const Text('Stay on this short'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BounceSoftPrompt extends StatelessWidget {
  const _BounceSoftPrompt();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ModePill(),
          const Spacer(),
          Text(
            'Bounce needs 3 books',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'You have ${c.books.length}. Add the free samples or paste another book to unlock cross-book shorts.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              await c.seedSamples();
              c.enterBounce();
            },
            child: const Text('Add public-domain samples'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => c.setTab(1),
            child: const Text('Go to Library'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
