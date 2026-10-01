import '../models/models.dart';

/// True when Story mode is on the final short and advancing should celebrate.
bool shouldCelebrateStoryFinish({
  required PlayMode mode,
  required int queueIndex,
  required int queueLength,
}) {
  return mode == PlayMode.story &&
      queueLength > 0 &&
      queueIndex >= queueLength - 1;
}
