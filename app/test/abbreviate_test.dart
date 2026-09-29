import 'package:flick/services/abbreviate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const multi =
      'The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down. '
      'Alice had not a moment to think about stopping herself before she found herself falling down a very deep well. '
      'Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her and to wonder what was going to happen next. '
      'First, she tried to look down and make out what she was coming to, but it was too dark to see anything.';

  test('sentenceSplit finds multiple sentences', () {
    expect(sentenceSplit(multi).length, greaterThanOrEqualTo(3));
  });

  test('abbreviate keeps more than the first sentence when possible', () {
    final sentences = sentenceSplit(multi);
    final condensed = abbreviate(multi);
    expect(condensed, isNot(equals(sentences.first)));
    // Should retain material from later in the passage.
    expect(
      condensed.toLowerCase().contains('falling') ||
          condensed.toLowerCase().contains('well') ||
          condensed.toLowerCase().contains('dark'),
      isTrue,
    );
    expect(wordCount(condensed), lessThan(wordCount(multi)));
    expect(wordCount(condensed), greaterThan(12));
  });

  test('summary is a multi-sentence gist when passage allows', () {
    final summary = summarizePassage(multi);
    expect(summary.toLowerCase(), isNot(startsWith('summary:')));
    expect(sentenceSplit(summary).length, greaterThanOrEqualTo(2));
    expect(wordCount(summary), lessThan(wordCount(multi)));
  });

  test('quotes prefer dialogue', () {
    const withDialogue =
        'She looked at the book with some curiosity. '
        '"And what is the use of a book," thought Alice, "without pictures or conversations?" '
        'So she was considering in her own mind whether the pleasure of making a daisy-chain would be worth the trouble.';
    final quotes = keyQuotes(withDialogue);
    expect(quotes, contains('use of a book'));
  });
}
