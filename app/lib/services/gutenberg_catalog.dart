import 'dart:convert';

import 'package:http/http.dart' as http;

/// Gutendex (Gutenberg metadata API) — see docs/plan/pd-library-source-2026-10-01.md.
const gutendexBase = 'https://gutendex.com';

class PdCatalogBook {
  PdCatalogBook({
    required this.id,
    required this.title,
    required this.authors,
    required this.textUrl,
  });

  final int id;
  final String title;
  final List<String> authors;
  final String textUrl;

  String get authorLabel =>
      authors.isEmpty ? 'Unknown author' : authors.join(', ');
}

class GutenbergCatalogClient {
  GutenbergCatalogClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<PdCatalogBook>> search({
    String query = '',
    int page = 1,
  }) async {
    final q = query.trim().isEmpty ? 'fiction' : query.trim();
    final uri = Uri.parse('$gutendexBase/books/').replace(
      queryParameters: {
        'search': q,
        'page': '$page',
        'languages': 'en',
      },
    );
    final response = await _client.get(uri).timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw StateError('Catalog unavailable (${response.statusCode})');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>? ?? [];
    final books = <PdCatalogBook>[];
    for (final raw in results) {
      final book = _parseBook(raw as Map<String, dynamic>);
      if (book != null) books.add(book);
    }
    return books;
  }

  PdCatalogBook? _parseBook(Map<String, dynamic> json) {
    final id = json['id'] as int?;
    final title = (json['title'] as String?)?.trim();
    if (id == null || title == null || title.isEmpty) return null;
    final authors = <String>[];
    for (final a in json['authors'] as List<dynamic>? ?? []) {
      final name = (a as Map<String, dynamic>)['name'] as String?;
      if (name != null && name.isNotEmpty) authors.add(name);
    }
    final formats = json['formats'] as Map<String, dynamic>? ?? {};
    String? textUrl;
    for (final key in formats.keys) {
      if (key.startsWith('text/plain')) {
        textUrl = formats[key] as String?;
        break;
      }
    }
    textUrl ??= formats['text/plain'] as String?;
    if (textUrl == null || textUrl.isEmpty) return null;
    return PdCatalogBook(
      id: id,
      title: title,
      authors: authors,
      textUrl: textUrl,
    );
  }

  Future<String> downloadPlainText(String url) async {
    final response = await _client.get(Uri.parse(url)).timeout(
      const Duration(seconds: 45),
    );
    if (response.statusCode != 200) {
      throw StateError('Download failed (${response.statusCode})');
    }
    return utf8.decode(response.bodyBytes);
  }

  void close() => _client.close();
}
