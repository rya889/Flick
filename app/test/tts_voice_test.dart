import 'package:flick/services/tts_voice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pickSpokenVoice prefers premium English over compact', () {
    final picked = pickSpokenVoice(const [
      {
        'name': 'Samantha',
        'locale': 'en-US',
        'identifier': 'com.apple.voice.compact.en-US.Samantha',
        'quality': 'default',
      },
      {
        'name': 'Ava',
        'locale': 'en-US',
        'identifier': 'com.apple.voice.premium.en-US.Ava',
        'quality': '3',
      },
      {
        'name': 'Daniel',
        'locale': 'en-GB',
        'identifier': 'com.apple.voice.enhanced.en-GB.Daniel',
        'quality': 'enhanced',
      },
    ]);

    expect(picked?.name, 'Ava');
    expect(picked?.natural, isTrue);
    expect(picked?.toTtsVoice()['identifier'], contains('premium'));
  });

  test('pickSpokenVoice uses Siri before a compact voice', () {
    final picked = pickSpokenVoice(const [
      {
        'name': 'Samantha',
        'locale': 'en-US',
        'identifier': 'com.apple.voice.compact.en-US.Samantha',
      },
      {
        'name': 'Nicky',
        'locale': 'en-US',
        'identifier': 'com.apple.ttsbundle.siri_Nicky_en-US_compact',
      },
    ]);

    expect(picked?.name, 'Nicky');
    expect(picked?.natural, isTrue);
  });
}
