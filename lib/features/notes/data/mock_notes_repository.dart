import '../domain/note.dart';
import '../domain/notes_repository.dart';

/// Serves local dummy notes until the backend /notes endpoint exists.
class MockNotesRepository implements NotesRepository {
  static final List<Note> _notes = [
    Note(
      id: 'n1',
      text: 'Buy groceries for the weekend',
      kind: NoteKind.note,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Note(
      id: 'n2',
      text: 'Idea: weekly review ritual every Sunday evening',
      kind: NoteKind.idea,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Note(
      id: 'n3',
      text: 'Call the dentist to reschedule',
      kind: NoteKind.note,
      remindAt: DateTime.now().add(const Duration(hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static int _nextId = 100;

  @override
  Future<List<Note>> getNotes() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_notes);
  }

  @override
  Future<Note> createNote({
    required String text,
    NoteKind kind = NoteKind.note,
    DateTime? remindAt,
    String? projectId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final note = Note(
      id: '${_nextId++}',
      text: text,
      kind: kind,
      remindAt: remindAt,
      createdAt: DateTime.now(),
      projectId: projectId,
    );
    _notes.insert(0, note);
    return note;
  }

  @override
  Future<Note> updateNote(Note note) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    }
    return note;
  }

  @override
  Future<void> deleteNote(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _notes.removeWhere((n) => n.id == id);
  }
}
