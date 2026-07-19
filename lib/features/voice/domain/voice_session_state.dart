enum VoicePhase { idle, listening, thinking, speaking }

class VoiceSessionState {
  const VoiceSessionState({
    this.phase = VoicePhase.idle,
    this.transcript = '',
    this.response = '',
  });

  final VoicePhase phase;
  final String transcript;
  final String response;

  VoiceSessionState copyWith({
    VoicePhase? phase,
    String? transcript,
    String? response,
  }) {
    return VoiceSessionState(
      phase: phase ?? this.phase,
      transcript: transcript ?? this.transcript,
      response: response ?? this.response,
    );
  }
}
