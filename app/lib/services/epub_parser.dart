import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// On-device EPUB → plain text (ported from archive/v0-nextjs-web epub parser).
class ParsedEpub {
  ParsedEpub({
    required this.title,
    this.author,
    required this.text,
    required this.chapters,
  });

  final String title;
  final String? author;
  final String text;
  final List<EpubChapterSlice> chapters;
}

class EpubChapterSlice {
  EpubChapterSlice({
    required this.index,
    required this.title,
    required this.startOffset,
    required this.endOffset,
  });

  final int index;
  final String title;
  final int startOffset;
  final int endOffset;
}

ParsedEpub parseEpubBytes(Uint8List bytes, {String fallbackTitle = 'Untitled'}) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final files = <String, ArchiveFile>{};
  for (final f in archive.files) {
    if (!f.isFile) continue;
    files[_normalizeZipPath(f.name)] = f;
  }

  final container = _readString(files, 'META-INF/container.xml');
  if (container == null) {
    throw StateError('Invalid EPUB: missing container.xml');
  }

  final rootfileMatch =
      RegExp(r'full-path="([^"]+)"', caseSensitive: false).firstMatch(container);
  if (rootfileMatch == null) {
    throw StateError('Invalid EPUB: no rootfile');
  }
  final opfPath = _normalizeZipPath(rootfileMatch.group(1)!);
  final opfXml = _readString(files, opfPath);
  if (opfXml == null) {
    throw StateError('Invalid EPUB: missing OPF');
  }

  final titleMatch =
      RegExp(r'<dc:title[^>]*>([^<]+)</dc:title>', caseSensitive: false)
          .firstMatch(opfXml);
  final authorMatch =
      RegExp(r'<dc:creator[^>]*>([^<]+)</dc:creator>', caseSensitive: false)
          .firstMatch(opfXml);
  final title = (titleMatch?.group(1)?.trim().isNotEmpty ?? false)
      ? titleMatch!.group(1)!.trim()
      : fallbackTitle.replaceAll(RegExp(r'\.epub$', caseSensitive: false), '');
  final author = authorMatch?.group(1)?.trim();

  final manifest = <String, String>{};
  final manifestRe = RegExp(
    r'<item\s+[^>]*id="([^"]+)"[^>]*href="([^"]+)"[^>]*/?>',
    caseSensitive: false,
  );
  for (final m in manifestRe.allMatches(opfXml)) {
    manifest[m.group(1)!] = m.group(2)!;
  }
  // Also handle href-before-id attribute order.
  final manifestReAlt = RegExp(
    r'<item\s+[^>]*href="([^"]+)"[^>]*id="([^"]+)"[^>]*/?>',
    caseSensitive: false,
  );
  for (final m in manifestReAlt.allMatches(opfXml)) {
    manifest.putIfAbsent(m.group(2)!, () => m.group(1)!);
  }

  final spineIds = <String>[];
  final spineRe = RegExp(
    r'<itemref\s+[^>]*idref="([^"]+)"[^>]*/?>',
    caseSensitive: false,
  );
  for (final m in spineRe.allMatches(opfXml)) {
    spineIds.add(m.group(1)!);
  }

  final textParts = <String>[];
  final chapters = <EpubChapterSlice>[];
  var offset = 0;
  var chapterIndex = 0;

  for (final id in spineIds) {
    final href = manifest[id];
    if (href == null) continue;
    final resolved = _resolvePath(opfPath, href);
    final html = _readString(files, resolved);
    if (html == null) continue;
    final plain = _stripHtml(html);
    if (plain.isEmpty) continue;

    final chapterTitle = _guessChapterTitle(plain, chapterIndex);
    final start = offset;
    if (textParts.isNotEmpty) {
      offset += 2; // "\n\n" joiner
    }
    textParts.add(plain);
    offset += plain.length;
    chapters.add(
      EpubChapterSlice(
        index: chapterIndex,
        title: chapterTitle,
        startOffset: start,
        endOffset: offset,
      ),
    );
    chapterIndex += 1;
  }

  final text = textParts.join('\n\n').trim();
  if (text.isEmpty) {
    throw StateError('Could not extract text from EPUB');
  }

  if (chapters.isEmpty) {
    chapters.add(
      EpubChapterSlice(
        index: 0,
        title: 'Chapter 1',
        startOffset: 0,
        endOffset: text.length,
      ),
    );
  }

  return ParsedEpub(
    title: title,
    author: author,
    text: text,
    chapters: chapters,
  );
}

String _normalizeZipPath(String path) =>
    path.replaceAll('\\', '/').replaceFirst(RegExp(r'^/+'), '');

String? _readString(Map<String, ArchiveFile> files, String path) {
  final key = _normalizeZipPath(path);
  final file = files[key] ??
      files.entries
          .where((e) => e.key.toLowerCase() == key.toLowerCase())
          .map((e) => e.value)
          .firstOrNull;
  if (file == null) return null;
  final content = file.content as List<int>;
  return utf8.decode(content, allowMalformed: true);
}

String _resolvePath(String base, String href) {
  if (href.startsWith('/')) return _normalizeZipPath(href);
  final parts = base.split('/');
  parts.removeLast();
  for (final seg in href.split('/')) {
    if (seg == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else if (seg.isNotEmpty && seg != '.') {
      parts.add(seg);
    }
  }
  return parts.join('/');
}

String _stripHtml(String html) {
  var s = html;
  s = s.replaceAll(
    RegExp(r'<(script|style)[^>]*>[\s\S]*?</\1>', caseSensitive: false),
    ' ',
  );
  s = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
  s = s.replaceAll(RegExp(r'<[^>]+>'), ' ');
  s = s
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
  s = s.replaceAll(RegExp(r'[ \t\f\v]+'), ' ');
  s = s.replaceAll(RegExp(r' *\n *'), '\n');
  s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  s = s.replaceAllMapped(
    RegExp(r'([.!?])\s+'),
    (m) => '${m.group(1)}\n\n',
  );
  return s.trim();
}

String _guessChapterTitle(String plain, int index) {
  final firstLine = plain.split(RegExp(r'\n+')).first.trim();
  if (firstLine.isNotEmpty && firstLine.length <= 80) {
    return firstLine;
  }
  return 'Chapter ${index + 1}';
}

extension<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
