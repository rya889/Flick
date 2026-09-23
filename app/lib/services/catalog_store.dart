import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/flick_database.dart';
import '../models/models.dart';
import 'book_blob_store.dart';
import 'epub_parser.dart';
import 'short_builder.dart';

/// Paste limits from backend spec §5.
const maxPasteBytes = 500 * 1024;
const maxPasteWords = 100000;

class CatalogStore {
  CatalogStore({FlickDatabase? database}) : _db = database ?? FlickDatabase();

  final FlickDatabase _db;
  SharedPreferences? _prefs;
  bool _migrated = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _migrateFromPrefsIfNeeded();
  }

  Future<void> close() => _db.close();

  Future<List<LibraryBook>> loadBooks() async {
    final rows = await (_db.select(_db.libraryBooks)
          ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
        .get();
    return rows.map(_bookFromRow).toList();
  }

  Future<void> saveBooks(List<LibraryBook> books) async {
    await _db.transaction(() async {
      for (final book in books) {
        await _upsertBook(book);
      }
    });
  }

  Future<List<ShortSegment>> loadShorts(String bookId) async {
    final rows = await (_db.select(_db.shorts)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.asc(t.shortIndex)]))
        .get();
    return rows.map(_shortFromRow).toList();
  }

  Future<void> saveShorts(String bookId, List<ShortSegment> shorts) async {
    await _db.transaction(() async {
      await (_db.delete(_db.shorts)..where((t) => t.bookId.equals(bookId)))
          .go();
      for (final s in shorts) {
        await _db.into(_db.shorts).insertOnConflictUpdate(_shortCompanion(s));
      }
    });
  }

  Future<Map<String, ReadingProgress>> loadProgress() async {
    final rows = await _db.select(_db.progressRows).get();
    return {
      for (final r in rows)
        r.bookId: ReadingProgress(
          bookId: r.bookId,
          shortIndex: r.shortIndex,
          updatedAt: r.updatedAt,
          shortId: r.shortId,
        ),
    };
  }

  Future<void> saveProgress(Map<String, ReadingProgress> progress) async {
    await _db.transaction(() async {
      for (final entry in progress.entries) {
        final prog = entry.value;
        await _db.into(_db.progressRows).insertOnConflictUpdate(
              ProgressRowsCompanion(
                bookId: Value(prog.bookId),
                shortId: Value(prog.shortId),
                shortIndex: Value(prog.shortIndex),
                updatedAt: Value(prog.updatedAt),
              ),
            );
      }
    });
  }

  Future<Set<String>> loadHearts() async => _loadIdSet('hearts');
  Future<void> saveHearts(Set<String> ids) => _saveIdSet('hearts', ids);
  Future<Set<String>> loadSaves() async => _loadIdSet('saves');
  Future<void> saveSaves(Set<String> ids) => _saveIdSet('saves', ids);

  Future<({String day, int seconds})> loadListen() async {
    final day = await _getMeta('listen.day');
    final secondsRaw = await _getMeta('listen.seconds');
    return (
      day: day ?? _todayKey(),
      seconds: int.tryParse(secondsRaw ?? '0') ?? 0,
    );
  }

  Future<void> saveListen(String day, int seconds) async {
    await _setMeta('listen.day', day);
    await _setMeta('listen.seconds', '$seconds');
  }

  Future<String?> get lastBookId async => _getMeta('lastBook');

  Future<void> setLastBookId(String? id) async {
    if (id == null) {
      await (_db.delete(_db.metaKv)..where((t) => t.metaKey.equals('lastBook')))
          .go();
    } else {
      await _setMeta('lastBook', id);
    }
  }

  Future<bool> get plusDemo async => (await _getMeta('plusDemo')) == 'true';

  Future<void> setPlusDemo(bool value) =>
      _setMeta('plusDemo', value ? 'true' : 'false');

  Future<void> updateShort(ShortSegment short) async {
    await _db.into(_db.shorts).insertOnConflictUpdate(_shortCompanion(short));
  }

  Future<ThemePreference> get themePreference async {
    final name = await _getMeta('theme');
    if (name == null) return ThemePreference.system;
    return ThemePreference.values.byName(name);
  }

  Future<void> setThemePreference(ThemePreference value) =>
      _setMeta('theme', value.name);

  Future<double> get playbackSpeed async {
    final raw = await _getMeta('speed');
    return double.tryParse(raw ?? '') ?? 1.0;
  }

  Future<void> setPlaybackSpeed(double value) =>
      _setMeta('speed', value.toString());

  Future<LibraryBook> importSample(SampleMeta sample) async {
    final text = await rootBundle.loadString(sample.assetPath);
    return _persistImportedBook(
      LibraryBook(
        id: sample.id,
        title: sample.title,
        author: sample.author,
        source: BookSource.sample,
        text: text,
        addedAt: DateTime.now(),
        coverHue: sample.hue,
      ),
    );
  }

  Future<LibraryBook> importText({
    required String title,
    required String text,
    BookSource source = BookSource.paste,
    String? author,
    double hue = 200,
    String? fileUri,
  }) async {
    _assertPasteLimits(text, source: source);
    final id = '${source.name}-${DateTime.now().millisecondsSinceEpoch}';
    final rawTextRef = await writeTextBlob(id, text);
    return _persistImportedBook(
      LibraryBook(
        id: id,
        title: title.trim().isEmpty ? 'Untitled' : title.trim(),
        author: author,
        source: source,
        text: text,
        addedAt: DateTime.now(),
        coverHue: hue,
        fileUri: fileUri,
        rawTextRef: rawTextRef,
      ),
    );
  }

  Future<LibraryBook> importEpubBytes({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final parsed = parseEpubBytes(
      bytes,
      fallbackTitle: fileName,
    );
    final id = 'epub-${DateTime.now().millisecondsSinceEpoch}';
    final fileUri = await writeBinaryBlob(id, 'epub', bytes);
    final rawTextRef = await writeTextBlob(id, parsed.text);
    final book = LibraryBook(
      id: id,
      title: parsed.title,
      author: parsed.author,
      source: BookSource.epub,
      text: parsed.text,
      addedAt: DateTime.now(),
      coverHue: 28 + (parsed.title.hashCode % 40).abs().toDouble(),
      fileUri: fileUri,
      rawTextRef: rawTextRef,
    );
    final shorts = buildShorts(book);
    await _db.transaction(() async {
      await _upsertBook(book.copyWith(shortCount: shorts.length));
      await (_db.delete(_db.chapters)..where((t) => t.bookId.equals(id))).go();
      for (final ch in parsed.chapters) {
        await _db.into(_db.chapters).insert(
              ChaptersCompanion.insert(
                bookId: id,
                chapterIndex: ch.index,
                title: ch.title,
                startOffset: ch.startOffset,
                endOffset: ch.endOffset,
              ),
            );
      }
      await (_db.delete(_db.shorts)..where((t) => t.bookId.equals(id))).go();
      for (final s in shorts) {
        await _db.into(_db.shorts).insert(_shortCompanion(s));
      }
    });
    return book.copyWith(shortCount: shorts.length);
  }

  void _assertPasteLimits(String text, {required BookSource source}) {
    if (source != BookSource.paste) return;
    final bytes = utf8.encode(text).length;
    final words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    if (bytes > maxPasteBytes) {
      throw StateError(
        'Paste exceeds ${maxPasteBytes ~/ 1024}KB limit ($bytes bytes).',
      );
    }
    if (words > maxPasteWords) {
      throw StateError(
        'Paste exceeds $maxPasteWords word limit ($words words).',
      );
    }
  }

  Future<LibraryBook> _persistImportedBook(LibraryBook book) async {
    final shorts = buildShorts(book);
    final withCount = book.copyWith(shortCount: shorts.length);
    await _db.transaction(() async {
      await _upsertBook(withCount);
      await (_db.delete(_db.shorts)..where((t) => t.bookId.equals(book.id)))
          .go();
      for (final s in shorts) {
        await _db.into(_db.shorts).insert(_shortCompanion(s));
      }
    });
    return withCount;
  }

  Future<void> _upsertBook(LibraryBook book) async {
    await _db.into(_db.libraryBooks).insertOnConflictUpdate(
          LibraryBooksCompanion(
            id: Value(book.id),
            title: Value(book.title),
            author: Value(book.author),
            source: Value(book.source.name),
            fileUri: Value(book.fileUri),
            rawTextRef: Value(book.rawTextRef),
            bodyText: Value(book.text),
            addedAt: Value(book.addedAt),
            coverHue: Value(book.coverHue),
            shortCount: Value(book.shortCount),
          ),
        );
  }

  LibraryBook _bookFromRow(LibraryBookRow row) {
    return LibraryBook(
      id: row.id,
      title: row.title,
      author: row.author,
      source: BookSource.values.byName(row.source),
      text: row.bodyText,
      addedAt: row.addedAt,
      coverHue: row.coverHue,
      shortCount: row.shortCount,
      fileUri: row.fileUri,
      rawTextRef: row.rawTextRef,
    );
  }

  ShortSegment _shortFromRow(ShortRow row) {
    return ShortSegment(
      id: row.id,
      bookId: row.bookId,
      index: row.shortIndex,
      original: row.original,
      condense: row.condense,
      summary: row.summary,
      quotes: row.quotes,
      wordCount: row.wordCount,
      chapterIndex: row.chapterIndex,
      chapterTitle: row.chapterTitle,
      tldrSource: row.tldrSource,
      contentHash: row.contentHash,
    );
  }

  ShortsCompanion _shortCompanion(ShortSegment s) {
    final hash = sha1.convert(utf8.encode(s.original)).toString();
    return ShortsCompanion(
      id: Value(s.id),
      bookId: Value(s.bookId),
      shortIndex: Value(s.index),
      original: Value(s.original),
      condense: Value(s.condense),
      summary: Value(s.summary),
      quotes: Value(s.quotes),
      wordCount: Value(s.wordCount),
      chapterIndex: Value(s.chapterIndex),
      chapterTitle: Value(s.chapterTitle),
      tldrSource: Value(s.tldrSource ?? 'extractive'),
      contentHash: Value(s.contentHash ?? hash),
    );
  }

  Future<Set<String>> _loadIdSet(String key) async {
    final raw = await _getMeta(key);
    if (raw == null || raw.isEmpty) return {};
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => e as String).toSet();
  }

  Future<void> _saveIdSet(String key, Set<String> ids) async {
    await _setMeta(key, jsonEncode(ids.toList()));
  }

  Future<String?> _getMeta(String key) async {
    final row =
        await (_db.select(_db.metaKv)..where((t) => t.metaKey.equals(key)))
            .getSingleOrNull();
    return row?.metaValue;
  }

  Future<void> _setMeta(String key, String value) async {
    await _db.into(_db.metaKv).insertOnConflictUpdate(
          MetaKvCompanion(metaKey: Value(key), metaValue: Value(value)),
        );
  }

  Future<void> _migrateFromPrefsIfNeeded() async {
    if (_migrated) return;
    _migrated = true;
    final prefs = _prefs;
    if (prefs == null) return;

    final already = await _getMeta('migratedFromPrefs.v1');
    if (already == 'true') return;

    final existing = await _db.select(_db.libraryBooks).get();
    if (existing.isNotEmpty) {
      await _setMeta('migratedFromPrefs.v1', 'true');
      return;
    }

    final booksRaw = prefs.getString('flick.books.v1');
    if (booksRaw != null) {
      final list = jsonDecode(booksRaw) as List<dynamic>;
      for (final e in list) {
        final book = LibraryBook.fromJson(e as Map<String, dynamic>);
        final shortsRaw = prefs.getString('flick.shorts.v1.${book.id}');
        final shorts = shortsRaw == null
            ? buildShorts(book)
            : (jsonDecode(shortsRaw) as List<dynamic>)
                .map((s) => ShortSegment.fromJson(s as Map<String, dynamic>))
                .toList();
        await _upsertBook(book.copyWith(shortCount: shorts.length));
        for (final s in shorts) {
          await _db.into(_db.shorts).insertOnConflictUpdate(_shortCompanion(s));
        }
      }
    }

    final progressRaw = prefs.getString('flick.progress.v1');
    if (progressRaw != null) {
      final map = jsonDecode(progressRaw) as Map<String, dynamic>;
      for (final entry in map.entries) {
        final prog =
            ReadingProgress.fromJson(entry.value as Map<String, dynamic>);
        await _db.into(_db.progressRows).insertOnConflictUpdate(
              ProgressRowsCompanion(
                bookId: Value(prog.bookId),
                shortId: Value(prog.shortId),
                shortIndex: Value(prog.shortIndex),
                updatedAt: Value(prog.updatedAt),
              ),
            );
      }
    }

    final hearts = prefs.getStringList('flick.hearts.v1');
    if (hearts != null) await _saveIdSet('hearts', hearts.toSet());
    final saves = prefs.getStringList('flick.saves.v1');
    if (saves != null) await _saveIdSet('saves', saves.toSet());

    final listenRaw = prefs.getString('flick.listen.v1');
    if (listenRaw != null) {
      final map = jsonDecode(listenRaw) as Map<String, dynamic>;
      await saveListen(
        map['day'] as String? ?? _todayKey(),
        map['seconds'] as int? ?? 0,
      );
    }

    final last = prefs.getString('flick.lastBook.v1');
    if (last != null) await setLastBookId(last);

    final plus = prefs.getBool('flick.plusDemo.v1');
    if (plus != null) await setPlusDemo(plus);

    final theme = prefs.getString('flick.settings.v1.theme');
    if (theme != null) {
      await setThemePreference(ThemePreference.values.byName(theme));
    }
    final speed = prefs.getDouble('flick.settings.v1.speed');
    if (speed != null) await setPlaybackSpeed(speed);

    await prefs.remove('flick.books.v1');
    for (final key
        in prefs.getKeys().where((k) => k.startsWith('flick.shorts.v1.'))) {
      await prefs.remove(key);
    }
    await prefs.remove('flick.progress.v1');
    await prefs.remove('flick.hearts.v1');
    await prefs.remove('flick.saves.v1');
    await prefs.remove('flick.listen.v1');

    await _setMeta('migratedFromPrefs.v1', 'true');
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}
