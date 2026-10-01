import 'package:flutter_test/flutter_test.dart';
import 'package:flick/services/listen_cap.dart';

void main() {
  test('free listen cap at 60 minutes', () {
    expect(
      isListenCapped(plusActive: false, listenSecondsToday: 3599),
      isFalse,
    );
    expect(
      isListenCapped(plusActive: false, listenSecondsToday: 3600),
      isTrue,
    );
    expect(
      isListenCapped(plusActive: true, listenSecondsToday: 99999),
      isFalse,
    );
  });

  test('formatListenRemaining is human readable', () {
    expect(formatListenRemaining(1800), contains('min'));
    expect(formatListenRemaining(0), contains('No free'));
  });
}
