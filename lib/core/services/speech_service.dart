import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Speech-to-text + text-to-speech abstraction used by voice mode.
///
/// Every plugin call is guarded: on devices without speech services the
/// service degrades gracefully and voice mode falls back to simulation.
class SpeechService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _sttAvailable = false;
  bool _ttsReady = false;

  bool get isListening => _stt.isListening;

  Future<bool> initSpeech() async {
    try {
      _sttAvailable = await _stt.initialize(onError: (_) {}, onStatus: (_) {});
    } catch (_) {
      _sttAvailable = false;
    }
    return _sttAvailable;
  }

  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
  }) async {
    if (!_sttAvailable) return;
    try {
      await _stt.listen(
        onResult: (result) => onResult(result.recognizedWords, result.finalResult),
        listenOptions: SpeechListenOptions(partialResults: true),
      );
    } catch (_) {
      // Ignore — caller falls back to simulated input.
    }
  }

  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    try {
      if (!_ttsReady) {
        await _tts.setLanguage('en-US');
        await _tts.setSpeechRate(0.5);
        await _tts.setPitch(1.0);
        await _tts.setAwaitSpeakCompletion(true);
        _ttsReady = true;
      }
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
