import 'package:flick/models/reader_sync.dart';
import 'package:flick/theme/flick_theme.dart';
import 'package:flick/theme/reader_paper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unset paper follows app brightness', () {
    expect(
      effectiveReaderPaper(
        brightness: Brightness.dark,
        stored: ReaderPaper.paper,
        userSet: false,
      ),
      ReaderPaper.ink,
    );
    expect(
      effectiveReaderPaper(
        brightness: Brightness.light,
        stored: ReaderPaper.ink,
        userSet: false,
      ),
      ReaderPaper.paper,
    );
  });

  test('user-set sepia is kept across themes', () {
    expect(
      effectiveReaderPaper(
        brightness: Brightness.dark,
        stored: ReaderPaper.sepia,
        userSet: true,
      ),
      ReaderPaper.sepia,
    );
  });

  test('night paper matches Flick dark scaffold', () {
    final colors = readerPaperColors(ReaderPaper.ink);
    expect(colors.background, FlickColors.bgDark);
    expect(colors.ink, FlickColors.inkDark);
  });

  test('day paper matches Flick light scaffold', () {
    final colors = readerPaperColors(ReaderPaper.paper);
    expect(colors.background, FlickColors.bgLight);
    expect(colors.ink, FlickColors.inkLight);
  });
}
