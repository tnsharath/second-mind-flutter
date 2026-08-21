import '../../../core/services/api_client.dart';
import '../domain/note.dart';
import '../domain/notes_repository.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiNotesRepository implements NotesRepository {
  ApiNotesRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Note>> getNotes() async {
    final response = await _client.get<List<dynamic>>('/notes');
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => Note.fromJson(_normalizeIds(json)))
        .toList();
  }

  @override
  Future<Note> createNote({
    required String text,
    NoteKind kind = NoteKind.note,
    DateTime? remindAt,
    String? projectId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/notes',
      body: {
        'text': text,
        'kind': kind.name,
        if (remindAt != null) 'remindAt': remindAt.toIso8601String(),
        if (projectId != null) 'projectId': _toIntId(projectId),
      },
    );
    return Note.fromJson(_normalizeIds(response.data ?? const {}));
  }

  @override
  Future<Note> updateNote(Note note) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/notes/${note.id}',
      body: {
        'text': note.text,
        'kind': note.kind.name,
        'remindAt': note.remindAt?.toIso8601String(),
        'done': note.done,
        if (note.projectId != null) 'projectId': _toIntId(note.projectId!),
      },
    );
    return Note.fromJson(_normalizeIds(response.data ?? const {}));
  }

  @override
  Future<void> deleteNote(String id) async {
    await _client.delete<void>('/notes/$id');
  }
}

/// Backend ids are integers; the Dart models use String ids.
Map<String, dynamic> _normalizeIds(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
      if (json['projectId'] != null) 'projectId': json['projectId'].toString(),
    };

/// Sends numeric ids back to the backend as ints when possible.
Object _toIntId(String id) => int.tryParse(id) ?? id;
