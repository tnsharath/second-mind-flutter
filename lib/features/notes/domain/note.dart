import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

enum NoteKind { note, idea }

@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String text,
    @Default(NoteKind.note) NoteKind kind,
    DateTime? remindAt,
    @Default(false) bool done,
    required DateTime createdAt,
    String? projectId,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
