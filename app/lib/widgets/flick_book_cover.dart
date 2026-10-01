import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/book_cover.dart';
import '../models/models.dart';

/// Typography cover (T11 default). Optional bundled asset when cleared in manifest.
class FlickBookCover extends StatelessWidget {
  const FlickBookCover({
    super.key,
    required this.book,
    this.width = 72,
    this.height = 96,
    this.borderRadius = 8,
  });

  final LibraryBook book;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final meta = coverMetaForBook(book);
    if (meta.source == CoverSource.bundled &&
        meta.assetPath != null &&
        meta.assetPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          meta.assetPath!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _TypographyCover(
            book: book,
            width: width,
            height: height,
            borderRadius: borderRadius,
          ),
        ),
      );
    }
    return _TypographyCover(
      book: book,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

class _TypographyCover extends StatelessWidget {
  const _TypographyCover({
    required this.book,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final LibraryBook book;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final hue = coverAccentHue(book);
    final onDark = HSLColor.fromAHSL(1, hue, 0.08, 0.95).toColor();
    final ink = HSLColor.fromAHSL(1, hue, 0.35, 0.22).toColor();
    final accent = HSLColor.fromAHSL(1, hue, 0.55, 0.45).toColor();
    final title = _shortTitle(book.title);
    final author = book.author ?? '';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue, 0.42, 0.38).toColor(),
            HSLColor.fromAHSL(1, (hue + 28) % 360, 0.38, 0.28).toColor(),
          ],
        ),
        border: Border.all(color: ink.withValues(alpha: 0.12)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.literata(
                    fontSize: width > 60 ? 11 : 9,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    color: onDark,
                  ),
                ),
                if (author.isNotEmpty) ...[
                  const Spacer(),
                  Text(
                    author,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.literata(
                      fontSize: 8,
                      height: 1.1,
                      color: onDark.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortTitle(String raw) {
    final t = raw.trim();
    if (t.length <= 48) return t;
    return '${t.substring(0, 45)}…';
  }
}
