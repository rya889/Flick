import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/flick_controller.dart';
import 'paywall_sheet.dart';
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Add a book in Library to start reading.',
            textAlign: TextAlign.center,
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Flick',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  const ModePill(),
                ],
              ),
              const SizedBox(height: 10),
              const ChapterPips(),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: c.playMode == PlayMode.story
                        ? () => c.jumpChapter(-1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous chapter',
                  ),
                  Expanded(
                    child: Text(
                      item.short.chapterTitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: c.playMode == PlayMode.story
                        ? () => c.jumpChapter(1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
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
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            feed.book.title,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: KaraokeText(
                                  text: text,
                                  activeIndex: active
                                      ? c.karaokeWord
                                      : wordsOf(text).length,
                                ),
                              ),
                            ),
                          ),
                          if (!c.playing && active)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Paused — tap center · swipe · double-tap heart',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const HeartBurstOverlay(),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ChoiceChip(
                label: const Text('Full'),
                selected: c.contentMode == ContentMode.full,
                onSelected: (_) => c.setContentMode(ContentMode.full),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(c.plusActive ? 'TLDR' : 'TLDR · lite'),
                selected: c.contentMode == ContentMode.tldr,
                onSelected: (_) {
                  if (!c.plusActive) {
                    // Free extractive still allowed
                    c.setContentMode(ContentMode.tldr);
                    return;
                  }
                  c.setContentMode(ContentMode.tldr);
                },
              ),
              const Spacer(),
              IconButton(
                tooltip: c.muted ? 'Unmute / Listen' : 'Mute',
                onPressed: () async {
                  final ok = await c.toggleMute();
                  if (!ok && context.mounted) {
                    await showPaywallSheet(
                      context,
                      reason: PaywallReason.listenCap,
                    );
                  }
                },
                icon: Icon(c.muted ? Icons.volume_off : Icons.volume_up),
              ),
              PopupMenuButton<double>(
                tooltip: 'Speed',
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text('${_formatSpeed(c.playbackSpeed)}x'),
                ),
              ),
            ],
          ),
          if (c.contentMode == ContentMode.tldr) ...[
            const SizedBox(height: 8),
            SegmentedButton<TldrSubmode>(
              segments: const [
                ButtonSegment(
                  value: TldrSubmode.condense,
                  label: Text('Condense'),
                ),
                ButtonSegment(
                  value: TldrSubmode.summary,
                  label: Text('Summary'),
                ),
                ButtonSegment(
                  value: TldrSubmode.quotes,
                  label: Text('Quotes'),
                ),
              ],
              selected: {c.tldrSubmode},
              onSelectionChanged: (set) {
                final mode = set.first;
                if (!c.plusActive && mode != TldrSubmode.condense) {
                  // Prototype: extractive covers all three; AI paywall tease
                  showPaywallSheet(context, reason: PaywallReason.aiTldr);
                }
                c.setTldrSubmode(mode);
              },
            ),
            if (!c.plusActive)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Extractive lite · Plus unlocks AI TLDR',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => c.toggleHeart(),
                icon: Icon(
                  hearted ? Icons.favorite : Icons.favorite_border,
                  color: hearted ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
              IconButton(
                onPressed: () => c.toggleSave(),
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
              ),
              IconButton(
                onPressed: () => c.shareCurrent(),
                icon: const Icon(Icons.ios_share),
              ),
            ],
          ),
        ],
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
            child: const Text('Add sample library'),
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
