import 'dart:convert';

import 'models.dart';

enum SyncTarget { device, googleDrive, files }

enum ReaderPaper { paper, sepia, ink }

class ReaderLocation {
  const ReaderLocation({
    required this.bookId,
    required this.chapterIndex,
    required this.charOffset,
    required this.updatedAt,
  });

  final String bookId;
  final int chapterIndex;
  final int charOffset;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'chapterIndex': chapterIndex,
        'charOffset': charOffset,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ReaderLocation.fromJson(Map<String, dynamic> json) {
    return ReaderLocation(
      bookId: json['bookId'] as String,
      chapterIndex: json['chapterIndex'] as int? ?? 0,
      charOffset: json['charOffset'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class LibrarySnapshot {
  LibrarySnapshot({
    required this.exportedAt,
    required this.books,
    required this.shortsByBook,
    required this.progress,
    required this.reader,
    required this.hearts,
    required this.saves,
  });

  static const format = 'flick-library';
  static const version = 1;

  final DateTime exportedAt;
  final List<LibraryBook> books;
  final Map<String, List<ShortSegment>> shortsByBook;
  final Map<String, ReadingProgress> progress;
  final Map<String, ReaderLocation> reader;
  final Set<String> hearts;
  final Set<String> saves;

  String encode() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
        'format': format,
        'version': version,
        'exportedAt': exportedAt.toIso8601String(),
        'books': books.map((b) => b.toJson()).toList(),
        'shorts': {
          for (final entry in shortsByBook.entries)
            entry.key: entry.value.map((s) => s.toJson()).toList(),
        },
        'progress': {
          for (final entry in progress.entries) entry.key: entry.value.toJson(),
        },
        'reader': {
          for (final entry in reader.entries) entry.key: entry.value.toJson(),
        },
        'hearts': hearts.toList(),
        'saves': saves.toList(),
      };

  factory LibrarySnapshot.decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Flick library file is not a JSON object.');
    }
    if (decoded['format'] != format) {
      throw const FormatException('This file is not a Flick library backup.');
    }
    final version = decoded['version'];
    if (version is! int || version > LibrarySnapshot.version) {
      throw FormatException('This Flick library file is version $version.');
    }

    final books = (decoded['books'] as List<dynamic>? ?? [])
        .map((e) => LibraryBook.fromJson(e as Map<String, dynamic>))
        .toList();
    final shortsRaw = decoded['shorts'] as Map<String, dynamic>? ?? {};
    final shortsByBook = <String, List<ShortSegment>>{
      for (final entry in shortsRaw.entries)
        entry.key: (entry.value as List<dynamic>)
            .map((s) => ShortSegment.fromJson(s as Map<String, dynamic>))
            .toList(),
    };
    final progressRaw = decoded['progress'] as Map<String, dynamic>? ?? {};
    final progress = <String, ReadingProgress>{
      for (final entry in progressRaw.entries)
        entry.key:
            ReadingProgress.fromJson(entry.value as Map<String, dynamic>),
    };
    final readerRaw = decoded['reader'] as Map<String, dynamic>? ?? {};
    final reader = <String, ReaderLocation>{
      for (final entry in readerRaw.entries)
        entry.key: ReaderLocation.fromJson(entry.value as Map<String, dynamic>),
    };
    return LibrarySnapshot(
      exportedAt: DateTime.parse(decoded['exportedAt'] as String),
      books: books,
      shortsByBook: shortsByBook,
      progress: progress,
      reader: reader,
      hearts: {...(decoded['hearts'] as List<dynamic>? ?? []).cast<String>()},
      saves: {...(decoded['saves'] as List<dynamic>? ?? []).cast<String>()},
    );
  }
}

class MergePlan {
  const MergePlan({
    required this.booksToAdd,
    required this.shortsForNewBooks,
    required this.progress,
    required this.reader,
    required this.hearts,
    required this.saves,
    required this.progressUpdates,
    required this.readerUpdates,
  });

  final List<LibraryBook> booksToAdd;
  final Map<String, List<ShortSegment>> shortsForNewBooks;
  final Map<String, ReadingProgress> progress;
  final Map<String, ReaderLocation> reader;
  final Set<String> hearts;
  final Set<String> saves;
  final int progressUpdates;
  final int readerUpdates;
}

MergePlan planLibraryMerge({
  required List<LibraryBook> localBooks,
  required Map<String, ReadingProgress> localProgress,
  required Map<String, ReaderLocation> localReader,
  required Set<String> localHearts,
  required Set<String> localSaves,
  required LibrarySnapshot incoming,
}) {
  final known = {for (final book in localBooks) book.id};
  final booksToAdd = <LibraryBook>[];
  final shortsForNewBooks = <String, List<ShortSegment>>{};
  for (final book in incoming.books) {
    if (known.contains(book.id)) continue;
    booksToAdd.add(book);
    shortsForNewBooks[book.id] = incoming.shortsByBook[book.id] ?? const [];
  }

  final progress = Map<String, ReadingProgress>.from(localProgress);
  var progressUpdates = 0;
  for (final entry in incoming.progress.entries) {
    final current = progress[entry.key];
    if (current == null || entry.value.updatedAt.isAfter(current.updatedAt)) {
      if (current != null) progressUpdates += 1;
      if (current == null) progressUpdates += 1;
      progress[entry.key] = entry.value;
    }
  }

  final reader = Map<String, ReaderLocation>.from(localReader);
  var readerUpdates = 0;
  for (final entry in incoming.reader.entries) {
    final current = reader[entry.key];
    if (current == null || entry.value.updatedAt.isAfter(current.updatedAt)) {
      readerUpdates += 1;
      reader[entry.key] = entry.value;
    }
  }

  return MergePlan(
    booksToAdd: booksToAdd,
    shortsForNewBooks: shortsForNewBooks,
    progress: progress,
    reader: reader,
    hearts: {...localHearts, ...incoming.hearts},
    saves: {...localSaves, ...incoming.saves},
    progressUpdates: progressUpdates,
    readerUpdates: readerUpdates,
  );
}
