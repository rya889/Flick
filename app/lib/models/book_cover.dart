import 'models.dart';

/// How the shelf cover was produced (T11 policy).
enum CoverSource { generated, bundled, lookupPending }

class BookCoverMeta {
  const BookCoverMeta({
    required this.source,
    this.assetPath,
    this.license,
    this.attribution,
    this.lookupId,
  });

  final CoverSource source;
  final String? assetPath;
  final String? license;
  final String? attribution;
  final String? lookupId;
}

/// Per-title overrides when bundled art is cleared (T11 manifest).
const _seedCoverOverrides = <String, BookCoverMeta>{
  // All seed titles: generated only until art is rights-recorded in docs.
};

BookCoverMeta coverMetaForBook(LibraryBook book) {
  final override = _seedCoverOverrides[book.id];
  if (override != null) return override;
  if (book.source == BookSource.sample) {
    return const BookCoverMeta(source: CoverSource.generated);
  }
  return const BookCoverMeta(source: CoverSource.generated);
}

/// Stable accent from book id + hue for typography covers.
double coverAccentHue(LibraryBook book) {
  final mixed = (book.coverHue + book.id.hashCode % 360).abs();
  return mixed % 360;
}
