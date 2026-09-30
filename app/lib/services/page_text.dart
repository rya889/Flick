class PageBlock {
  const PageBlock(this.words);

  final List<String> words;

  String get text => words.join(' ');
}

/// Paragraphs stay the same whether or not a word is highlighted.
List<PageBlock> pageBlocks(String text) {
  final normalized = text.replaceAll('\r\n', '\n').trim();
  if (normalized.isEmpty) return const [];
  final parts = normalized.split(RegExp(r'\n\s*\n|\n'));
  return [
    for (final part in parts)
      if (part.trim().isNotEmpty)
        PageBlock(
          part.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList(),
        ),
  ];
}

/// How the page is spaced. Highlight index must not change this.
String pageLayoutSignature(String text) {
  final blocks = pageBlocks(text);
  return blocks.map((block) => block.words.length.toString()).join('|');
}
