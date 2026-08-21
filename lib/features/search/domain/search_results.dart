import 'package:freezed_annotation/freezed_annotation.dart';

import '../../conversation/domain/conversation.dart';
import '../../goals/domain/goal.dart';
import '../../memory/domain/memory_item.dart';

part 'search_results.freezed.dart';
part 'search_results.g.dart';

/// Minimal note model for universal search results.
///
/// Deliberately defined locally (instead of importing features/notes) so
/// this feature does not depend on files owned by another workstream.
@freezed
class SearchNote with _$SearchNote {
  const factory SearchNote({
    required String id,
    required String text,
    @Default('note') String kind,
    DateTime? createdAt,
  }) = _SearchNote;

  factory SearchNote.fromJson(Map<String, dynamic> json) =>
      _$SearchNoteFromJson(json);
}

/// Grouped results returned by GET /search.
@freezed
class SearchResults with _$SearchResults {
  const factory SearchResults({
    @Default([]) List<MemoryItem> memories,
    @Default([]) List<Goal> goals,
    @Default([]) List<Conversation> conversations,
    @Default([]) List<SearchNote> notes,
  }) = _SearchResults;

  const SearchResults._();

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      memories: _parseList(json['memories'], MemoryItem.fromJson),
      goals: _parseList(json['goals'], Goal.fromJson),
      conversations: _parseList(json['conversations'], Conversation.fromJson),
      notes: _parseList(json['notes'], SearchNote.fromJson),
    );
  }

  bool get isEmpty =>
      memories.isEmpty && goals.isEmpty && conversations.isEmpty && notes.isEmpty;
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
