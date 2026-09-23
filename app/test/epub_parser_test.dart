import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flick/services/epub_parser.dart';

Uint8List _minimalEpub() {
  final archive = Archive();

  void add(String name, String body) {
    final bytes = utf8.encode(body);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  add(
    'META-INF/container.xml',
    '''<?xml version="1.0"?>
<container>
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>''',
  );
  add(
    'OEBPS/content.opf',
    '''<?xml version="1.0"?>
<package>
  <metadata>
    <dc:title>Tiny Flick Book</dc:title>
    <dc:creator>Test Author</dc:creator>
  </metadata>
  <manifest>
    <item id="c1" href="chap1.xhtml" media-type="application/xhtml+xml"/>
    <item id="c2" href="chap2.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine>
    <itemref idref="c1"/>
    <itemref idref="c2"/>
  </spine>
</package>''',
  );
  add(
    'OEBPS/chap1.xhtml',
    '''<html><body>
      <h1>Chapter 1</h1>
      <p>Once upon a time there was a short that wanted to be read.</p>
    </body></html>''',
  );
  add(
    'OEBPS/chap2.xhtml',
    '''<html><body>
      <h1>Chapter 2</h1>
      <p>Then the anti-doomscroll reader finished the book.</p>
    </body></html>''',
  );

  return Uint8List.fromList(ZipEncoder().encode(archive));
}

void main() {
  test('parseEpubBytes extracts title, author, text, chapters', () {
    final parsed = parseEpubBytes(_minimalEpub());
    expect(parsed.title, 'Tiny Flick Book');
    expect(parsed.author, 'Test Author');
    expect(parsed.text, contains('Once upon a time'));
    expect(parsed.text, contains('anti-doomscroll'));
    expect(parsed.chapters.length, 2);
    expect(parsed.chapters.first.title, contains('Chapter 1'));
  });
}
