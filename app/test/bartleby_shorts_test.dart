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
        wordCounts.where((w) => w >= minWords - 10 && w <= maxWords + 25).length;
    expect(snackable, greaterThan((wordCounts.length * 3) ~/ 4));
    final tiny = wordCounts.where((w) => w < 35).length;
    expect(tiny, lessThan(wordCounts.length ~/ 10));
  });

  test('packShortUnits merges tiny paragraphs toward target length', () {
    final units = [
      'One two three four five six seven eight nine ten.',
      'Eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen.',
      'Nineteen twenty twentyone twentytwo twentythree twentyfour twentyfive '
          'twentysix twentyseven twentyeight twentynine thirty thirtyone '
          'thirtytwo thirtythree thirtyfour thirtyfive thirtysix thirtyseven '
          'thirtyeight thirtynine forty fortyone fortytwo fortythree '
          'fortyfour fortyfive fortysix fortyseven fortyeight fortynine fifty.',
    ];
    final packed = packShortUnits(units);
    expect(packed.length, lessThan(units.length));
    expect(wordCount(packed.first), greaterThanOrEqualTo(minWords - 5));
    for (final chunk in packed) {
      expect(wordCount(chunk), lessThanOrEqualTo(maxWords + 25));
    }
  });
}
