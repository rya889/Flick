import 'package:flutter/material.dart';

import '../models/reader_sync.dart';
import 'flick_theme.dart';

class ReaderPaperColors {
  const ReaderPaperColors({
    required this.background,
    required this.ink,
  });

  final Color background;
  final Color ink;

  Color get border => ink.withValues(alpha: 0.12);
  Color get mutedInk => ink.withValues(alpha: 0.65);
  Color get faintInk => ink.withValues(alpha: 0.34);
}

/// Resolve stored preference against app brightness.
/// Until the user picks a paper mode themselves, follow light/dark theme.
ReaderPaper effectiveReaderPaper({
  required Brightness brightness,
  required ReaderPaper stored,
  required bool userSet,
}) {
  if (userSet) return stored;
  return brightness == Brightness.dark ? ReaderPaper.ink : ReaderPaper.paper;
}

/// Reading surface colors aligned with Flick scaffold tokens.
ReaderPaperColors readerPaperColors(ReaderPaper paper) {
  return switch (paper) {
    ReaderPaper.paper => const ReaderPaperColors(
        background: FlickColors.bgLight,
        ink: FlickColors.inkLight,
      ),
    ReaderPaper.sepia => const ReaderPaperColors(
        background: Color(0xFFF4ECD8),
        ink: Color(0xFF3E2F1C),
      ),
    ReaderPaper.ink => const ReaderPaperColors(
        background: FlickColors.bgDark,
        ink: FlickColors.inkDark,
      ),
  };
}

ReaderPaperColors readerPaperColorsFor({
  required Brightness brightness,
  required ReaderPaper stored,
  required bool userSet,
}) {
  return readerPaperColors(
    effectiveReaderPaper(
      brightness: brightness,
      stored: stored,
      userSet: userSet,
    ),
  );
}
