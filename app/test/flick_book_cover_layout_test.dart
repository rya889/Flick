import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flick/models/models.dart';
import 'package:flick/widgets/flick_book_cover.dart';

void main() {
  testWidgets('compact cover fits hero thumbnail without overflow', (tester) async {
    final book = LibraryBook(
      id: 'sample-notes',
      title: 'Notes from Underground',
      author: 'Fyodor Dostoyevsky',
      source: BookSource.sample,
      text: 'x',
      addedAt: DateTime(2026),
      coverHue: 12,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: FlickBookCover(
              book: book,
              width: 44,
              height: 60,
              layout: BookCoverLayout.chip,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('poster cover scales title for shelf cells', (tester) async {
    final book = LibraryBook(
      id: 'sample-time',
      title: 'The Time Machine',
      author: 'H. G. Wells',
      source: BookSource.sample,
      text: 'x',
      addedAt: DateTime(2026),
      coverHue: 88,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: FlickBookCover(
              book: book,
              width: 168,
              height: 220,
              layout: BookCoverLayout.poster,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('The Time Machine'), findsOneWidget);
  });
}
