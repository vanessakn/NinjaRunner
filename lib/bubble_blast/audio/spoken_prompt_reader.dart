import 'package:flutter_tts/flutter_tts.dart';

abstract class TextToSpeechEngine {
  Future<void> speak(String text);
  Future<void> stop();
}

class FlutterTtsEngine implements TextToSpeechEngine {
  FlutterTtsEngine({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;

  @override
  Future<void> speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.05);
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}

class SpokenPromptReader {
  SpokenPromptReader({TextToSpeechEngine? engine})
      : _engine = engine ?? FlutterTtsEngine();

  final TextToSpeechEngine _engine;
  bool isMuted = false;

  Future<void> speak(String text) async {
    if (isMuted || text.trim().isEmpty) {
      return;
    }
    await _engine.speak(text);
  }

  Future<void> stop() async {
    await _engine.stop();
  }
}
