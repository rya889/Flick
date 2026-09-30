import 'package:flick/models/models.dart';
import 'package:flick/services/book_pages.dart';
import 'package:flick/services/library_access.dart';
import 'package:flick/services/progress_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('free tier blocks a third import and EPUB', () {
    expect(
      blockImport(BookSource.txt, premium: false, importedBooks: 2),
      LibraryBlock.bookCap,
    );
    expect(
      blockImport(BookSource.epub, premium: false, importedBooks: 0),
      LibraryBlock.extensionLocked,
    );
    expect(
      blockImport(BookSource.paste, premium: false, importedBooks: 1),
      isNull,
    );
    expect(
      blockImport(BookSource.epub, premium: true, importedBooks: 2),
      isNull,
    );
  });

  test('reader place and short index refer to the same passage', () {
    const chapters = [
      ReaderChapter(
        index: 0,
        title: 'Chapter 1',
        text: 'Alice sat by the river and watched the water.',
      ),
      ReaderChapter(
        index: 1,
        title: 'Chapter 2',
        text: 'The rabbit hurried past with a watch.',
      ),
    ];
    final shorts = [
      _short(0, 0, 'Alice sat by the river and watched the water.'),
      _short(1, 1, 'The rabbit hurried past with a watch.'),
    ];
    final places = shortPlaces(chapters, shorts);
    expect(shortIndexAtPlace(places, 1, 0), 1);
    final back = readerLocationForShort(
      bookId: 'b',
      chapters: chapters,
      shorts: shorts,
      shortIndex: 0,
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    expect(back?.chapterIndex, 0);
    expect(shortIndexAtPlace(places, back!.chapterIndex, back.charOffset), 0);
  });
}

ShortSegment _short(int index, int chapter, String text) {
  return ShortSegment(
    id: 's$index',
    bookId: 'b',
    index: index,
    original: text,
    condense: text,
    summary: text,
    quotes: text,
    wordCount: 4,
    chapterIndex: chapter,
    chapterTitle: 'Chapter ${chapter + 1}',
  );
}
