class SpokenVoice {
  const SpokenVoice({
    required this.name,
    required this.locale,
    this.identifier,
    required this.natural,
    this.rank = 1,
  });

  final String name;
  final String locale;
  final String? identifier;
  final bool natural;
  final int rank;

  Map<String, String> toTtsVoice() {
    return {
      'name': name,
      'locale': locale,
      if (identifier != null && identifier!.isNotEmpty) 'identifier': identifier!,
    };
  }
}

/// Prefer a natural English voice already installed on the device.
SpokenVoice? pickSpokenVoice(Iterable<Map<String, String>> voices) {
  SpokenVoice? best;
  var bestScore = 0;
  for (final raw in voices) {
    final voice = _normalize(raw);
    final score = _score(voice);
    if (score > bestScore) {
      bestScore = score;
      best = voice;
    }
  }
  return best;
}

SpokenVoice _normalize(Map<String, String> raw) {
  final name = raw['name'] ?? raw['voice'] ?? '';
  final locale = (raw['locale'] ?? raw['language'] ?? '').replaceAll('_', '-');
  final identifier = raw['identifier'] ?? raw['id'];
  final quality = (raw['quality'] ?? '').toLowerCase();
  final id = (identifier ?? '').toLowerCase();
  final qualityRank = _qualityRank(quality, id);
  final natural = qualityRank >= 2 || id.contains('siri');
  return SpokenVoice(
    name: name,
    locale: locale,
    identifier: identifier,
    natural: natural,
    rank: qualityRank,
  );
}

int _qualityRank(String quality, String id) {
  if (quality == '3' || quality.contains('premium') || id.contains('.premium.')) {
    return 3;
  }
  if (quality == '2' || quality.contains('enhanced') || id.contains('.enhanced.')) {
    return 2;
  }
  if (id.contains('siri')) return 2;
  return 1;
}

int _score(SpokenVoice voice) {
  final locale = voice.locale.toLowerCase();
  if (!locale.startsWith('en')) return 0;
  var score = locale.startsWith('en-us')
      ? 20
      : locale.startsWith('en-gb')
          ? 12
          : 6;
  final id = (voice.identifier ?? '').toLowerCase();
  final name = voice.name.toLowerCase();
  if (voice.rank >= 3) {
    score += 100;
  } else if (voice.rank == 2) {
    score += 70;
  } else {
    score += 5;
  }
  const preferred = ['ava', 'zoe', 'allison', 'nicky', 'nathan', 'samantha'];
  for (final token in preferred) {
    if (name.contains(token) || id.contains(token)) score += 6;
  }
  return score;
}
