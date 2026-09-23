import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'flick_database.g.dart';

@DataClassName('LibraryBookRow')
class LibraryBooks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get source => text()();
  TextColumn get fileUri => text().nullable()();
  TextColumn get rawTextRef => text().nullable()();
  TextColumn get bodyText => text()();
  DateTimeColumn get addedAt => dateTime()();
  RealColumn get coverHue => real().withDefault(const Constant(32.0))();
  IntColumn get shortCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ChapterRow')
class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookId => text()();
  IntColumn get chapterIndex => integer()();
  TextColumn get title => text()();
  IntColumn get startOffset => integer()();
  IntColumn get endOffset => integer()();
}

@DataClassName('ShortRow')
class Shorts extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  IntColumn get shortIndex => integer()();
  TextColumn get original => text()();
  TextColumn get condense => text()();
  TextColumn get summary => text()();
  TextColumn get quotes => text()();
  IntColumn get wordCount => integer()();
  IntColumn get chapterIndex => integer()();
  TextColumn get chapterTitle => text()();
  TextColumn get tldrSource => text().withDefault(const Constant('extractive'))();
  TextColumn get contentHash => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProgressRow')
class ProgressRows extends Table {
  TextColumn get bookId => text()();
  TextColumn get shortId => text().nullable()();
  IntColumn get shortIndex => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {bookId};
}

@DataClassName('MetaKvRow')
class MetaKv extends Table {
  TextColumn get metaKey => text()();
  TextColumn get metaValue => text()();

  @override
  Set<Column<Object>> get primaryKey => {metaKey};
}

@DriftDatabase(tables: [LibraryBooks, Chapters, Shorts, ProgressRows, MetaKv])
class FlickDatabase extends _$FlickDatabase {
  FlickDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'flick'));

  @override
  int get schemaVersion => 1;
}
