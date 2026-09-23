import 'package:flutter_test/flutter_test.dart';

import 'package:flick/services/abbreviate.dart';
import 'package:flick/services/short_builder.dart';
import 'package:flick/models/models.dart';

void main() {
  test('abbreviate shortens long passages', () {
    const text =
        'Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do. Once or twice she had peeped into the book her sister was reading. There were no pictures or conversations in it. "And what is the use of a book," thought Alice, "without pictures or conversations?"';
    final out = abbreviate(text);
    expect(wordCount(out), lessThan(wordCount(text)));
    expect(out.isNotEmpty, isTrue);
  });

  test('buildShorts creates chapter-aware segments', () {
    final book = LibraryBook(
      id: 't',
      title: 'Test',
      source: BookSource.paste,
      text: '''
Chapter 1

Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do. Once or twice she had peeped into the book her sister was reading.

Chapter 2

Suddenly a White Rabbit with pink eyes ran close by her. There was nothing so very remarkable in that; nor did Alice think it so very much out of the way to hear the Rabbit say to itself "Oh dear! Oh dear! I shall be late!"
''',
      addedAt: DateTime.now(),
    );
    final shorts = buildShorts(book);
    expect(shorts.length, greaterThanOrEqualTo(2));
    expect(shorts.first.chapterIndex, 0);
    expect(shorts.any((s) => s.chapterIndex == 1), isTrue);
  });
}
