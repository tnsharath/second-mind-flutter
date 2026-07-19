import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory_item.freezed.dart';
part 'memory_item.g.dart';

enum MemoryCategory { event, goal, preference, note, milestone }

@freezed
class MemoryItem with _$MemoryItem {
  const factory MemoryItem({
    required String id,
    required String title,
    required String description,
    required MemoryCategory category,
    required DateTime timestamp,
    @Default(false) bool isImportant,
  }) = _MemoryItem;

  factory MemoryItem.fromJson(Map<String, dynamic> json) =>
      _$MemoryItemFromJson(json);
}
