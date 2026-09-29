import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareLibraryJson(String json) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/flick-library.json');
  await file.writeAsString(json);
  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile(
          file.path,
          mimeType: 'application/json',
          name: 'flick-library.json',
        ),
      ],
      subject: 'Flick library',
    ),
  );
}
