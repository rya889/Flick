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
    this.retrievedAt,
  });

  final CoverSource source;
  final String? assetPath;
  final String? license;
  final String? attribution;
  final String? lookupId;
  final String? retrievedAt;
}

/// Per-title overrides when bundled art is cleared (T11 / T15 manifest).
const _seedCoverOverrides = <String, BookCoverMeta>{
  kBartlebySampleId: BookCoverMeta(
    source: CoverSource.bundled,
    assetPath: 'assets/covers/bartleby.jpg',
    license: 'CC0-1.0',
    attribution:
        'Cover art from Standard Ebooks edition: Herman Melville, Short Fiction (includes Bartleby). standardebooks.org',
    lookupId: 'se:herman-melville/short-fiction',
    retrievedAt: '2026-10-01',
  ),
  'sample-machine-stops': BookCoverMeta(
    source: CoverSource.bundled,
    assetPath: 'assets/covers/machine-stops.jpg',
    license: 'CC0-1.0',
    attribution:
        'Cover art from Standard Ebooks edition: E. M. Forster, Short Fiction (includes The Machine Stops). standardebooks.org',
    lookupId: 'se:e-m-forster/short-fiction',
    retrievedAt: '2026-10-01',
  ),
  'sample-notes-underground': BookCoverMeta(
    source: CoverSource.bundled,
    assetPath: 'assets/covers/notes-underground.jpg',
    license: 'CC0-1.0',
    attribution:
        'Cover art from Standard Ebooks: Notes from Underground (Constance Garnett trans.). standardebooks.org',
    lookupId:
        'se:fyodor-dostoevsky/notes-from-underground/constance-garnett',
    retrievedAt: '2026-10-01',
  ),
  'sample-jekyll-hyde': BookCoverMeta(
    source: CoverSource.bundled,
    assetPath: 'assets/covers/jekyll-hyde.jpg',
    license: 'CC0-1.0',
    attribution:
        'Cover art from Standard Ebooks: The Strange Case of Dr. Jekyll and Mr. Hyde. standardebooks.org',
    lookupId: 'se:robert-louis-stevenson/the-strange-case-of-dr-jekyll-and-mr-hyde',
    retrievedAt: '2026-10-01',
  ),
  'sample-time-machine': BookCoverMeta(
    source: CoverSource.bundled,
    assetPath: 'assets/covers/time-machine.jpg',
    license: 'CC0-1.0',
    attribution:
        'Cover art from Standard Ebooks: The Time Machine. standardebooks.org',
    lookupId: 'se:h-g-wells/the-time-machine',
    retrievedAt: '2026-10-01',
  ),
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
