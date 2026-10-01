import 'package:flutter_test/flutter_test.dart';
import 'package:flick/services/gutenberg_catalog.dart';

void main() {
  test('PdCatalogBook author label', () {
    final book = PdCatalogBook(
      id: 1,
      title: 'Test',
      authors: ['A', 'B'],
      textUrl: 'https://example.com/a.txt',
    );
    expect(book.authorLabel, 'A, B');
  });
}
