import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/bubble_blast/audio/spoken_prompt_reader.dart';

class FakeTextToSpeechEngine implements TextToSpeechEngine {
  final spokenTexts = <String>[];
  var stopCount = 0;

  @override
  Future<void> speak(String text) async {
    spokenTexts.add(text);
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }
}

void main() {
  test('speaks prompt text when unmuted', () async {
    final engine = FakeTextToSpeechEngine();
    final reader = SpokenPromptReader(engine: engine);

    await reader.speak('Can you find blue?');

    expect(engine.spokenTexts, ['Can you find blue?']);
  });

  test('does not speak prompt text while muted', () async {
    final engine = FakeTextToSpeechEngine();
    final reader = SpokenPromptReader(engine: engine)..isMuted = true;

    await reader.speak('Can you find blue?');

    expect(engine.spokenTexts, isEmpty);
  });

  test('stops speech through the engine', () async {
    final engine = FakeTextToSpeechEngine();
    final reader = SpokenPromptReader(engine: engine);

    await reader.stop();

    expect(engine.stopCount, 1);
  });
}
