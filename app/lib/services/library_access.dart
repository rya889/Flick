import '../models/models.dart';

/// Free tier for the fixed-price MVP.
const freeBookLimit = 2;

/// Premium library size. Samples do not count toward either cap.
const premiumBookLimit = 50;

enum LibraryBlock { bookCap, extensionLocked }

int countedImports(Iterable<LibraryBook> books) {
  return books.where((book) => book.source != BookSource.sample).length;
}

int bookLimitFor({required bool premium}) {
  return premium ? premiumBookLimit : freeBookLimit;
}

bool importAllowed(BookSource source, {required bool premium}) {
  if (source == BookSource.epub) return premium;
  return source == BookSource.txt ||
      source == BookSource.paste ||
      source == BookSource.sample ||
      source == BookSource.catalog;
}

LibraryBlock? blockImport(
  BookSource source, {
  required bool premium,
  required int importedBooks,
}) {
  if (!importAllowed(source, premium: premium)) {
    return LibraryBlock.extensionLocked;
  }
  if (source == BookSource.sample) return null;
  if (importedBooks >= bookLimitFor(premium: premium)) {
    return LibraryBlock.bookCap;
  }
  return null;
}
