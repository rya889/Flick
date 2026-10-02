import 'package:flutter/material.dart';

import '../models/reader_sync.dart';

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

ReaderPaperColors readerPaperColors(ReaderPaper paper) {
  return switch (paper) {
    ReaderPaper.paper => const ReaderPaperColors(
        background: Color(0xFFFFFBF5),
        ink: Color(0xFF1C1C1C),
      ),
    ReaderPaper.sepia => const ReaderPaperColors(
        background: Color(0xFFF4ECD8),
        ink: Color(0xFF3E2F1C),
      ),
    ReaderPaper.ink => const ReaderPaperColors(
        background: Color(0xFF121212),
        ink: Color(0xFFE8E4DC),
      ),
  };
}
