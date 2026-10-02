import 'package:flutter/material.dart';

/// Kindle-style left/right margins. Debounces margin taps so double-clicks
/// cannot advance multiple pages/shorts.
class ReaderMarginTapLayer extends StatefulWidget {
  const ReaderMarginTapLayer({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.onCenterTap,
    this.onCenterDoubleTap,
    this.navCooldown = const Duration(milliseconds: 900),
  });

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCenterTap;
  final VoidCallback? onCenterDoubleTap;
  final Duration navCooldown;

  @override
  State<ReaderMarginTapLayer> createState() => _ReaderMarginTapLayerState();
}

class _ReaderMarginTapLayerState extends State<ReaderMarginTapLayer> {
  DateTime _lastMarginNav = DateTime.fromMillisecondsSinceEpoch(0);
  _MarginZone? _lastZone;

  void _marginTap(_MarginZone zone) {
    final now = DateTime.now();
    if (zone == _MarginZone.center) {
      widget.onCenterTap();
      return;
    }
    if (_lastZone == zone &&
        now.difference(_lastMarginNav) < widget.navCooldown) {
      return;
    }
    if (now.difference(_lastMarginNav) < widget.navCooldown) {
      return;
    }
    _lastZone = zone;
    _lastMarginNav = now;
    switch (zone) {
      case _MarginZone.previous:
        widget.onPrevious();
      case _MarginZone.next:
        widget.onNext();
      case _MarginZone.center:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 26,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _marginTap(_MarginZone.previous),
          ),
        ),
        Expanded(
          flex: 48,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _marginTap(_MarginZone.center),
            onDoubleTap: widget.onCenterDoubleTap,
          ),
        ),
        Expanded(
          flex: 26,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _marginTap(_MarginZone.next),
          ),
        ),
      ],
    );
  }
}

enum _MarginZone { previous, center, next }
