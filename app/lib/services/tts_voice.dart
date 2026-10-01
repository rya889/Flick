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

  /// Enhanced / Siri-class voices (Pro perk on device).
  bool get isPremiumTier => natural && rank >= 2;

  Map<String, String> toTtsVoice() {
    return {
      'name': name,
      'locale': locale,
      if (identifier != null && identifier!.isNotEmpty) 'identifier': identifier!,
    };
  }
}

/// Prefer a natural English voice already installed on the device.
///
/// When [allowPremiumVoices] is false (free tier), only compact/basic voices
/// are considered so Listen stays on-device without Pro-enhanced picks.
SpokenVoice? pickSpokenVoice(
  Iterable<Map<String, String>> voices, {
  bool allowPremiumVoices = true,
}) {
  SpokenVoice? best;
  var bestScore = 0;
  for (final raw in voices) {
    final voice = _normalize(raw);
    if (!allowPremiumVoices && voice.isPremiumTier) continue;
    final score = _score(voice, allowPremiumVoices: allowPremiumVoices);
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

int _score(SpokenVoice voice, {required bool allowPremiumVoices}) {
  final locale = voice.locale.toLowerCase();
  if (!locale.startsWith('en')) return 0;
  var score = locale.startsWith('en-us')
      ? 20
      : locale.startsWith('en-gb')
          ? 12
          : 6;
  final id = (voice.identifier ?? '').toLowerCase();
  final name = voice.name.toLowerCase();
  final siri = id.contains('siri') || name.contains('siri');
  if (!allowPremiumVoices) {
    if (siri || voice.rank >= 2) return 0;
    score += 8;
    const preferredBasic = ['samantha', 'karen', 'daniel', 'arthur'];
    for (final token in preferredBasic) {
      if (name.contains(token) || id.contains(token)) score += 4;
    }
    return score;
  }
  // Premium voices are listed even when that audio is not downloaded.
  // iOS then substitutes the compact voice, which sounds robotic.
  if (siri) {
    score += 120;
  } else if (voice.rank == 2) {
    score += 100;
  } else if (voice.rank >= 3) {
    score += 40;
  } else {
    score += 5;
  }
  const preferred = ['ava', 'zoe', 'allison', 'nicky', 'nathan'];
  for (final token in preferred) {
    if (name.contains(token) || id.contains(token)) score += 6;
  }
  return score;
}

SpokenVoice spokenVoiceFromMap(Map<String, String> raw) => _normalize(raw);

int spokenVoiceSortScore(SpokenVoice voice, {bool allowPremiumVoices = true}) =>
    _score(voice, allowPremiumVoices: allowPremiumVoices);
