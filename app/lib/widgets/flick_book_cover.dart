import 'dart:math' as math;

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
    this.layout = BookCoverLayout.auto,
  });

  final LibraryBook book;
  final double width;
  final double height;
  final double borderRadius;
  final BookCoverLayout layout;

  @override
  Widget build(BuildContext context) {
    final meta = coverMetaForBook(book);
    final tier = _resolveTier();
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
            tier: tier,
          ),
        ),
      );
    }
    return _TypographyCover(
      book: book,
      width: width,
      height: height,
      borderRadius: borderRadius,
      tier: tier,
    );
  }

  _CoverTier _resolveTier() {
    switch (layout) {
      case BookCoverLayout.chip:
        return _CoverTier.chip;
      case BookCoverLayout.poster:
        return _CoverTier.poster;
      case BookCoverLayout.auto:
        if (height < 78 || width < 60) return _CoverTier.chip;
        if (width >= 96 && height >= 118) return _CoverTier.poster;
        return _CoverTier.standard;
    }
  }
}

enum BookCoverLayout { auto, chip, poster }

enum _CoverTier { chip, standard, poster }

class _TypographyCover extends StatelessWidget {
  const _TypographyCover({
    required this.book,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.tier,
  });

  final LibraryBook book;
  final double width;
  final double height;
  final double borderRadius;
  final _CoverTier tier;

  @override
  Widget build(BuildContext context) {
    final hue = coverAccentHue(book);
    final onDark = HSLColor.fromAHSL(1, hue, 0.08, 0.95).toColor();
    final ink = HSLColor.fromAHSL(1, hue, 0.35, 0.22).toColor();
    final accent = HSLColor.fromAHSL(1, hue, 0.55, 0.45).toColor();
    final author = book.author ?? '';
    final title = _shortTitle(
      book.title,
      tier == _CoverTier.chip ? 28 : (tier == _CoverTier.poster ? 64 : 48),
    );

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: gradient,
          child: switch (tier) {
            _CoverTier.chip => _chipBody(accent, onDark),
            _CoverTier.standard => _standardBody(title, author, accent, onDark),
            _CoverTier.poster => _posterBody(title, author, accent, onDark),
          },
        ),
      ),
    );
  }

  Widget _chipBody(Color accent, Color onDark) {
    return Stack(
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
              fontSize: (math.min(width, height) * 0.34).clamp(15, 22),
              fontWeight: FontWeight.w700,
              color: onDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _standardBody(
    String title,
    String author,
    Color accent,
    Color onDark,
  ) {
    final pad = (width * 0.07).clamp(7.0, 11.0);
    final titleSize = (width * 0.085).clamp(10.0, 15.0);
    final authorSize = (titleSize * 0.72).clamp(8.0, 11.0);
    final chip = (width * 0.08).clamp(11.0, 14.0);

    return Stack(
      children: [
        Positioned(
          top: pad,
          right: pad,
          child: Container(
            width: chip,
            height: chip,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(chip * 0.22),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, pad * 1.1, pad, pad * 0.9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.literata(
                      fontSize: titleSize,
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
                      fontSize: authorSize,
                      height: 1.08,
                      color: onDark.withValues(alpha: 0.82),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _posterBody(
    String title,
    String author,
    Color accent,
    Color onDark,
  ) {
    final pad = (width * 0.09).clamp(12.0, 18.0);
    final titleSize = (width * 0.105).clamp(16.0, 26.0);
    final authorSize = (titleSize * 0.62).clamp(11.0, 15.0);
    final chip = (width * 0.09).clamp(14.0, 20.0);
    final watermark = (math.min(width, height) * 0.42).clamp(48.0, 120.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Text(
            _monogram(book.title),
            style: GoogleFonts.literata(
              fontSize: watermark,
              fontWeight: FontWeight.w700,
              color: onDark.withValues(alpha: 0.14),
            ),
          ),
        ),
        Positioned(
          top: pad,
          right: pad,
          child: Container(
            width: chip,
            height: chip,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(chip * 0.22),
            ),
          ),
        ),
        Positioned(
          left: pad,
          right: pad,
          bottom: pad,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad * 0.85, pad * 0.65, pad * 0.85, pad * 0.75),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.literata(
                      fontSize: titleSize,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                      color: onDark,
                    ),
                  ),
                  if (author.isNotEmpty) ...[
                    SizedBox(height: pad * 0.35),
                    Text(
                      author,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.literata(
                        fontSize: authorSize,
                        height: 1.1,
                        color: onDark.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
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
