import 'package:flick/models/models.dart';
import 'package:flick/models/reader_sync.dart';
import 'package:flick/services/book_pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chaptersFromPlainText splits on chapter headings', () {
    const text = '''
Chapter 1

Alice sat on the bank.

Chapter 2

The rabbit ran past.
''';
    final chapters = chaptersFromPlainText(text);
    expect(chapters.length, 2);
    expect(chapters.first.title, 'Chapter 1');
    expect(chapters.last.text, contains('rabbit'));
  });

  test('paginateBook does not cut a word in half', () {
    final chapter = ReaderChapter(
      index: 0,
      title: 'Chapter 1',
      text: List.filled(80, 'wonderland').join(' '),
    );
    final pages = paginateBook([chapter], 32);
    expect(pages.length, greaterThan(1));
    for (final page in pages) {
      expect(page.text.endsWith('wonderland'), isTrue);
    }
  });

  test('pageIndexForLocation stays in the saved chapter', () {
    final pages = paginateBook(
      [
        const ReaderChapter(index: 0, title: 'A', text: 'one two three four five'),
        const ReaderChapter(index: 1, title: 'B', text: 'six seven eight nine ten'),
      ],
      14,
    );
    final index = pageIndexForLocation(pages, 1, 0);
    expect(pages[index].chapterIndex, 1);
  });

  test('restore keeps newer reader place and adds missing books', () {
    final localBook = _book('local', 'Local');
    final remoteBook = _book('remote', 'Remote');
    final older = DateTime.utc(2026, 1, 1);
    final newer = DateTime.utc(2026, 6, 1);

    final incoming = LibrarySnapshot(
      exportedAt: newer,
      books: [localBook, remoteBook],
      shortsByBook: {
        'remote': [
          ShortSegment(
            id: 'remote-short-0',
            bookId: 'remote',
            index: 0,
            original: 'Hello from the other phone.',
            condense: 'Hello.',
            summary: 'Hello.',
            quotes: 'Hello.',
            wordCount: 5,
            chapterIndex: 0,
            chapterTitle: 'Chapter 1',
          ),
        ],
      },
      progress: {
        'local': ReadingProgress(
          bookId: 'local',
          shortIndex: 3,
          updatedAt: newer,
        ),
      },
      reader: {
        'local': ReaderLocation(
          bookId: 'local',
          chapterIndex: 2,
          charOffset: 40,
          updatedAt: older,
        ),
      },
      hearts: {'h1'},
      saves: {'s1'},
    );

    final plan = planLibraryMerge(
      localBooks: [localBook],
      localProgress: {
        'local': ReadingProgress(
          bookId: 'local',
          shortIndex: 1,
          updatedAt: older,
        ),
      },
      localReader: {
        'local': ReaderLocation(
          bookId: 'local',
          chapterIndex: 4,
          charOffset: 10,
          updatedAt: newer,
        ),
      },
      localHearts: {'h0'},
      localSaves: {},
      incoming: incoming,
    );

    expect(plan.booksToAdd.map((b) => b.id), ['remote']);
    expect(plan.progress['local']!.shortIndex, 3);
    expect(plan.reader['local']!.chapterIndex, 4);
    expect(plan.hearts, {'h0', 'h1'});
    expect(plan.saves, {'s1'});

    final again = LibrarySnapshot.decode(incoming.encode());
    expect(again.books.map((b) => b.title), ['Local', 'Remote']);
  });
}

LibraryBook _book(String id, String title) {
  return LibraryBook(
    id: id,
    title: title,
    source: BookSource.paste,
    text: 'A short book about $title.',
    addedAt: DateTime.utc(2026, 1, 1),
  );
}
