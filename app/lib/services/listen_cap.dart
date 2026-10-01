const freeListenDailyCapSeconds = 60 * 60;

bool isListenCapped({
  required bool plusActive,
  required int listenSecondsToday,
}) {
  return !plusActive && listenSecondsToday >= freeListenDailyCapSeconds;
}

String formatListenRemaining(int seconds) {
  if (seconds <= 0) return 'No free Listen left today';
  final minutes = (seconds / 60).ceil();
  if (minutes >= 60) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '$h h Listen left today';
    return '$h h $m m Listen left today';
  }
  return '$minutes min Listen left today';
}
