import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_notes_repository.dart';
import '../data/mock_notes_repository.dart';
import '../domain/note.dart';
import '../domain/notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => Env.useMockApi
      ? MockNotesRepository()
      : ApiNotesRepository(ref.watch(apiClientProvider)),
);

final notesProvider = AsyncNotifierProvider<NotesController, List<Note>>(
  NotesController.new,
);

class NotesController extends AsyncNotifier<List<Note>> {
  NotesRepository get _repository => ref.read(notesRepositoryProvider);

  @override
  Future<List<Note>> build() => _repository.getNotes();

  Future<void> add({
    required String text,
    NoteKind kind = NoteKind.note,
    DateTime? remindAt,
    String? projectId,
  }) async {
    final current = state.valueOrNull ?? const <Note>[];
    try {
      final created = await _repository.createNote(
        text: text,
        kind: kind,
        remindAt: remindAt,
        projectId: projectId,
      );
      state = AsyncData([created, ...current]);
      _syncReminder(created);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  /// Optimistic update with rollback on failure.
  Future<void> updateNote(Note note) async {
    final current = state.valueOrNull ?? const <Note>[];
    state = AsyncData([
      for (final n in current)
        if (n.id == note.id) note else n,
    ]);
    try {
      final updated = await _repository.updateNote(note);
      state = AsyncData([
        for (final n in state.valueOrNull ?? current)
          if (n.id == updated.id) updated else n,
      ]);
      _syncReminder(updated);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  Future<void> toggleDone(Note note) =>
      updateNote(note.copyWith(done: !note.done));

  /// Optimistic delete with rollback on failure.
  Future<void> delete(Note note) async {
    final current = state.valueOrNull ?? const <Note>[];
    state = AsyncData([
      for (final n in current)
        if (n.id != note.id) n,
    ]);
    try {
      await _repository.deleteNote(note.id);
      _cancelReminder(note);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  /// Schedules or clears the local notification tied to [note]'s reminder.
  void _syncReminder(Note note) {
    final notifications = ref.read(notificationServiceProvider);
    final remindAt = note.remindAt;
    if (remindAt != null && !note.done) {
      notifications.scheduleAt(
        id: _notificationId(note),
        at: remindAt,
        title: note.kind == NoteKind.idea ? 'Idea reminder' : 'Note reminder',
        body: note.text,
        alarm: true,
      );
    } else {
      _cancelReminder(note);
    }
  }

  void _cancelReminder(Note note) =>
      ref.read(notificationServiceProvider).cancel(_notificationId(note));

  /// Backend note ids are ints and double as notification ids; fall back
  /// to the String id's hashCode for non-numeric (e.g. mock) ids.
  static int _notificationId(Note note) =>
      int.tryParse(note.id) ?? note.id.hashCode;
}
