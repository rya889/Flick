import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/short_builder.dart';
import '../state/flick_controller.dart';
import '../theme/flick_theme.dart';
import 'library_screen.dart';
import 'now_player.dart';
import 'settings_sheet.dart';

class FlickShell extends StatelessWidget {
  const FlickShell({super.key});

  @override
  Widget build(BuildContext context) {
    // Only rebuild shell chrome when these change — not on every karaoke tick
    // (that was remounting the settings FAB and making it flicker).
    final ready = context.select((FlickController c) => c.ready);
    final tabIndex = context.select((FlickController c) => c.tabIndex);

    if (!ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Settings in Library header + Now chrome; avoid FAB over shelf grid.
    final showSettingsFab = false;

    // Library first in the bar; tabIndex 1 = Library, 0 = Now.
    final navIndex = tabIndex <= 0 ? 1 : 0;
    final playerTab = tabIndex == 0;

    return Scaffold(
      body: SafeArea(
        child: playerTab ? const NowPlayer() : const LibraryScreen(),
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        selectedIndex: navIndex,
        onDestinationSelected: (i) =>
            context.read<FlickController>().setTab(i == 0 ? 1 : 0),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle_filled),
            label: 'Now',
          ),
        ],
      ),
      floatingActionButton: showSettingsFab
          ? FloatingActionButton.small(
              onPressed: () => showSettingsSheet(context),
              tooltip: 'Settings',
              backgroundColor: FlickColors.signalLight,
              foregroundColor: Colors.white,
              elevation: 2,
              child: const Icon(Icons.settings_outlined),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ModePill extends StatelessWidget {
  const ModePill({super.key});

  @override
  Widget build(BuildContext context) {
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
          _seg(context, 'Story', true, () {}),
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

class KaraokeText extends StatelessWidget {
  const KaraokeText({
    super.key,
    required this.text,
    required this.activeIndex,
    this.inkColor,
  });

  final String text;
  final int activeIndex;
  final Color? inkColor;

  @override
  Widget build(BuildContext context) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final ink = inkColor ?? Theme.of(context).colorScheme.onSurface;
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
                      fontSize: shortsFontSize,
                      height: shortsLineHeight,
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
          child: Icon(Icons.favorite, size: 96, color: FlickColors.signalLight),
        ),
      ),
    );
  }
}
