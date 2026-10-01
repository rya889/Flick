import '../models/models.dart';
import '../models/reader_sync.dart';
import 'book_pages.dart';

class ShortPlace {
  const ShortPlace({
    required this.shortIndex,
    required this.chapterIndex,
    required this.charOffset,
  });

  final int shortIndex;
  final int chapterIndex;
  final int charOffset;
}

String _squeeze(String value) {
  return value.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Map each short onto a character offset inside its chapter.
List<ShortPlace> shortPlaces(
  List<ReaderChapter> chapters,
  List<ShortSegment> shorts,
) {
  final places = <ShortPlace>[];
  final byChapter = <int, List<ShortSegment>>{};
  for (final short in shorts) {
    byChapter.putIfAbsent(short.chapterIndex, () => []).add(short);
  }

  for (final chapter in chapters) {
    final text = _squeeze(chapter.text);
    var cursor = 0;
    for (final short in byChapter[chapter.index] ?? const <ShortSegment>[]) {
      final needle = _squeeze(short.original);
      if (needle.isEmpty) continue;
      final found = text.indexOf(needle, cursor);
      final offset = found >= 0 ? found : cursor;
      places.add(
        ShortPlace(
          shortIndex: short.index,
          chapterIndex: chapter.index,
          charOffset: offset,
        ),
      );
      if (found >= 0) cursor = found + needle.length;
    }
  }
  places.sort((a, b) => a.shortIndex.compareTo(b.shortIndex));
  return places;
}

int? shortIndexAtPlace(
  List<ShortPlace> places,
  int chapterIndex,
  int charOffset,
) {
  ShortPlace? best;
  for (final place in places) {
    if (place.chapterIndex != chapterIndex) continue;
    if (place.charOffset <= charOffset) best = place;
  }
  if (best != null) return best.shortIndex;
  final inChapter = places.where((p) => p.chapterIndex == chapterIndex);
  if (inChapter.isEmpty) return null;
  return inChapter.first.shortIndex;
}

ShortPlace? placeForShort(List<ShortPlace> places, int shortIndex) {
  for (final place in places) {
    if (place.shortIndex == shortIndex) return place;
  }
  return null;
}

/// Map Story karaoke word index onto a paginated page (same passage).
int storyKaraokeWordInPage(
  String pageText,
  String shortText,
  int karaokeWord,
) {
  if (karaokeWord < 0) return -1;
  final pageWords =
      pageText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  final shortWords =
      shortText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (pageWords.isEmpty || shortWords.isEmpty) return -1;
  for (var i = 0; i <= pageWords.length - shortWords.length; i++) {
    var match = true;
    for (var j = 0; j < shortWords.length; j++) {
      if (pageWords[i + j] != shortWords[j]) {
        match = false;
        break;
      }
    }
    if (match) {
      return i + karaokeWord.clamp(0, shortWords.length - 1);
    }
  }
  return -1;
}

ReaderLocation? readerLocationForShort({
  required String bookId,
  required List<ReaderChapter> chapters,
  required List<ShortSegment> shorts,
  required int shortIndex,
  required DateTime updatedAt,
}) {
  final place = placeForShort(shortPlaces(chapters, shorts), shortIndex);
  if (place == null) return null;
  return ReaderLocation(
    bookId: bookId,
    chapterIndex: place.chapterIndex,
    charOffset: place.charOffset,
    updatedAt: updatedAt,
  );
}
