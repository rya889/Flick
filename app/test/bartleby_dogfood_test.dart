import 'package:flutter_test/flutter_test.dart';
import 'package:flick/models/models.dart';
import 'package:flick/services/book_finish.dart';
import 'package:flick/services/library_access.dart';

void main() {
  test('Bartleby is the dogfood sample id', () {
    expect(sampleLibrary.first.id, kBartlebySampleId);
  });

  test('PD samples are never library-blocked', () {
    expect(
      blockImport(BookSource.sample, premium: false, importedBooks: 99),
      isNull,
    );
  });

  test('story finish triggers on last short index', () {
    expect(
      shouldCelebrateStoryFinish(
        mode: PlayMode.story,
        queueIndex: 4,
        queueLength: 5,
      ),
      isTrue,
    );
    expect(
      shouldCelebrateStoryFinish(
        mode: PlayMode.story,
        queueIndex: 2,
        queueLength: 5,
      ),
      isFalse,
    );
    expect(
      shouldCelebrateStoryFinish(
        mode: PlayMode.bounce,
        queueIndex: 9,
        queueLength: 10,
      ),
      isFalse,
    );
  });
}
