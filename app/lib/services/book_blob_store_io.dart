import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String?> writeTextBlob(String bookId, String text) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory(p.join(dir.path, 'books'));
    if (!await booksDir.exists()) await booksDir.create(recursive: true);
    final file = File(p.join(booksDir.path, '$bookId.txt'));
    await file.writeAsString(text, encoding: utf8);
    return file.path;
  } catch (_) {
    return null;
  }
}

Future<String?> writeBinaryBlob(
  String bookId,
  String ext,
  List<int> bytes,
) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory(p.join(dir.path, 'books'));
    if (!await booksDir.exists()) await booksDir.create(recursive: true);
    final file = File(p.join(booksDir.path, '$bookId.$ext'));
    await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
    return file.path;
  } catch (_) {
    return null;
  }
}
