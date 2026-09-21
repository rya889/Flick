enum BookSource { epub, txt, paste, sample }

enum PlayMode { story, bounce }

enum ContentMode { full, tldr }

enum TldrSubmode { condense, summary, quotes }

enum ThemePreference { system, light, dark }

class LibraryBook {
  LibraryBook({
    required this.id,
    required this.title,
    this.author,
    required this.source,
    required this.text,
    required this.addedAt,
    this.coverHue = 32,
    this.shortCount = 0,
  });

  final String id;
  final String title;
  final String? author;
  final BookSource source;
  final String text;
  final DateTime addedAt;
  final double coverHue;
  final int shortCount;

  LibraryBook copyWith({int? shortCount}) {
    return LibraryBook(
      id: id,
      title: title,
      author: author,
      source: source,
      text: text,
      addedAt: addedAt,
      coverHue: coverHue,
      shortCount: shortCount ?? this.shortCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'source': source.name,
        'text': text,
        'addedAt': addedAt.toIso8601String(),
        'coverHue': coverHue,
        'shortCount': shortCount,
      };

  factory LibraryBook.fromJson(Map<String, dynamic> json) {
    return LibraryBook(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      source: BookSource.values.byName(json['source'] as String),
      text: json['text'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      coverHue: (json['coverHue'] as num?)?.toDouble() ?? 32,
      shortCount: json['shortCount'] as int? ?? 0,
    );
  }
}

class ShortSegment {
  ShortSegment({
    required this.id,
    required this.bookId,
    required this.index,
    required this.original,
    required this.condense,
    required this.summary,
    required this.quotes,
    required this.wordCount,
    required this.chapterIndex,
    required this.chapterTitle,
  });

  final String id;
  final String bookId;
  final int index;
  final String original;
  final String condense;
  final String summary;
  final String quotes;
  final int wordCount;
  final int chapterIndex;
  final String chapterTitle;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'index': index,
        'original': original,
        'condense': condense,
        'summary': summary,
        'quotes': quotes,
        'wordCount': wordCount,
        'chapterIndex': chapterIndex,
        'chapterTitle': chapterTitle,
      };

  factory ShortSegment.fromJson(Map<String, dynamic> json) {
    return ShortSegment(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      index: json['index'] as int,
      original: json['original'] as String,
      condense: json['condense'] as String? ?? json['original'] as String,
      summary: json['summary'] as String? ?? json['original'] as String,
      quotes: json['quotes'] as String? ?? json['original'] as String,
      wordCount: json['wordCount'] as int,
      chapterIndex: json['chapterIndex'] as int,
      chapterTitle: json['chapterTitle'] as String,
    );
  }
}

class ReadingProgress {
  ReadingProgress({
    required this.bookId,
    required this.shortIndex,
    required this.updatedAt,
  });

  final String bookId;
  final int shortIndex;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'shortIndex': shortIndex,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      bookId: json['bookId'] as String,
      shortIndex: json['shortIndex'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class SampleMeta {
  const SampleMeta({
    required this.id,
    required this.title,
    required this.author,
    required this.assetPath,
    required this.hue,
  });

  final String id;
  final String title;
  final String author;
  final String assetPath;
  final double hue;
}

const sampleLibrary = [
  SampleMeta(
    id: 'sample-alice',
    title: 'Alice in Wonderland',
    author: 'Lewis Carroll',
    assetPath: 'assets/samples/alice.txt',
    hue: 32,
  ),
  SampleMeta(
    id: 'sample-holmes',
    title: 'A Scandal in Bohemia',
    author: 'Arthur Conan Doyle',
    assetPath: 'assets/samples/holmes.txt',
    hue: 210,
  ),
  SampleMeta(
    id: 'sample-metamorphosis',
    title: 'The Metamorphosis',
    author: 'Franz Kafka',
    assetPath: 'assets/samples/metamorphosis.txt',
    hue: 145,
  ),
];
