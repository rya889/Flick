import 'package:share_plus/share_plus.dart';

Future<void> shareLibraryJson(String json) {
  return SharePlus.instance.share(
    ShareParams(text: json, subject: 'Flick library'),
  );
}
