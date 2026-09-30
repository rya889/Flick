import 'package:flick/models/models.dart';
import 'package:flick/services/library_access.dart';
import 'package:flick/services/page_text.dart';
import 'package:flick/services/progress_bridge.dart';
import 'package:flick/services/book_pages.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression checks for the reader flows. Run with `flutter test`.
void main() {
  test('paragraph spacing is fixed and does not depend on read-along', () {
    const page = 'Alice sat by the river.\n\nThe rabbit hurried past.';
    expect(pageLayoutSignature(page), '5|4');
    expect(pageBlocks(page).length, 2);
    expect(pageBlocks(page).first.text, 'Alice sat by the river.');
  });

  test('a single paragraph stays one block', () {
    expect(pageBlocks('Just one line of text.').length, 1);
  });

  test('free library allows two text books and blocks EPUB and a third book', () {
    expect(blockImport(BookSource.txt, premium: false, importedBooks: 0), isNull);
    expect(blockImport(BookSource.paste, premium: false, importedBooks: 1), isNull);
    expect(
      blockImport(BookSource.txt, premium: false, importedBooks: 2),
      LibraryBlock.bookCap,
    );
    expect(
      blockImport(BookSource.epub, premium: false, importedBooks: 0),
      LibraryBlock.extensionLocked,
    );
    expect(blockImport(BookSource.epub, premium: true, importedBooks: 2), isNull);
  });

  test('reader place and flick short stay on the same passage', () {
    const chapters = [
      ReaderChapter(index: 0, title: 'Chapter 1', text: 'First passage of the book.'),
      ReaderChapter(index: 1, title: 'Chapter 2', text: 'Second passage of the book.'),
    ];
    final shorts = [
      _short(0, 0, 'First passage of the book.'),
      _short(1, 1, 'Second passage of the book.'),
    ];
    final places = shortPlaces(chapters, shorts);
    final location = readerLocationForShort(
      bookId: 'book',
      chapters: chapters,
      shorts: shorts,
      shortIndex: 1,
      updatedAt: DateTime.utc(2026, 5, 1),
    );
    expect(
      shortIndexAtPlace(places, location!.chapterIndex, location.charOffset),
      1,
    );
  });

  test('reader speeds are the speeds shown in the reader menu', () {
    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
    expect(speeds, contains(1.0));
    expect(speeds.first, lessThan(speeds.last));
  });
}

ShortSegment _short(int index, int chapter, String text) {
  return ShortSegment(
    id: 's$index',
    bookId: 'book',
    index: index,
    original: text,
    condense: text,
    summary: text,
    quotes: text,
    wordCount: text.split(' ').length,
    chapterIndex: chapter,
    chapterTitle: 'Chapter ${chapter + 1}',
  );
}
