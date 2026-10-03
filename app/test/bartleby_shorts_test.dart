import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flick/models/models.dart';
import 'package:flick/services/abbreviate.dart';
import 'package:flick/services/short_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Bartleby shorts fit a fixed-font viewport', () async {
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
    const width = shortsFallbackWidth;
    const height = shortsFallbackHeight;
    final shorts = buildShorts(book, maxWidth: width, maxHeight: height);
    expect(shorts, isNotEmpty);
    expect(shorts.first.original.trim().isNotEmpty, isTrue);

    final softCeil = height * shortsFillTarget * 1.2;
    var overflows = 0;
    var tiny = 0;
    for (final short in shorts) {
      final h = measureShortHeight(
        short.original,
        maxWidth: width,
      );
      if (h > softCeil) overflows += 1;
      if (h < height * shortsMinFill * 0.4) tiny += 1;
    }
    // Fixed-font viewport packing: almost no card overflow / crumb shorts.
    expect(overflows, lessThan(3));
    expect(tiny, lessThan(shorts.length ~/ 20));
  });

  test('packShortUnitsToViewport fills toward card height', () {
    final units = [
      for (var i = 0; i < 20; i++)
        'Sentence number ${i + 1} has enough filler words to act like prose here for packing.',
    ];
    const width = shortsFallbackWidth;
    const height = shortsFallbackHeight;
    final packed = packShortUnitsToViewport(
      units,
      maxWidth: width,
      maxHeight: height,
    );
    expect(packed.length, greaterThan(1));
    expect(packed.length, lessThan(units.length));
    for (final chunk in packed) {
      final h = measureShortHeight(chunk, maxWidth: width);
      expect(h, lessThanOrEqualTo(height * shortsFillTarget + 4));
      expect(wordCount(chunk), greaterThan(10));
    }
  });
}
