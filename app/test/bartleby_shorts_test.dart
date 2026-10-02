import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flick/models/models.dart';
import 'package:flick/services/abbreviate.dart';
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
    // Most shorts should land in the snackable band; allow a few chapter-edge
    // leftovers outside it.
    final snackable =
        wordCounts.where((w) => w >= minWords - 5 && w <= maxWords + 40).length;
    expect(snackable, greaterThan((wordCounts.length * 9) ~/ 10));
    final tiny = wordCounts.where((w) => w < 45).length;
    expect(tiny, lessThan(3));
  });

  test('packShortUnits merges tiny paragraphs toward target length', () {
    final units = [
      for (var i = 0; i < 12; i++)
        'Sentence number ${i + 1} has enough filler words to act like prose here.',
    ];
    final packed = packShortUnits(units);
    expect(packed.length, lessThan(units.length));
    for (final chunk in packed) {
      expect(wordCount(chunk), greaterThanOrEqualTo(minWords - 5));
      expect(wordCount(chunk), lessThanOrEqualTo(maxWords + 40));
    }
  });
}
