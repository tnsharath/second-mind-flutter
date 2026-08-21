import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_focus_repository.dart';
import '../data/mock_focus_repository.dart';
import '../domain/focus_repository.dart';
import '../domain/focus_session.dart';

final focusRepositoryProvider = Provider<FocusRepository>(
  (ref) => Env.useMockApi
      ? MockFocusRepository()
      : ApiFocusRepository(ref.watch(apiClientProvider)),
);

final focusSessionsProvider =
    AsyncNotifierProvider<FocusController, List<FocusSession>>(
  FocusController.new,
);

class FocusController extends AsyncNotifier<List<FocusSession>> {
  FocusRepository get _repository => ref.read(focusRepositoryProvider);

  @override
  Future<List<FocusSession>> build() => _repository.getSessions();

  /// Logs a finished session and appends it to the cached list.
  Future<void> logSession({
    required int minutes,
    required DateTime startedAt,
  }) async {
    final current = state.valueOrNull ?? const <FocusSession>[];
    try {
      final session = await _repository.logSession(
        minutes: minutes,
        startedAt: startedAt,
      );
      state = AsyncData([...current, session]);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

enum FocusPhase { idle, running, paused, completed }

class FocusTimerState {
  const FocusTimerState({
    this.phase = FocusPhase.idle,
    this.selectedMinutes = 25,
    this.remainingSeconds = 25 * 60,
  });

  final FocusPhase phase;
  final int selectedMinutes;
  final int remainingSeconds;

  /// Fraction of the session that has elapsed, 0..1.
  double get progress {
    final total = selectedMinutes * 60;
    if (total <= 0) return 0;
    return (1 - remainingSeconds / total).clamp(0.0, 1.0);
  }

  FocusTimerState copyWith({
    FocusPhase? phase,
    int? selectedMinutes,
    int? remainingSeconds,
  }) {
    return FocusTimerState(
      phase: phase ?? this.phase,
      selectedMinutes: selectedMinutes ?? this.selectedMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}

final focusTimerProvider =
    NotifierProvider<FocusTimerController, FocusTimerState>(
  FocusTimerController.new,
);

/// Drives the countdown. A session is logged only when the timer reaches
/// zero on its own — resetting mid-session logs nothing.
class FocusTimerController extends Notifier<FocusTimerState> {
  Timer? _ticker;
  DateTime? _startedAt;

  @override
  FocusTimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const FocusTimerState();
  }

  void selectMinutes(int minutes) {
    if (state.phase == FocusPhase.running) return;
    _ticker?.cancel();
    state = FocusTimerState(
      selectedMinutes: minutes,
      remainingSeconds: minutes * 60,
    );
  }

  void start() {
    if (state.phase != FocusPhase.idle && state.phase != FocusPhase.paused) {
      return;
    }
    if (state.phase == FocusPhase.idle) {
      _startedAt = DateTime.now();
    }
    state = state.copyWith(phase: FocusPhase.running);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    if (state.phase != FocusPhase.running) return;
    _ticker?.cancel();
    state = state.copyWith(phase: FocusPhase.paused);
  }

  /// Cancels the session without logging anything.
  void reset() {
    _ticker?.cancel();
    _startedAt = null;
    state = FocusTimerState(
      selectedMinutes: state.selectedMinutes,
      remainingSeconds: state.selectedMinutes * 60,
    );
  }

  /// Leaves the completion state, ready for another session.
  void acknowledge() => reset();

  void _tick() {
    final remaining = state.remainingSeconds - 1;
    if (remaining > 0) {
      state = state.copyWith(remainingSeconds: remaining);
      return;
    }
    _ticker?.cancel();
    final minutes = state.selectedMinutes;
    final startedAt =
        _startedAt ?? DateTime.now().subtract(Duration(minutes: minutes));
    _startedAt = null;
    state = state.copyWith(
      phase: FocusPhase.completed,
      remainingSeconds: 0,
    );
    unawaited(
      ref
          .read(focusSessionsProvider.notifier)
          .logSession(minutes: minutes, startedAt: startedAt),
    );
  }
}
