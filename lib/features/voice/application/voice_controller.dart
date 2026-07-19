import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../domain/voice_session_state.dart';

final voiceControllerProvider =
    NotifierProvider<VoiceController, VoiceSessionState>(VoiceController.new);

/// Orchestrates the voice loop: listen → think → speak, with interrupt.
///
/// TODO(backend): POST /voice + WebSocket streaming for real-time turns.
class VoiceController extends Notifier<VoiceSessionState> {
  Timer? _timer;

  @override
  VoiceSessionState build() {
    ref.onDispose(() => _timer?.cancel());
    return const VoiceSessionState();
  }

  Future<void> toggle() async {
    if (state.phase == VoicePhase.idle) {
      await start();
    } else {
      await interrupt();
    }
  }

  Future<void> start() async {
    final speech = ref.read(speechServiceProvider);
    final available = await speech.initSpeech();
    state = state.copyWith(
      phase: VoicePhase.listening,
      transcript: '',
      response: '',
    );

    if (available) {
      await speech.startListening(
        onResult: (words, isFinal) {
          state = state.copyWith(transcript: words);
          if (isFinal && words.trim().isNotEmpty) {
            unawaited(_respond(words));
          }
        },
      );
    } else {
      // Graceful fallback on devices without speech services.
      _timer = Timer(const Duration(seconds: 2), () {
        const simulated = 'What does my day look like?';
        state = state.copyWith(transcript: simulated);
        unawaited(_respond(simulated));
      });
    }
  }

  Future<void> _respond(String text) async {
    final speech = ref.read(speechServiceProvider);
    await speech.stopListening();
    state = state.copyWith(phase: VoicePhase.thinking, transcript: text);

    _timer = Timer(const Duration(milliseconds: 900), () async {
      const reply =
          'You have two meetings today — standup at 10:30 and a design '
          'review at 14:00. Three goals are still open, and your evening '
          'is clear. I will keep an eye on everything.';
      state = state.copyWith(phase: VoicePhase.speaking, response: reply);
      await speech.speak(reply);
      _timer = Timer(const Duration(seconds: 6), () {
        if (state.phase == VoicePhase.speaking) {
          state = state.copyWith(phase: VoicePhase.idle);
        }
      });
    });
  }

  Future<void> interrupt() async {
    _timer?.cancel();
    final speech = ref.read(speechServiceProvider);
    await speech.stopListening();
    await speech.stopSpeaking();
    state = state.copyWith(phase: VoicePhase.idle);
  }
}
