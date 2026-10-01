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

  /// Full title stack needs ~76px; smaller slots use monogram layout.
  bool get _compact => height < 78 || width < 60;

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
            compact: _compact,
          ),
        ),
      );
    }
    return _TypographyCover(
      book: book,
      width: width,
      height: height,
      borderRadius: borderRadius,
      compact: _compact,
    );
  }
}

class _TypographyCover extends StatelessWidget {
  const _TypographyCover({
    required this.book,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.compact,
  });

  final LibraryBook book;
  final double width;
  final double height;
  final double borderRadius;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hue = coverAccentHue(book);
    final onDark = HSLColor.fromAHSL(1, hue, 0.08, 0.95).toColor();
    final ink = HSLColor.fromAHSL(1, hue, 0.35, 0.22).toColor();
    final accent = HSLColor.fromAHSL(1, hue, 0.55, 0.45).toColor();
    final title = _shortTitle(book.title, compact ? 28 : 48);
    final author = book.author ?? '';

    final gradient = BoxDecoration(
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
    );

    if (compact) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: gradient,
            child: Stack(
              children: [
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    _monogram(book.title),
                    style: GoogleFonts.literata(
                      fontSize: (width * 0.38).clamp(16, 24),
                      fontWeight: FontWeight.w700,
                      color: onDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: gradient,
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
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 9, 8, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.literata(
                            fontSize: width > 60 ? 11 : 10,
                            height: 1.12,
                            fontWeight: FontWeight.w600,
                            color: onDark,
                          ),
                        ),
                      ),
                      if (author.isNotEmpty)
                        Text(
                          author,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.literata(
                            fontSize: 8,
                            height: 1.08,
                            color: onDark.withValues(alpha: 0.82),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monogram(String title) {
    final t = title.trim();
    if (t.isEmpty) return '?';
    final words = t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return '${words.first[0]}${words[1][0]}'.toUpperCase();
    }
    return t.substring(0, 1).toUpperCase();
  }

  String _shortTitle(String raw, int maxLen) {
    final t = raw.trim();
    if (t.length <= maxLen) return t;
    return '${t.substring(0, maxLen - 1)}…';
  }
}
