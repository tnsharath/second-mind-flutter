import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../conversation/application/chat_controller.dart';
import '../domain/voice_session_state.dart';

final voiceControllerProvider =
    NotifierProvider<VoiceController, VoiceSessionState>(VoiceController.new);

/// Orchestrates the voice loop: listen → think → speak, with interrupt.
///
/// Replies come from the shared chat repository (mock or real backend,
/// depending on Env.useMockApi) under the fixed conversationId 'voice'.
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

    final buffer = StringBuffer();
    try {
      await for (final chunk in ref.read(chatRepositoryProvider).sendMessage(
        conversationId: 'voice',
        text: text,
      )) {
        buffer.write(chunk);
      }
    } catch (_) {
      buffer.write('Something went wrong while reaching AURA. Please try again.');
    }
    if (state.phase != VoicePhase.thinking) return;

    final reply = buffer.toString().trim();
    state = state.copyWith(phase: VoicePhase.speaking, response: reply);
    await speech.speak(reply);
    _timer = Timer(const Duration(seconds: 6), () {
      if (state.phase == VoicePhase.speaking) {
        state = state.copyWith(phase: VoicePhase.idle);
      }
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
