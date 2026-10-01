import 'package:flick/services/tts_voice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('enhanced voice is chosen over an undownloaded premium voice', () {
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
        'quality': 'premium',
      },
      {
        'name': 'Daniel',
        'locale': 'en-GB',
        'identifier': 'com.apple.voice.enhanced.en-GB.Daniel',
        'quality': 'enhanced',
      },
    ]);

    expect(picked?.name, 'Daniel');
    expect(picked?.natural, isTrue);
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

  test('Siri is used instead of a premium voice that may not be downloaded', () {
    final picked = pickSpokenVoice(const [
      {
        'name': 'Ava',
        'locale': 'en-US',
        'identifier': 'com.apple.voice.premium.en-US.Ava',
        'quality': 'premium',
      },
      {
        'name': 'Nicky',
        'locale': 'en-US',
        'identifier': 'com.apple.ttsbundle.siri_Nicky_en-US_compact',
        'quality': 'default',
      },
    ]);

    expect(picked?.name, 'Nicky');
  });

  test('free tier avoids premium and enhanced voices', () {
    final picked = pickSpokenVoice(const [
      {
        'name': 'Daniel',
        'locale': 'en-GB',
        'identifier': 'com.apple.voice.enhanced.en-GB.Daniel',
        'quality': 'enhanced',
      },
      {
        'name': 'Samantha',
        'locale': 'en-US',
        'identifier': 'com.apple.voice.compact.en-US.Samantha',
      },
    ], allowPremiumVoices: false);

    expect(picked?.name, 'Samantha');
    expect(picked?.isPremiumTier, isFalse);
  });
}
