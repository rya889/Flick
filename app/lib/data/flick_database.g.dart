// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flick_database.dart';

// ignore_for_file: type=lint
class $LibraryBooksTable extends LibraryBooks
    with TableInfo<$LibraryBooksTable, LibraryBookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileUriMeta = const VerificationMeta(
    'fileUri',
  );
  @override
  late final GeneratedColumn<String> fileUri = GeneratedColumn<String>(
    'file_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawTextRefMeta = const VerificationMeta(
    'rawTextRef',
  );
  @override
  late final GeneratedColumn<String> rawTextRef = GeneratedColumn<String>(
    'raw_text_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyTextMeta = const VerificationMeta(
    'bodyText',
  );
  @override
  late final GeneratedColumn<String> bodyText = GeneratedColumn<String>(
    'body_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverHueMeta = const VerificationMeta(
    'coverHue',
  );
  @override
  late final GeneratedColumn<double> coverHue = GeneratedColumn<double>(
    'cover_hue',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(32.0),
  );
  static const VerificationMeta _shortCountMeta = const VerificationMeta(
    'shortCount',
  );
  @override
  late final GeneratedColumn<int> shortCount = GeneratedColumn<int>(
    'short_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    source,
    fileUri,
    rawTextRef,
    bodyText,
    addedAt,
    coverHue,
    shortCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryBookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('file_uri')) {
      context.handle(
        _fileUriMeta,
        fileUri.isAcceptableOrUnknown(data['file_uri']!, _fileUriMeta),
      );
    }
    if (data.containsKey('raw_text_ref')) {
      context.handle(
        _rawTextRefMeta,
        rawTextRef.isAcceptableOrUnknown(
          data['raw_text_ref']!,
          _rawTextRefMeta,
        ),
      );
    }
    if (data.containsKey('body_text')) {
      context.handle(
        _bodyTextMeta,
        bodyText.isAcceptableOrUnknown(data['body_text']!, _bodyTextMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyTextMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('cover_hue')) {
      context.handle(
        _coverHueMeta,
        coverHue.isAcceptableOrUnknown(data['cover_hue']!, _coverHueMeta),
      );
    }
    if (data.containsKey('short_count')) {
      context.handle(
        _shortCountMeta,
        shortCount.isAcceptableOrUnknown(data['short_count']!, _shortCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryBookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryBookRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fileUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_uri'],
      ),
      rawTextRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text_ref'],
      ),
      bodyText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_text'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      coverHue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cover_hue'],
      )!,
      shortCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}short_count'],
      )!,
    );
  }

  @override
  $LibraryBooksTable createAlias(String alias) {
    return $LibraryBooksTable(attachedDatabase, alias);
  }
}

class LibraryBookRow extends DataClass implements Insertable<LibraryBookRow> {
  final String id;
  final String title;
  final String? author;
  final String source;
  final String? fileUri;
  final String? rawTextRef;
  final String bodyText;
  final DateTime addedAt;
  final double coverHue;
  final int shortCount;
  const LibraryBookRow({
    required this.id,
    required this.title,
    this.author,
    required this.source,
    this.fileUri,
    this.rawTextRef,
    required this.bodyText,
    required this.addedAt,
    required this.coverHue,
    required this.shortCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || fileUri != null) {
      map['file_uri'] = Variable<String>(fileUri);
    }
    if (!nullToAbsent || rawTextRef != null) {
      map['raw_text_ref'] = Variable<String>(rawTextRef);
    }
    map['body_text'] = Variable<String>(bodyText);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['cover_hue'] = Variable<double>(coverHue);
    map['short_count'] = Variable<int>(shortCount);
    return map;
  }

  LibraryBooksCompanion toCompanion(bool nullToAbsent) {
    return LibraryBooksCompanion(
      id: Value(id),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      source: Value(source),
      fileUri: fileUri == null && nullToAbsent
          ? const Value.absent()
          : Value(fileUri),
      rawTextRef: rawTextRef == null && nullToAbsent
          ? const Value.absent()
          : Value(rawTextRef),
      bodyText: Value(bodyText),
      addedAt: Value(addedAt),
      coverHue: Value(coverHue),
      shortCount: Value(shortCount),
    );
  }

  factory LibraryBookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryBookRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      source: serializer.fromJson<String>(json['source']),
      fileUri: serializer.fromJson<String?>(json['fileUri']),
      rawTextRef: serializer.fromJson<String?>(json['rawTextRef']),
      bodyText: serializer.fromJson<String>(json['bodyText']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      coverHue: serializer.fromJson<double>(json['coverHue']),
      shortCount: serializer.fromJson<int>(json['shortCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'source': serializer.toJson<String>(source),
      'fileUri': serializer.toJson<String?>(fileUri),
      'rawTextRef': serializer.toJson<String?>(rawTextRef),
      'bodyText': serializer.toJson<String>(bodyText),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'coverHue': serializer.toJson<double>(coverHue),
      'shortCount': serializer.toJson<int>(shortCount),
    };
  }

  LibraryBookRow copyWith({
    String? id,
    String? title,
    Value<String?> author = const Value.absent(),
    String? source,
    Value<String?> fileUri = const Value.absent(),
    Value<String?> rawTextRef = const Value.absent(),
    String? bodyText,
    DateTime? addedAt,
    double? coverHue,
    int? shortCount,
  }) => LibraryBookRow(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    source: source ?? this.source,
    fileUri: fileUri.present ? fileUri.value : this.fileUri,
    rawTextRef: rawTextRef.present ? rawTextRef.value : this.rawTextRef,
    bodyText: bodyText ?? this.bodyText,
    addedAt: addedAt ?? this.addedAt,
    coverHue: coverHue ?? this.coverHue,
    shortCount: shortCount ?? this.shortCount,
  );
  LibraryBookRow copyWithCompanion(LibraryBooksCompanion data) {
    return LibraryBookRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      source: data.source.present ? data.source.value : this.source,
      fileUri: data.fileUri.present ? data.fileUri.value : this.fileUri,
      rawTextRef: data.rawTextRef.present
          ? data.rawTextRef.value
          : this.rawTextRef,
      bodyText: data.bodyText.present ? data.bodyText.value : this.bodyText,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      coverHue: data.coverHue.present ? data.coverHue.value : this.coverHue,
      shortCount: data.shortCount.present
          ? data.shortCount.value
          : this.shortCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryBookRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('source: $source, ')
          ..write('fileUri: $fileUri, ')
          ..write('rawTextRef: $rawTextRef, ')
          ..write('bodyText: $bodyText, ')
          ..write('addedAt: $addedAt, ')
          ..write('coverHue: $coverHue, ')
          ..write('shortCount: $shortCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    author,
    source,
    fileUri,
    rawTextRef,
    bodyText,
    addedAt,
    coverHue,
    shortCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryBookRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.source == this.source &&
          other.fileUri == this.fileUri &&
          other.rawTextRef == this.rawTextRef &&
          other.bodyText == this.bodyText &&
          other.addedAt == this.addedAt &&
          other.coverHue == this.coverHue &&
          other.shortCount == this.shortCount);
}

class LibraryBooksCompanion extends UpdateCompanion<LibraryBookRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> author;
  final Value<String> source;
  final Value<String?> fileUri;
  final Value<String?> rawTextRef;
  final Value<String> bodyText;
  final Value<DateTime> addedAt;
  final Value<double> coverHue;
  final Value<int> shortCount;
  final Value<int> rowid;
  const LibraryBooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.source = const Value.absent(),
    this.fileUri = const Value.absent(),
    this.rawTextRef = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.coverHue = const Value.absent(),
    this.shortCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryBooksCompanion.insert({
    required String id,
    required String title,
    this.author = const Value.absent(),
    required String source,
    this.fileUri = const Value.absent(),
    this.rawTextRef = const Value.absent(),
    required String bodyText,
    required DateTime addedAt,
    this.coverHue = const Value.absent(),
    this.shortCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       source = Value(source),
       bodyText = Value(bodyText),
       addedAt = Value(addedAt);
  static Insertable<LibraryBookRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? source,
    Expression<String>? fileUri,
    Expression<String>? rawTextRef,
    Expression<String>? bodyText,
    Expression<DateTime>? addedAt,
    Expression<double>? coverHue,
    Expression<int>? shortCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (source != null) 'source': source,
      if (fileUri != null) 'file_uri': fileUri,
      if (rawTextRef != null) 'raw_text_ref': rawTextRef,
      if (bodyText != null) 'body_text': bodyText,
      if (addedAt != null) 'added_at': addedAt,
      if (coverHue != null) 'cover_hue': coverHue,
      if (shortCount != null) 'short_count': shortCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryBooksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? author,
    Value<String>? source,
    Value<String?>? fileUri,
    Value<String?>? rawTextRef,
    Value<String>? bodyText,
    Value<DateTime>? addedAt,
    Value<double>? coverHue,
    Value<int>? shortCount,
    Value<int>? rowid,
  }) {
    return LibraryBooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      source: source ?? this.source,
      fileUri: fileUri ?? this.fileUri,
      rawTextRef: rawTextRef ?? this.rawTextRef,
      bodyText: bodyText ?? this.bodyText,
      addedAt: addedAt ?? this.addedAt,
      coverHue: coverHue ?? this.coverHue,
      shortCount: shortCount ?? this.shortCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fileUri.present) {
      map['file_uri'] = Variable<String>(fileUri.value);
    }
    if (rawTextRef.present) {
      map['raw_text_ref'] = Variable<String>(rawTextRef.value);
    }
    if (bodyText.present) {
      map['body_text'] = Variable<String>(bodyText.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (coverHue.present) {
      map['cover_hue'] = Variable<double>(coverHue.value);
    }
    if (shortCount.present) {
      map['short_count'] = Variable<int>(shortCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryBooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('source: $source, ')
          ..write('fileUri: $fileUri, ')
          ..write('rawTextRef: $rawTextRef, ')
          ..write('bodyText: $bodyText, ')
          ..write('addedAt: $addedAt, ')
          ..write('coverHue: $coverHue, ')
          ..write('shortCount: $shortCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters
    with TableInfo<$ChaptersTable, ChapterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startOffsetMeta = const VerificationMeta(
    'startOffset',
  );
  @override
  late final GeneratedColumn<int> startOffset = GeneratedColumn<int>(
    'start_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endOffsetMeta = const VerificationMeta(
    'endOffset',
  );
  @override
  late final GeneratedColumn<int> endOffset = GeneratedColumn<int>(
    'end_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapterIndex,
    title,
    startOffset,
    endOffset,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_offset')) {
      context.handle(
        _startOffsetMeta,
        startOffset.isAcceptableOrUnknown(
          data['start_offset']!,
          _startOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startOffsetMeta);
    }
    if (data.containsKey('end_offset')) {
      context.handle(
        _endOffsetMeta,
        endOffset.isAcceptableOrUnknown(data['end_offset']!, _endOffsetMeta),
      );
    } else if (isInserting) {
      context.missing(_endOffsetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChapterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_offset'],
      )!,
      endOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_offset'],
      )!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class ChapterRow extends DataClass implements Insertable<ChapterRow> {
  final int id;
  final String bookId;
  final int chapterIndex;
  final String title;
  final int startOffset;
  final int endOffset;
  const ChapterRow({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.title,
    required this.startOffset,
    required this.endOffset,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['title'] = Variable<String>(title);
    map['start_offset'] = Variable<int>(startOffset);
    map['end_offset'] = Variable<int>(endOffset);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      title: Value(title),
      startOffset: Value(startOffset),
      endOffset: Value(endOffset),
    );
  }

  factory ChapterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterRow(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      title: serializer.fromJson<String>(json['title']),
      startOffset: serializer.fromJson<int>(json['startOffset']),
      endOffset: serializer.fromJson<int>(json['endOffset']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'title': serializer.toJson<String>(title),
      'startOffset': serializer.toJson<int>(startOffset),
      'endOffset': serializer.toJson<int>(endOffset),
    };
  }

  ChapterRow copyWith({
    int? id,
    String? bookId,
    int? chapterIndex,
    String? title,
    int? startOffset,
    int? endOffset,
  }) => ChapterRow(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    title: title ?? this.title,
    startOffset: startOffset ?? this.startOffset,
    endOffset: endOffset ?? this.endOffset,
  );
  ChapterRow copyWithCompanion(ChaptersCompanion data) {
    return ChapterRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      title: data.title.present ? data.title.value : this.title,
      startOffset: data.startOffset.present
          ? data.startOffset.value
          : this.startOffset,
      endOffset: data.endOffset.present ? data.endOffset.value : this.endOffset,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('title: $title, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, chapterIndex, title, startOffset, endOffset);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterIndex == this.chapterIndex &&
          other.title == this.title &&
          other.startOffset == this.startOffset &&
          other.endOffset == this.endOffset);
}

class ChaptersCompanion extends UpdateCompanion<ChapterRow> {
  final Value<int> id;
  final Value<String> bookId;
  final Value<int> chapterIndex;
  final Value<String> title;
  final Value<int> startOffset;
  final Value<int> endOffset;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.title = const Value.absent(),
    this.startOffset = const Value.absent(),
    this.endOffset = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required String bookId,
    required int chapterIndex,
    required String title,
    required int startOffset,
    required int endOffset,
  }) : bookId = Value(bookId),
       chapterIndex = Value(chapterIndex),
       title = Value(title),
       startOffset = Value(startOffset),
       endOffset = Value(endOffset);
  static Insertable<ChapterRow> custom({
    Expression<int>? id,
    Expression<String>? bookId,
    Expression<int>? chapterIndex,
    Expression<String>? title,
    Expression<int>? startOffset,
    Expression<int>? endOffset,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (title != null) 'title': title,
      if (startOffset != null) 'start_offset': startOffset,
      if (endOffset != null) 'end_offset': endOffset,
    });
  }

  ChaptersCompanion copyWith({
    Value<int>? id,
    Value<String>? bookId,
    Value<int>? chapterIndex,
    Value<String>? title,
    Value<int>? startOffset,
    Value<int>? endOffset,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      title: title ?? this.title,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startOffset.present) {
      map['start_offset'] = Variable<int>(startOffset.value);
    }
    if (endOffset.present) {
      map['end_offset'] = Variable<int>(endOffset.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('title: $title, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset')
          ..write(')'))
        .toString();
  }
}

class $ShortsTable extends Shorts with TableInfo<$ShortsTable, ShortRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShortsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortIndexMeta = const VerificationMeta(
    'shortIndex',
  );
  @override
  late final GeneratedColumn<int> shortIndex = GeneratedColumn<int>(
    'short_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalMeta = const VerificationMeta(
    'original',
  );
  @override
  late final GeneratedColumn<String> original = GeneratedColumn<String>(
    'original',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _condenseMeta = const VerificationMeta(
    'condense',
  );
  @override
  late final GeneratedColumn<String> condense = GeneratedColumn<String>(
    'condense',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quotesMeta = const VerificationMeta('quotes');
  @override
  late final GeneratedColumn<String> quotes = GeneratedColumn<String>(
    'quotes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterTitleMeta = const VerificationMeta(
    'chapterTitle',
  );
  @override
  late final GeneratedColumn<String> chapterTitle = GeneratedColumn<String>(
    'chapter_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tldrSourceMeta = const VerificationMeta(
    'tldrSource',
  );
  @override
  late final GeneratedColumn<String> tldrSource = GeneratedColumn<String>(
    'tldr_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('extractive'),
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    shortIndex,
    original,
    condense,
    summary,
    quotes,
    wordCount,
    chapterIndex,
    chapterTitle,
    tldrSource,
    contentHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shorts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShortRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('short_index')) {
      context.handle(
        _shortIndexMeta,
        shortIndex.isAcceptableOrUnknown(data['short_index']!, _shortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_shortIndexMeta);
    }
    if (data.containsKey('original')) {
      context.handle(
        _originalMeta,
        original.isAcceptableOrUnknown(data['original']!, _originalMeta),
      );
    } else if (isInserting) {
      context.missing(_originalMeta);
    }
    if (data.containsKey('condense')) {
      context.handle(
        _condenseMeta,
        condense.isAcceptableOrUnknown(data['condense']!, _condenseMeta),
      );
    } else if (isInserting) {
      context.missing(_condenseMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('quotes')) {
      context.handle(
        _quotesMeta,
        quotes.isAcceptableOrUnknown(data['quotes']!, _quotesMeta),
      );
    } else if (isInserting) {
      context.missing(_quotesMeta);
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    } else if (isInserting) {
      context.missing(_wordCountMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('chapter_title')) {
      context.handle(
        _chapterTitleMeta,
        chapterTitle.isAcceptableOrUnknown(
          data['chapter_title']!,
          _chapterTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterTitleMeta);
    }
    if (data.containsKey('tldr_source')) {
      context.handle(
        _tldrSourceMeta,
        tldrSource.isAcceptableOrUnknown(data['tldr_source']!, _tldrSourceMeta),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShortRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShortRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      shortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}short_index'],
      )!,
      original: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original'],
      )!,
      condense: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condense'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      quotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quotes'],
      )!,
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      chapterTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_title'],
      )!,
      tldrSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tldr_source'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      ),
    );
  }

  @override
  $ShortsTable createAlias(String alias) {
    return $ShortsTable(attachedDatabase, alias);
  }
}

class ShortRow extends DataClass implements Insertable<ShortRow> {
  final String id;
  final String bookId;
  final int shortIndex;
  final String original;
  final String condense;
  final String summary;
  final String quotes;
  final int wordCount;
  final int chapterIndex;
  final String chapterTitle;
  final String tldrSource;
  final String? contentHash;
  const ShortRow({
    required this.id,
    required this.bookId,
    required this.shortIndex,
    required this.original,
    required this.condense,
    required this.summary,
    required this.quotes,
    required this.wordCount,
    required this.chapterIndex,
    required this.chapterTitle,
    required this.tldrSource,
    this.contentHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['short_index'] = Variable<int>(shortIndex);
    map['original'] = Variable<String>(original);
    map['condense'] = Variable<String>(condense);
    map['summary'] = Variable<String>(summary);
    map['quotes'] = Variable<String>(quotes);
    map['word_count'] = Variable<int>(wordCount);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['chapter_title'] = Variable<String>(chapterTitle);
    map['tldr_source'] = Variable<String>(tldrSource);
    if (!nullToAbsent || contentHash != null) {
      map['content_hash'] = Variable<String>(contentHash);
    }
    return map;
  }

  ShortsCompanion toCompanion(bool nullToAbsent) {
    return ShortsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      shortIndex: Value(shortIndex),
      original: Value(original),
      condense: Value(condense),
      summary: Value(summary),
      quotes: Value(quotes),
      wordCount: Value(wordCount),
      chapterIndex: Value(chapterIndex),
      chapterTitle: Value(chapterTitle),
      tldrSource: Value(tldrSource),
      contentHash: contentHash == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHash),
    );
  }

  factory ShortRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShortRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      shortIndex: serializer.fromJson<int>(json['shortIndex']),
      original: serializer.fromJson<String>(json['original']),
      condense: serializer.fromJson<String>(json['condense']),
      summary: serializer.fromJson<String>(json['summary']),
      quotes: serializer.fromJson<String>(json['quotes']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      chapterTitle: serializer.fromJson<String>(json['chapterTitle']),
      tldrSource: serializer.fromJson<String>(json['tldrSource']),
      contentHash: serializer.fromJson<String?>(json['contentHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'shortIndex': serializer.toJson<int>(shortIndex),
      'original': serializer.toJson<String>(original),
      'condense': serializer.toJson<String>(condense),
      'summary': serializer.toJson<String>(summary),
      'quotes': serializer.toJson<String>(quotes),
      'wordCount': serializer.toJson<int>(wordCount),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'chapterTitle': serializer.toJson<String>(chapterTitle),
      'tldrSource': serializer.toJson<String>(tldrSource),
      'contentHash': serializer.toJson<String?>(contentHash),
    };
  }

  ShortRow copyWith({
    String? id,
    String? bookId,
    int? shortIndex,
    String? original,
    String? condense,
    String? summary,
    String? quotes,
    int? wordCount,
    int? chapterIndex,
    String? chapterTitle,
    String? tldrSource,
    Value<String?> contentHash = const Value.absent(),
  }) => ShortRow(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    shortIndex: shortIndex ?? this.shortIndex,
    original: original ?? this.original,
    condense: condense ?? this.condense,
    summary: summary ?? this.summary,
    quotes: quotes ?? this.quotes,
    wordCount: wordCount ?? this.wordCount,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    chapterTitle: chapterTitle ?? this.chapterTitle,
    tldrSource: tldrSource ?? this.tldrSource,
    contentHash: contentHash.present ? contentHash.value : this.contentHash,
  );
  ShortRow copyWithCompanion(ShortsCompanion data) {
    return ShortRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      shortIndex: data.shortIndex.present
          ? data.shortIndex.value
          : this.shortIndex,
      original: data.original.present ? data.original.value : this.original,
      condense: data.condense.present ? data.condense.value : this.condense,
      summary: data.summary.present ? data.summary.value : this.summary,
      quotes: data.quotes.present ? data.quotes.value : this.quotes,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      chapterTitle: data.chapterTitle.present
          ? data.chapterTitle.value
          : this.chapterTitle,
      tldrSource: data.tldrSource.present
          ? data.tldrSource.value
          : this.tldrSource,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShortRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('shortIndex: $shortIndex, ')
          ..write('original: $original, ')
          ..write('condense: $condense, ')
          ..write('summary: $summary, ')
          ..write('quotes: $quotes, ')
          ..write('wordCount: $wordCount, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('tldrSource: $tldrSource, ')
          ..write('contentHash: $contentHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    shortIndex,
    original,
    condense,
    summary,
    quotes,
    wordCount,
    chapterIndex,
    chapterTitle,
    tldrSource,
    contentHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShortRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.shortIndex == this.shortIndex &&
          other.original == this.original &&
          other.condense == this.condense &&
          other.summary == this.summary &&
          other.quotes == this.quotes &&
          other.wordCount == this.wordCount &&
          other.chapterIndex == this.chapterIndex &&
          other.chapterTitle == this.chapterTitle &&
          other.tldrSource == this.tldrSource &&
          other.contentHash == this.contentHash);
}

class ShortsCompanion extends UpdateCompanion<ShortRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> shortIndex;
  final Value<String> original;
  final Value<String> condense;
  final Value<String> summary;
  final Value<String> quotes;
  final Value<int> wordCount;
  final Value<int> chapterIndex;
  final Value<String> chapterTitle;
  final Value<String> tldrSource;
  final Value<String?> contentHash;
  final Value<int> rowid;
  const ShortsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.shortIndex = const Value.absent(),
    this.original = const Value.absent(),
    this.condense = const Value.absent(),
    this.summary = const Value.absent(),
    this.quotes = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.chapterTitle = const Value.absent(),
    this.tldrSource = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShortsCompanion.insert({
    required String id,
    required String bookId,
    required int shortIndex,
    required String original,
    required String condense,
    required String summary,
    required String quotes,
    required int wordCount,
    required int chapterIndex,
    required String chapterTitle,
    this.tldrSource = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       shortIndex = Value(shortIndex),
       original = Value(original),
       condense = Value(condense),
       summary = Value(summary),
       quotes = Value(quotes),
       wordCount = Value(wordCount),
       chapterIndex = Value(chapterIndex),
       chapterTitle = Value(chapterTitle);
  static Insertable<ShortRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? shortIndex,
    Expression<String>? original,
    Expression<String>? condense,
    Expression<String>? summary,
    Expression<String>? quotes,
    Expression<int>? wordCount,
    Expression<int>? chapterIndex,
    Expression<String>? chapterTitle,
    Expression<String>? tldrSource,
    Expression<String>? contentHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (shortIndex != null) 'short_index': shortIndex,
      if (original != null) 'original': original,
      if (condense != null) 'condense': condense,
      if (summary != null) 'summary': summary,
      if (quotes != null) 'quotes': quotes,
      if (wordCount != null) 'word_count': wordCount,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (chapterTitle != null) 'chapter_title': chapterTitle,
      if (tldrSource != null) 'tldr_source': tldrSource,
      if (contentHash != null) 'content_hash': contentHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShortsCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<int>? shortIndex,
    Value<String>? original,
    Value<String>? condense,
    Value<String>? summary,
    Value<String>? quotes,
    Value<int>? wordCount,
    Value<int>? chapterIndex,
    Value<String>? chapterTitle,
    Value<String>? tldrSource,
    Value<String?>? contentHash,
    Value<int>? rowid,
  }) {
    return ShortsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      shortIndex: shortIndex ?? this.shortIndex,
      original: original ?? this.original,
      condense: condense ?? this.condense,
      summary: summary ?? this.summary,
      quotes: quotes ?? this.quotes,
      wordCount: wordCount ?? this.wordCount,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      tldrSource: tldrSource ?? this.tldrSource,
      contentHash: contentHash ?? this.contentHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (shortIndex.present) {
      map['short_index'] = Variable<int>(shortIndex.value);
    }
    if (original.present) {
      map['original'] = Variable<String>(original.value);
    }
    if (condense.present) {
      map['condense'] = Variable<String>(condense.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (quotes.present) {
      map['quotes'] = Variable<String>(quotes.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (chapterTitle.present) {
      map['chapter_title'] = Variable<String>(chapterTitle.value);
    }
    if (tldrSource.present) {
      map['tldr_source'] = Variable<String>(tldrSource.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShortsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('shortIndex: $shortIndex, ')
          ..write('original: $original, ')
          ..write('condense: $condense, ')
          ..write('summary: $summary, ')
          ..write('quotes: $quotes, ')
          ..write('wordCount: $wordCount, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('tldrSource: $tldrSource, ')
          ..write('contentHash: $contentHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgressRowsTable extends ProgressRows
    with TableInfo<$ProgressRowsTable, ProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortIdMeta = const VerificationMeta(
    'shortId',
  );
  @override
  late final GeneratedColumn<String> shortId = GeneratedColumn<String>(
    'short_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shortIndexMeta = const VerificationMeta(
    'shortIndex',
  );
  @override
  late final GeneratedColumn<int> shortIndex = GeneratedColumn<int>(
    'short_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    shortId,
    shortIndex,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('short_id')) {
      context.handle(
        _shortIdMeta,
        shortId.isAcceptableOrUnknown(data['short_id']!, _shortIdMeta),
      );
    }
    if (data.containsKey('short_index')) {
      context.handle(
        _shortIndexMeta,
        shortIndex.isAcceptableOrUnknown(data['short_index']!, _shortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_shortIndexMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  ProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressRow(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      shortId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_id'],
      ),
      shortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}short_index'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProgressRowsTable createAlias(String alias) {
    return $ProgressRowsTable(attachedDatabase, alias);
  }
}

class ProgressRow extends DataClass implements Insertable<ProgressRow> {
  final String bookId;
  final String? shortId;
  final int shortIndex;
  final DateTime updatedAt;
  const ProgressRow({
    required this.bookId,
    this.shortId,
    required this.shortIndex,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    if (!nullToAbsent || shortId != null) {
      map['short_id'] = Variable<String>(shortId);
    }
    map['short_index'] = Variable<int>(shortIndex);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProgressRowsCompanion toCompanion(bool nullToAbsent) {
    return ProgressRowsCompanion(
      bookId: Value(bookId),
      shortId: shortId == null && nullToAbsent
          ? const Value.absent()
          : Value(shortId),
      shortIndex: Value(shortIndex),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressRow(
      bookId: serializer.fromJson<String>(json['bookId']),
      shortId: serializer.fromJson<String?>(json['shortId']),
      shortIndex: serializer.fromJson<int>(json['shortIndex']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'shortId': serializer.toJson<String?>(shortId),
      'shortIndex': serializer.toJson<int>(shortIndex),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProgressRow copyWith({
    String? bookId,
    Value<String?> shortId = const Value.absent(),
    int? shortIndex,
    DateTime? updatedAt,
  }) => ProgressRow(
    bookId: bookId ?? this.bookId,
    shortId: shortId.present ? shortId.value : this.shortId,
    shortIndex: shortIndex ?? this.shortIndex,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProgressRow copyWithCompanion(ProgressRowsCompanion data) {
    return ProgressRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      shortId: data.shortId.present ? data.shortId.value : this.shortId,
      shortIndex: data.shortIndex.present
          ? data.shortIndex.value
          : this.shortIndex,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressRow(')
          ..write('bookId: $bookId, ')
          ..write('shortId: $shortId, ')
          ..write('shortIndex: $shortIndex, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, shortId, shortIndex, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressRow &&
          other.bookId == this.bookId &&
          other.shortId == this.shortId &&
          other.shortIndex == this.shortIndex &&
          other.updatedAt == this.updatedAt);
}

class ProgressRowsCompanion extends UpdateCompanion<ProgressRow> {
  final Value<String> bookId;
  final Value<String?> shortId;
  final Value<int> shortIndex;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProgressRowsCompanion({
    this.bookId = const Value.absent(),
    this.shortId = const Value.absent(),
    this.shortIndex = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgressRowsCompanion.insert({
    required String bookId,
    this.shortId = const Value.absent(),
    required int shortIndex,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       shortIndex = Value(shortIndex),
       updatedAt = Value(updatedAt);
  static Insertable<ProgressRow> custom({
    Expression<String>? bookId,
    Expression<String>? shortId,
    Expression<int>? shortIndex,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (shortId != null) 'short_id': shortId,
      if (shortIndex != null) 'short_index': shortIndex,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgressRowsCompanion copyWith({
    Value<String>? bookId,
    Value<String?>? shortId,
    Value<int>? shortIndex,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProgressRowsCompanion(
      bookId: bookId ?? this.bookId,
      shortId: shortId ?? this.shortId,
      shortIndex: shortIndex ?? this.shortIndex,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (shortId.present) {
      map['short_id'] = Variable<String>(shortId.value);
    }
    if (shortIndex.present) {
      map['short_index'] = Variable<int>(shortIndex.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressRowsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('shortId: $shortId, ')
          ..write('shortIndex: $shortIndex, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaKvTable extends MetaKv with TableInfo<$MetaKvTable, MetaKvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaKvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _metaKeyMeta = const VerificationMeta(
    'metaKey',
  );
  @override
  late final GeneratedColumn<String> metaKey = GeneratedColumn<String>(
    'meta_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaValueMeta = const VerificationMeta(
    'metaValue',
  );
  @override
  late final GeneratedColumn<String> metaValue = GeneratedColumn<String>(
    'meta_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [metaKey, metaValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta_kv';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaKvRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meta_key')) {
      context.handle(
        _metaKeyMeta,
        metaKey.isAcceptableOrUnknown(data['meta_key']!, _metaKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_metaKeyMeta);
    }
    if (data.containsKey('meta_value')) {
      context.handle(
        _metaValueMeta,
        metaValue.isAcceptableOrUnknown(data['meta_value']!, _metaValueMeta),
      );
    } else if (isInserting) {
      context.missing(_metaValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metaKey};
  @override
  MetaKvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaKvRow(
      metaKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_key'],
      )!,
      metaValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_value'],
      )!,
    );
  }

  @override
  $MetaKvTable createAlias(String alias) {
    return $MetaKvTable(attachedDatabase, alias);
  }
}

class MetaKvRow extends DataClass implements Insertable<MetaKvRow> {
  final String metaKey;
  final String metaValue;
  const MetaKvRow({required this.metaKey, required this.metaValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meta_key'] = Variable<String>(metaKey);
    map['meta_value'] = Variable<String>(metaValue);
    return map;
  }

  MetaKvCompanion toCompanion(bool nullToAbsent) {
    return MetaKvCompanion(
      metaKey: Value(metaKey),
      metaValue: Value(metaValue),
    );
  }

  factory MetaKvRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaKvRow(
      metaKey: serializer.fromJson<String>(json['metaKey']),
      metaValue: serializer.fromJson<String>(json['metaValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'metaKey': serializer.toJson<String>(metaKey),
      'metaValue': serializer.toJson<String>(metaValue),
    };
  }

  MetaKvRow copyWith({String? metaKey, String? metaValue}) => MetaKvRow(
    metaKey: metaKey ?? this.metaKey,
    metaValue: metaValue ?? this.metaValue,
  );
  MetaKvRow copyWithCompanion(MetaKvCompanion data) {
    return MetaKvRow(
      metaKey: data.metaKey.present ? data.metaKey.value : this.metaKey,
      metaValue: data.metaValue.present ? data.metaValue.value : this.metaValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaKvRow(')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(metaKey, metaValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaKvRow &&
          other.metaKey == this.metaKey &&
          other.metaValue == this.metaValue);
}

class MetaKvCompanion extends UpdateCompanion<MetaKvRow> {
  final Value<String> metaKey;
  final Value<String> metaValue;
  final Value<int> rowid;
  const MetaKvCompanion({
    this.metaKey = const Value.absent(),
    this.metaValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaKvCompanion.insert({
    required String metaKey,
    required String metaValue,
    this.rowid = const Value.absent(),
  }) : metaKey = Value(metaKey),
       metaValue = Value(metaValue);
  static Insertable<MetaKvRow> custom({
    Expression<String>? metaKey,
    Expression<String>? metaValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (metaKey != null) 'meta_key': metaKey,
      if (metaValue != null) 'meta_value': metaValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaKvCompanion copyWith({
    Value<String>? metaKey,
    Value<String>? metaValue,
    Value<int>? rowid,
  }) {
    return MetaKvCompanion(
      metaKey: metaKey ?? this.metaKey,
      metaValue: metaValue ?? this.metaValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (metaKey.present) {
      map['meta_key'] = Variable<String>(metaKey.value);
    }
    if (metaValue.present) {
      map['meta_value'] = Variable<String>(metaValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaKvCompanion(')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FlickDatabase extends GeneratedDatabase {
  _$FlickDatabase(QueryExecutor e) : super(e);
  $FlickDatabaseManager get managers => $FlickDatabaseManager(this);
  late final $LibraryBooksTable libraryBooks = $LibraryBooksTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $ShortsTable shorts = $ShortsTable(this);
  late final $ProgressRowsTable progressRows = $ProgressRowsTable(this);
  late final $MetaKvTable metaKv = $MetaKvTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryBooks,
    chapters,
    shorts,
    progressRows,
    metaKv,
  ];
}

typedef $$LibraryBooksTableCreateCompanionBuilder =
    LibraryBooksCompanion Function({
      required String id,
      required String title,
      Value<String?> author,
      required String source,
      Value<String?> fileUri,
      Value<String?> rawTextRef,
      required String bodyText,
      required DateTime addedAt,
      Value<double> coverHue,
      Value<int> shortCount,
      Value<int> rowid,
    });
typedef $$LibraryBooksTableUpdateCompanionBuilder =
    LibraryBooksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> author,
      Value<String> source,
      Value<String?> fileUri,
      Value<String?> rawTextRef,
      Value<String> bodyText,
      Value<DateTime> addedAt,
      Value<double> coverHue,
      Value<int> shortCount,
      Value<int> rowid,
    });

class $$LibraryBooksTableFilterComposer
    extends Composer<_$FlickDatabase, $LibraryBooksTable> {
  $$LibraryBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileUri => $composableBuilder(
    column: $table.fileUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawTextRef => $composableBuilder(
    column: $table.rawTextRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyText => $composableBuilder(
    column: $table.bodyText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coverHue => $composableBuilder(
    column: $table.coverHue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shortCount => $composableBuilder(
    column: $table.shortCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryBooksTableOrderingComposer
    extends Composer<_$FlickDatabase, $LibraryBooksTable> {
  $$LibraryBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileUri => $composableBuilder(
    column: $table.fileUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawTextRef => $composableBuilder(
    column: $table.rawTextRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyText => $composableBuilder(
    column: $table.bodyText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coverHue => $composableBuilder(
    column: $table.coverHue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shortCount => $composableBuilder(
    column: $table.shortCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryBooksTableAnnotationComposer
    extends Composer<_$FlickDatabase, $LibraryBooksTable> {
  $$LibraryBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get fileUri =>
      $composableBuilder(column: $table.fileUri, builder: (column) => column);

  GeneratedColumn<String> get rawTextRef => $composableBuilder(
    column: $table.rawTextRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyText =>
      $composableBuilder(column: $table.bodyText, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<double> get coverHue =>
      $composableBuilder(column: $table.coverHue, builder: (column) => column);

  GeneratedColumn<int> get shortCount => $composableBuilder(
    column: $table.shortCount,
    builder: (column) => column,
  );
}

class $$LibraryBooksTableTableManager
    extends
        RootTableManager<
          _$FlickDatabase,
          $LibraryBooksTable,
          LibraryBookRow,
          $$LibraryBooksTableFilterComposer,
          $$LibraryBooksTableOrderingComposer,
          $$LibraryBooksTableAnnotationComposer,
          $$LibraryBooksTableCreateCompanionBuilder,
          $$LibraryBooksTableUpdateCompanionBuilder,
          (
            LibraryBookRow,
            BaseReferences<_$FlickDatabase, $LibraryBooksTable, LibraryBookRow>,
          ),
          LibraryBookRow,
          PrefetchHooks Function()
        > {
  $$LibraryBooksTableTableManager(_$FlickDatabase db, $LibraryBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> fileUri = const Value.absent(),
                Value<String?> rawTextRef = const Value.absent(),
                Value<String> bodyText = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<double> coverHue = const Value.absent(),
                Value<int> shortCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryBooksCompanion(
                id: id,
                title: title,
                author: author,
                source: source,
                fileUri: fileUri,
                rawTextRef: rawTextRef,
                bodyText: bodyText,
                addedAt: addedAt,
                coverHue: coverHue,
                shortCount: shortCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> author = const Value.absent(),
                required String source,
                Value<String?> fileUri = const Value.absent(),
                Value<String?> rawTextRef = const Value.absent(),
                required String bodyText,
                required DateTime addedAt,
                Value<double> coverHue = const Value.absent(),
                Value<int> shortCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryBooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                source: source,
                fileUri: fileUri,
                rawTextRef: rawTextRef,
                bodyText: bodyText,
                addedAt: addedAt,
                coverHue: coverHue,
                shortCount: shortCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LibraryBooksTable, LibraryBookRow>(table),
                  BaseReferences<
                    _$FlickDatabase,
                    $LibraryBooksTable,
                    LibraryBookRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$FlickDatabase,
      $LibraryBooksTable,
      LibraryBookRow,
      $$LibraryBooksTableFilterComposer,
      $$LibraryBooksTableOrderingComposer,
      $$LibraryBooksTableAnnotationComposer,
      $$LibraryBooksTableCreateCompanionBuilder,
      $$LibraryBooksTableUpdateCompanionBuilder,
      (
        LibraryBookRow,
        BaseReferences<_$FlickDatabase, $LibraryBooksTable, LibraryBookRow>,
      ),
      LibraryBookRow,
      PrefetchHooks Function()
    >;
typedef $$ChaptersTableCreateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      required String bookId,
      required int chapterIndex,
      required String title,
      required int startOffset,
      required int endOffset,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      Value<String> bookId,
      Value<int> chapterIndex,
      Value<String> title,
      Value<int> startOffset,
      Value<int> endOffset,
    });

class $$ChaptersTableFilterComposer
    extends Composer<_$FlickDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$FlickDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endOffset => $composableBuilder(
    column: $table.endOffset,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$FlickDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get startOffset => $composableBuilder(
    column: $table.startOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endOffset =>
      $composableBuilder(column: $table.endOffset, builder: (column) => column);
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$FlickDatabase,
          $ChaptersTable,
          ChapterRow,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (
            ChapterRow,
            BaseReferences<_$FlickDatabase, $ChaptersTable, ChapterRow>,
          ),
          ChapterRow,
          PrefetchHooks Function()
        > {
  $$ChaptersTableTableManager(_$FlickDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> startOffset = const Value.absent(),
                Value<int> endOffset = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                bookId: bookId,
                chapterIndex: chapterIndex,
                title: title,
                startOffset: startOffset,
                endOffset: endOffset,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bookId,
                required int chapterIndex,
                required String title,
                required int startOffset,
                required int endOffset,
              }) => ChaptersCompanion.insert(
                id: id,
                bookId: bookId,
                chapterIndex: chapterIndex,
                title: title,
                startOffset: startOffset,
                endOffset: endOffset,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChaptersTable, ChapterRow>(table),
                  BaseReferences<_$FlickDatabase, $ChaptersTable, ChapterRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$FlickDatabase,
      $ChaptersTable,
      ChapterRow,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (ChapterRow, BaseReferences<_$FlickDatabase, $ChaptersTable, ChapterRow>),
      ChapterRow,
      PrefetchHooks Function()
    >;
typedef $$ShortsTableCreateCompanionBuilder =
    ShortsCompanion Function({
      required String id,
      required String bookId,
      required int shortIndex,
      required String original,
      required String condense,
      required String summary,
      required String quotes,
      required int wordCount,
      required int chapterIndex,
      required String chapterTitle,
      Value<String> tldrSource,
      Value<String?> contentHash,
      Value<int> rowid,
    });
typedef $$ShortsTableUpdateCompanionBuilder =
    ShortsCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<int> shortIndex,
      Value<String> original,
      Value<String> condense,
      Value<String> summary,
      Value<String> quotes,
      Value<int> wordCount,
      Value<int> chapterIndex,
      Value<String> chapterTitle,
      Value<String> tldrSource,
      Value<String?> contentHash,
      Value<int> rowid,
    });

class $$ShortsTableFilterComposer
    extends Composer<_$FlickDatabase, $ShortsTable> {
  $$ShortsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shortIndex => $composableBuilder(
    column: $table.shortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get original => $composableBuilder(
    column: $table.original,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condense => $composableBuilder(
    column: $table.condense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quotes => $composableBuilder(
    column: $table.quotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tldrSource => $composableBuilder(
    column: $table.tldrSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShortsTableOrderingComposer
    extends Composer<_$FlickDatabase, $ShortsTable> {
  $$ShortsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shortIndex => $composableBuilder(
    column: $table.shortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get original => $composableBuilder(
    column: $table.original,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condense => $composableBuilder(
    column: $table.condense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quotes => $composableBuilder(
    column: $table.quotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tldrSource => $composableBuilder(
    column: $table.tldrSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShortsTableAnnotationComposer
    extends Composer<_$FlickDatabase, $ShortsTable> {
  $$ShortsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get shortIndex => $composableBuilder(
    column: $table.shortIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get original =>
      $composableBuilder(column: $table.original, builder: (column) => column);

  GeneratedColumn<String> get condense =>
      $composableBuilder(column: $table.condense, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get quotes =>
      $composableBuilder(column: $table.quotes, builder: (column) => column);

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tldrSource => $composableBuilder(
    column: $table.tldrSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );
}

class $$ShortsTableTableManager
    extends
        RootTableManager<
          _$FlickDatabase,
          $ShortsTable,
          ShortRow,
          $$ShortsTableFilterComposer,
          $$ShortsTableOrderingComposer,
          $$ShortsTableAnnotationComposer,
          $$ShortsTableCreateCompanionBuilder,
          $$ShortsTableUpdateCompanionBuilder,
          (ShortRow, BaseReferences<_$FlickDatabase, $ShortsTable, ShortRow>),
          ShortRow,
          PrefetchHooks Function()
        > {
  $$ShortsTableTableManager(_$FlickDatabase db, $ShortsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShortsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShortsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShortsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> shortIndex = const Value.absent(),
                Value<String> original = const Value.absent(),
                Value<String> condense = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> quotes = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<String> chapterTitle = const Value.absent(),
                Value<String> tldrSource = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShortsCompanion(
                id: id,
                bookId: bookId,
                shortIndex: shortIndex,
                original: original,
                condense: condense,
                summary: summary,
                quotes: quotes,
                wordCount: wordCount,
                chapterIndex: chapterIndex,
                chapterTitle: chapterTitle,
                tldrSource: tldrSource,
                contentHash: contentHash,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required int shortIndex,
                required String original,
                required String condense,
                required String summary,
                required String quotes,
                required int wordCount,
                required int chapterIndex,
                required String chapterTitle,
                Value<String> tldrSource = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShortsCompanion.insert(
                id: id,
                bookId: bookId,
                shortIndex: shortIndex,
                original: original,
                condense: condense,
                summary: summary,
                quotes: quotes,
                wordCount: wordCount,
                chapterIndex: chapterIndex,
                chapterTitle: chapterTitle,
                tldrSource: tldrSource,
                contentHash: contentHash,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShortsTable, ShortRow>(table),
                  BaseReferences<_$FlickDatabase, $ShortsTable, ShortRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShortsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlickDatabase,
      $ShortsTable,
      ShortRow,
      $$ShortsTableFilterComposer,
      $$ShortsTableOrderingComposer,
      $$ShortsTableAnnotationComposer,
      $$ShortsTableCreateCompanionBuilder,
      $$ShortsTableUpdateCompanionBuilder,
      (ShortRow, BaseReferences<_$FlickDatabase, $ShortsTable, ShortRow>),
      ShortRow,
      PrefetchHooks Function()
    >;
typedef $$ProgressRowsTableCreateCompanionBuilder =
    ProgressRowsCompanion Function({
      required String bookId,
      Value<String?> shortId,
      required int shortIndex,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProgressRowsTableUpdateCompanionBuilder =
    ProgressRowsCompanion Function({
      Value<String> bookId,
      Value<String?> shortId,
      Value<int> shortIndex,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProgressRowsTableFilterComposer
    extends Composer<_$FlickDatabase, $ProgressRowsTable> {
  $$ProgressRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortId => $composableBuilder(
    column: $table.shortId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shortIndex => $composableBuilder(
    column: $table.shortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressRowsTableOrderingComposer
    extends Composer<_$FlickDatabase, $ProgressRowsTable> {
  $$ProgressRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortId => $composableBuilder(
    column: $table.shortId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shortIndex => $composableBuilder(
    column: $table.shortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressRowsTableAnnotationComposer
    extends Composer<_$FlickDatabase, $ProgressRowsTable> {
  $$ProgressRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get shortId =>
      $composableBuilder(column: $table.shortId, builder: (column) => column);

  GeneratedColumn<int> get shortIndex => $composableBuilder(
    column: $table.shortIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProgressRowsTableTableManager
    extends
        RootTableManager<
          _$FlickDatabase,
          $ProgressRowsTable,
          ProgressRow,
          $$ProgressRowsTableFilterComposer,
          $$ProgressRowsTableOrderingComposer,
          $$ProgressRowsTableAnnotationComposer,
          $$ProgressRowsTableCreateCompanionBuilder,
          $$ProgressRowsTableUpdateCompanionBuilder,
          (
            ProgressRow,
            BaseReferences<_$FlickDatabase, $ProgressRowsTable, ProgressRow>,
          ),
          ProgressRow,
          PrefetchHooks Function()
        > {
  $$ProgressRowsTableTableManager(_$FlickDatabase db, $ProgressRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String?> shortId = const Value.absent(),
                Value<int> shortIndex = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgressRowsCompanion(
                bookId: bookId,
                shortId: shortId,
                shortIndex: shortIndex,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                Value<String?> shortId = const Value.absent(),
                required int shortIndex,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProgressRowsCompanion.insert(
                bookId: bookId,
                shortId: shortId,
                shortIndex: shortIndex,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProgressRowsTable, ProgressRow>(table),
                  BaseReferences<
                    _$FlickDatabase,
                    $ProgressRowsTable,
                    ProgressRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$FlickDatabase,
      $ProgressRowsTable,
      ProgressRow,
      $$ProgressRowsTableFilterComposer,
      $$ProgressRowsTableOrderingComposer,
      $$ProgressRowsTableAnnotationComposer,
      $$ProgressRowsTableCreateCompanionBuilder,
      $$ProgressRowsTableUpdateCompanionBuilder,
      (
        ProgressRow,
        BaseReferences<_$FlickDatabase, $ProgressRowsTable, ProgressRow>,
      ),
      ProgressRow,
      PrefetchHooks Function()
    >;
typedef $$MetaKvTableCreateCompanionBuilder =
    MetaKvCompanion Function({
      required String metaKey,
      required String metaValue,
      Value<int> rowid,
    });
typedef $$MetaKvTableUpdateCompanionBuilder =
    MetaKvCompanion Function({
      Value<String> metaKey,
      Value<String> metaValue,
      Value<int> rowid,
    });

class $$MetaKvTableFilterComposer
    extends Composer<_$FlickDatabase, $MetaKvTable> {
  $$MetaKvTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metaValue => $composableBuilder(
    column: $table.metaValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaKvTableOrderingComposer
    extends Composer<_$FlickDatabase, $MetaKvTable> {
  $$MetaKvTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metaValue => $composableBuilder(
    column: $table.metaValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaKvTableAnnotationComposer
    extends Composer<_$FlickDatabase, $MetaKvTable> {
  $$MetaKvTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get metaKey =>
      $composableBuilder(column: $table.metaKey, builder: (column) => column);

  GeneratedColumn<String> get metaValue =>
      $composableBuilder(column: $table.metaValue, builder: (column) => column);
}

class $$MetaKvTableTableManager
    extends
        RootTableManager<
          _$FlickDatabase,
          $MetaKvTable,
          MetaKvRow,
          $$MetaKvTableFilterComposer,
          $$MetaKvTableOrderingComposer,
          $$MetaKvTableAnnotationComposer,
          $$MetaKvTableCreateCompanionBuilder,
          $$MetaKvTableUpdateCompanionBuilder,
          (MetaKvRow, BaseReferences<_$FlickDatabase, $MetaKvTable, MetaKvRow>),
          MetaKvRow,
          PrefetchHooks Function()
        > {
  $$MetaKvTableTableManager(_$FlickDatabase db, $MetaKvTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaKvTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaKvTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaKvTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> metaKey = const Value.absent(),
                Value<String> metaValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaKvCompanion(
                metaKey: metaKey,
                metaValue: metaValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String metaKey,
                required String metaValue,
                Value<int> rowid = const Value.absent(),
              }) => MetaKvCompanion.insert(
                metaKey: metaKey,
                metaValue: metaValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaKvTable, MetaKvRow>(table),
                  BaseReferences<_$FlickDatabase, $MetaKvTable, MetaKvRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaKvTableProcessedTableManager =
    ProcessedTableManager<
      _$FlickDatabase,
      $MetaKvTable,
      MetaKvRow,
      $$MetaKvTableFilterComposer,
      $$MetaKvTableOrderingComposer,
      $$MetaKvTableAnnotationComposer,
      $$MetaKvTableCreateCompanionBuilder,
      $$MetaKvTableUpdateCompanionBuilder,
      (MetaKvRow, BaseReferences<_$FlickDatabase, $MetaKvTable, MetaKvRow>),
      MetaKvRow,
      PrefetchHooks Function()
    >;

class $FlickDatabaseManager {
  final _$FlickDatabase _db;
  $FlickDatabaseManager(this._db);
  $$LibraryBooksTableTableManager get libraryBooks =>
      $$LibraryBooksTableTableManager(_db, _db.libraryBooks);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$ShortsTableTableManager get shorts =>
      $$ShortsTableTableManager(_db, _db.shorts);
  $$ProgressRowsTableTableManager get progressRows =>
      $$ProgressRowsTableTableManager(_db, _db.progressRows);
  $$MetaKvTableTableManager get metaKv =>
      $$MetaKvTableTableManager(_db, _db.metaKv);
}
