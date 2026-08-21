import 'note.dart';

abstract class NotesRepository {
  /// GET /notes
  Future<List<Note>> getNotes();

  /// POST /notes
  Future<Note> createNote({
    required String text,
    NoteKind kind,
    DateTime? remindAt,
    String? projectId,
  });

  /// PATCH /notes/{id}
  Future<Note> updateNote(Note note);

  /// DELETE /notes/{id}
  Future<void> deleteNote(String id);
}
