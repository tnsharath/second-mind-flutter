import 'package:freezed_annotation/freezed_annotation.dart';

part 'captured_item.freezed.dart';
part 'captured_item.g.dart';

@freezed
class CapturedItem with _$CapturedItem {
  const factory CapturedItem({
    required String category,
    required String title,
    String? detail,
    required String entityType,
    int? entityId,
  }) = _CapturedItem;

  factory CapturedItem.fromJson(Map<String, dynamic> json) =>
      _$CapturedItemFromJson(json);
}

extension CapturedItemX on CapturedItem {
  String get displayBadge {
    switch (category) {
      case 'gratitude':
        return '✨ Saved to Gratitude';
      case 'journal':
        return '✨ Logged to Journal';
      case 'todo':
      case 'reminder':
        return '✨ Added to Reminders';
      case 'schedule':
        return '✨ Added to Calendar';
      case 'goal':
        return '✨ Created Goal';
      case 'memory':
        return '✨ Saved to Memory';
      default:
        return '✨ Auto-captured';
    }
  }

  String get targetRoute {
    switch (category) {
      case 'gratitude':
      case 'journal':
        return '/journal';
      case 'todo':
      case 'reminder':
        return '/notes';
      case 'schedule':
        return '/calendar';
      case 'goal':
        return '/goals';
      case 'memory':
        return '/memory';
      default:
        return '/journal';
    }
  }
}
