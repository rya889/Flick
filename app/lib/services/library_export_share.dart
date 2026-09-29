import 'library_export_share_stub.dart'
    if (dart.library.io) 'library_export_share_io.dart' as impl;

Future<void> shareLibraryJson(String json) => impl.shareLibraryJson(json);
