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
            child: FlickBookCover(book: book, width: 44, height: 60),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
