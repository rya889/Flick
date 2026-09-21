import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'short_builder.dart';

class CatalogStore {
  static const _booksKey = 'flick.books.v1';
  static const _shortsPrefix = 'flick.shorts.v1.';
  static const _progressKey = 'flick.progress.v1';
  static const _heartsKey = 'flick.hearts.v1';
  static const _savesKey = 'flick.saves.v1';
  static const _listenKey = 'flick.listen.v1';
  static const _lastBookKey = 'flick.lastBook.v1';
  static const _settingsKey = 'flick.settings.v1';
  static const _plusKey = 'flick.plusDemo.v1';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<LibraryBook>> loadBooks() async {
    final raw = _prefs.getString(_booksKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => LibraryBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveBooks(List<LibraryBook> books) async {
    await _prefs.setString(
      _booksKey,
      jsonEncode(books.map((b) => b.toJson()).toList()),
    );
  }

  Future<List<ShortSegment>> loadShorts(String bookId) async {
    final raw = _prefs.getString('$_shortsPrefix$bookId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ShortSegment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveShorts(String bookId, List<ShortSegment> shorts) async {
    await _prefs.setString(
      '$_shortsPrefix$bookId',
      jsonEncode(shorts.map((s) => s.toJson()).toList()),
    );
  }

  Future<Map<String, ReadingProgress>> loadProgress() async {
    final raw = _prefs.getString(_progressKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map(
      (k, v) => MapEntry(k, ReadingProgress.fromJson(v as Map<String, dynamic>)),
    );
  }

  Future<void> saveProgress(Map<String, ReadingProgress> progress) async {
    await _prefs.setString(
      _progressKey,
      jsonEncode(progress.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  Future<Set<String>> loadIds(String key) async {
    final list = _prefs.getStringList(key) ?? [];
    return list.toSet();
  }

  Future<void> saveIds(String key, Set<String> ids) async {
    await _prefs.setStringList(key, ids.toList());
  }

  Future<Set<String>> loadHearts() => loadIds(_heartsKey);
  Future<void> saveHearts(Set<String> ids) => saveIds(_heartsKey, ids);
  Future<Set<String>> loadSaves() => loadIds(_savesKey);
  Future<void> saveSaves(Set<String> ids) => saveIds(_savesKey, ids);

  Future<({String day, int seconds})> loadListen() async {
    final raw = _prefs.getString(_listenKey);
    if (raw == null) {
      return (day: _todayKey(), seconds: 0);
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return (
      day: map['day'] as String? ?? _todayKey(),
      seconds: map['seconds'] as int? ?? 0,
    );
  }

  Future<void> saveListen(String day, int seconds) async {
    await _prefs.setString(
      _listenKey,
      jsonEncode({'day': day, 'seconds': seconds}),
    );
  }

  String? get lastBookId => _prefs.getString(_lastBookKey);
  Future<void> setLastBookId(String? id) async {
    if (id == null) {
      await _prefs.remove(_lastBookKey);
    } else {
      await _prefs.setString(_lastBookKey, id);
    }
  }

  bool get plusDemo => _prefs.getBool(_plusKey) ?? false;
  Future<void> setPlusDemo(bool value) => _prefs.setBool(_plusKey, value);

  ThemePreference get themePreference {
    final name = _prefs.getString('$_settingsKey.theme');
    if (name == null) return ThemePreference.system;
    return ThemePreference.values.byName(name);
  }

  Future<void> setThemePreference(ThemePreference value) async {
    await _prefs.setString('$_settingsKey.theme', value.name);
  }

  double get playbackSpeed => _prefs.getDouble('$_settingsKey.speed') ?? 1.0;
  Future<void> setPlaybackSpeed(double value) =>
      _prefs.setDouble('$_settingsKey.speed', value);

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<LibraryBook> importSample(SampleMeta sample) async {
    final text = await rootBundle.loadString(sample.assetPath);
    final book = LibraryBook(
      id: sample.id,
      title: sample.title,
      author: sample.author,
      source: BookSource.sample,
      text: text,
      addedAt: DateTime.now(),
      coverHue: sample.hue,
    );
    final shorts = buildShorts(book);
    await saveShorts(book.id, shorts);
    return book.copyWith(shortCount: shorts.length);
  }

  Future<LibraryBook> importText({
    required String title,
    required String text,
    BookSource source = BookSource.paste,
    String? author,
    double hue = 200,
  }) async {
    final id =
        '${source.name}-${DateTime.now().millisecondsSinceEpoch}';
    final book = LibraryBook(
      id: id,
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      author: author,
      source: source,
      text: text,
      addedAt: DateTime.now(),
      coverHue: hue,
    );
    final shorts = buildShorts(book);
    await saveShorts(book.id, shorts);
    return book.copyWith(shortCount: shorts.length);
  }
}
