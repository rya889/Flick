import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/flick_controller.dart';
import '../theme/flick_theme.dart';
import 'library_screen.dart';
import 'now_player.dart';
import 'settings_sheet.dart';

class FlickShell extends StatelessWidget {
  const FlickShell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    if (!c.ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: c.tabIndex == 2 ? 0 : c.tabIndex,
          children: const [
            NowPlayer(),
            LibraryScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: c.tabIndex == 2 ? 2 : c.tabIndex,
        onDestinationSelected: (i) {
          if (i == 2) {
            c.enterBounce();
            return;
          }
          c.setTab(i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle_filled),
            label: 'Now',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.shuffle_outlined),
            selectedIcon: Icon(Icons.shuffle),
            label: 'Bounce',
          ),
        ],
      ),
      floatingActionButton: c.tabIndex == 1
          ? null
          : IconButton.filledTonal(
              onPressed: () => showSettingsSheet(context),
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ModePill extends StatelessWidget {
  const ModePill({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final signal = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: signal.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(context, 'Story', c.playMode == PlayMode.story, () {
            c.setPlayMode(PlayMode.story);
          }),
          _seg(context, 'Bounce', c.playMode == PlayMode.bounce, () {
            c.enterBounce();
          }),
        ],
      ),
    );
  }

  Widget _seg(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final signal = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? signal : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
    );
  }
}

class ChapterPips extends StatelessWidget {
  const ChapterPips({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FlickController>();
    final item = c.current;
    if (item == null) return const SizedBox.shrink();
    final shorts = c.shortsByBook[item.book.id] ?? [];
    final inChapter =
        shorts.where((s) => s.chapterIndex == item.short.chapterIndex).toList();
    if (inChapter.isEmpty) return const SizedBox.shrink();
    final localIndex =
        inChapter.indexWhere((s) => s.id == item.short.id).clamp(0, inChapter.length - 1);
    final signal = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        for (var i = 0; i < inChapter.length; i++)
          Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: i <= localIndex
                    ? signal
                    : (Theme.of(context).brightness == Brightness.dark
                        ? FlickColors.inkMutedDark
                        : FlickColors.inkMutedLight)
                        .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}

class KaraokeText extends StatelessWidget {
  const KaraokeText({super.key, required this.text, required this.activeIndex});

  final String text;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final ink = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          children: [
            for (var i = 0; i < words.length; i++) ...[
              TextSpan(
                text: words[i],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: i <= activeIndex
                          ? ink
                          : ink.withValues(alpha: 0.34),
                      fontSize: 20,
                      height: 1.55,
                    ),
              ),
              if (i < words.length - 1) const TextSpan(text: ' '),
            ],
          ],
        ),
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}

class HeartBurstOverlay extends StatelessWidget {
  const HeartBurstOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final show = context.watch<FlickController>().showHeartBurst;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: const Center(
          child: Icon(Icons.favorite, size: 96, color: Color(0xFFFF3B2E)),
        ),
      ),
    );
  }
}
