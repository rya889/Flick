import 'book_blob_store_stub.dart'
    if (dart.library.io) 'book_blob_store_io.dart' as impl;

Future<String?> writeTextBlob(String bookId, String text) =>
    impl.writeTextBlob(bookId, text);

Future<String?> writeBinaryBlob(
  String bookId,
  String ext,
  List<int> bytes,
) =>
    impl.writeBinaryBlob(bookId, ext, bytes);
