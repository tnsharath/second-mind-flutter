import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_detail.freezed.dart';
part 'project_detail.g.dart';

/// Minimal note model for project detail.
///
/// Deliberately defined locally (instead of importing features/notes) so
/// this feature does not depend on files owned by another workstream.
@freezed
class ProjectNote with _$ProjectNote {
  const factory ProjectNote({
    required String id,
    required String text,
    @Default('note') String kind,
    DateTime? createdAt,
    @Default(false) bool done,
  }) = _ProjectNote;

  factory ProjectNote.fromJson(Map<String, dynamic> json) =>
      _$ProjectNoteFromJson(json);
}

/// Minimal goal model for project detail (no features/goals import needed
/// beyond the shared id contract; kept local for symmetry with ProjectNote).
@freezed
class ProjectGoal with _$ProjectGoal {
  const factory ProjectGoal({
    required String id,
    required String title,
    @Default(false) bool isCompleted,
    @Default(0) int progress,
  }) = _ProjectGoal;

  factory ProjectGoal.fromJson(Map<String, dynamic> json) =>
      _$ProjectGoalFromJson(json);
}

/// GET /projects/{id} payload: the project plus its linked items.
@freezed
class ProjectDetail with _$ProjectDetail {
  const factory ProjectDetail({
    required String id,
    required String name,
    String? description,
    required DateTime createdAt,
    @Default([]) List<ProjectNote> notes,
    @Default([]) List<ProjectGoal> goals,
  }) = _ProjectDetail;

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    return ProjectDetail(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      notes: _parseList(json['notes'], ProjectNote.fromJson),
      goals: _parseList(json['goals'], ProjectGoal.fromJson),
    );
  }
}

List<T> _parseList<T>(
  Object? raw,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((json) => fromJson(_normalizeId(json)))
      .toList();
}

/// Backend ids are integers; the Dart models use String ids.
Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };
