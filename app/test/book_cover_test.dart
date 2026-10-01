import 'package:flutter_test/flutter_test.dart';
import 'package:flick/models/book_cover.dart';
import 'package:flick/models/models.dart';

void main() {
  test('seed titles use generated cover source', () {
    for (final sample in sampleLibrary) {
      final book = LibraryBook(
        id: sample.id,
        title: sample.title,
        author: sample.author,
        source: BookSource.sample,
        text: 'x',
        addedAt: DateTime(2026),
        coverHue: sample.hue,
      );
      final meta = coverMetaForBook(book);
      expect(meta.source, CoverSource.generated);
      expect(meta.assetPath, isNull);
    }
  });

  test('cover accent hue is stable for same book', () {
    final book = LibraryBook(
      id: 'sample-bartleby',
      title: 'Bartleby',
      source: BookSource.sample,
      text: 'x',
      addedAt: DateTime(2026),
      coverHue: 220,
    );
    expect(coverAccentHue(book), coverAccentHue(book));
  });
}
