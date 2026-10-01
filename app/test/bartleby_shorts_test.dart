import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flick/models/models.dart';
import 'package:flick/services/short_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Bartleby asset builds non-empty Story shorts', () async {
    const path = 'assets/samples/bartleby.txt';
    final text = await rootBundle.loadString(path);
    expect(text.trim().isNotEmpty, isTrue);
    expect(text, contains('prefer not'));

    final book = LibraryBook(
      id: 'sample-bartleby',
      title: 'Bartleby, the Scrivener',
      author: 'Herman Melville',
      source: BookSource.sample,
      text: text,
      addedAt: DateTime(2026),
    );
    final shorts = buildShorts(book);
    expect(shorts, isNotEmpty);
    expect(shorts.first.original.trim().isNotEmpty, isTrue);
    final wordCounts = shorts.map((s) => s.wordCount).toList();
    final snackable =
        wordCounts.where((w) => w >= 40 && w <= 180).length;
    expect(snackable, greaterThan(wordCounts.length ~/ 3));
  });
}
