import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/flick_controller.dart';
import 'house_pro_prompt.dart';
import '../theme/reader_paper.dart';
import '../widgets/reader_margin_taps.dart';
import 'ebook_reader.dart';
import 'reading_chrome.dart';
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

    final host = c.readerPageHost;
    final paper = readerPaperColors(c.readerPaper);

    return ColoredBox(
      color: paper.background,
      child: Column(
      children: [
        ReadingChrome(
          item: item,
          pageLabel: host?.pageLabel,
          chapterTitle: host?.chapterTitle ?? item.short.chapterTitle,
          onShowChapters: () async {
            await host?.showChapters?.call();
          },
          onShowReaderMenu: () async {
            await host?.showReaderMenu?.call();
          },
        ),
        Expanded(
          child: IndexedStack(
            index: c.readingLayout == ReadingLayout.pages ? 1 : 0,
            children: [
              ColoredBox(
                color: paper.background,
                child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
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
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                        child: SizedBox.expand(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: paper.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: paper.border),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                              child: KaraokeText(
                                text: text,
                                inkColor: paper.ink,
                                activeIndex: active
                                    ? c.karaokeWord
                                    : wordsOf(text).length,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ReaderMarginTapLayer(
                    onPrevious: c.prevShort,
                    onNext: c.nextShort,
                    onCenterTap: c.togglePlay,
                    onCenterDoubleTap: () {
                      final id = c.current?.short.id;
                      if (id != null) c.toggleHeart(id);
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
              ReaderPagePane(book: item.book, embedded: true),
            ],
          ),
        ),
        ReadingActionBar(
          item: item,
          onShowReaderMenu: () async {
            await host?.showReaderMenu?.call();
          },
        ),
      ],
    ),
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
