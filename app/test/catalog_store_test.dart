import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flick/data/flick_database.dart';
import 'package:flick/models/models.dart';
import 'package:flick/services/catalog_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CatalogStore persists books and shorts in Drift', () async {
    SharedPreferences.setMockInitialValues({});
    final db = FlickDatabase(NativeDatabase.memory());
    final store = CatalogStore(database: db);
    await store.init();

    final book = await store.importText(
      title: 'Paste Book',
      text:
          'Chapter 1\n\nHello world from Flick. This is a longer sentence so the short builder keeps it. Another sentence follows for good measure.',
      source: BookSource.paste,
    );

    final books = await store.loadBooks();
    expect(books.map((b) => b.id), contains(book.id));
    expect(books.first.title, 'Paste Book');

    final shorts = await store.loadShorts(book.id);
    expect(shorts, isNotEmpty);

    await store.saveProgress({
      book.id: ReadingProgress(
        bookId: book.id,
        shortId: shorts.first.id,
        shortIndex: 0,
        updatedAt: DateTime.now(),
      ),
    });
    final progress = await store.loadProgress();
    expect(progress[book.id]?.shortIndex, 0);

    await store.close();
  });

  test('paste limits reject oversized text', () async {
    SharedPreferences.setMockInitialValues({});
    final db = FlickDatabase(NativeDatabase.memory());
    final store = CatalogStore(database: db);
    await store.init();

    final huge = List.filled(120000, 'word').join(' ');
    expect(
      () => store.importText(title: 'Too big', text: huge),
      throwsA(isA<StateError>()),
    );
    await store.close();
  });
}
