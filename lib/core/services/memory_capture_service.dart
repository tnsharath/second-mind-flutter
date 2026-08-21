import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/memory/application/memory_providers.dart';
import '../../features/memory/domain/memory_item.dart';

/// Signature for the side effect that persists a captured memory.
typedef CreateMemory = Future<MemoryItem> Function({
  required String title,
  required String description,
  MemoryCategory category,
  bool isImportant,
});

/// Extracts memory-worthy snippets from user messages and persists them.
///
/// Capture is best-effort and asynchronous: it never blocks the chat reply.
/// Trigger phrases include "remember that", "note this", "don't forget",
/// "keep in mind", and leading markers like "note:" or "remember:".
class MemoryCaptureService {
  MemoryCaptureService(this._create);

  factory MemoryCaptureService.withRef(Ref ref) =>
      MemoryCaptureService(ref.read(memoriesProvider.notifier).create);

  final CreateMemory _create;

  /// Returns true if [text] looks like a capture request.
  bool shouldCapture(String text) => MemoryCaptureLogic.shouldCapture(text);

  /// Extracts and persists a memory from [text].
  ///
  /// The returned title/description are simple heuristics; later phases can
  /// call the backend LLM for richer summarization.
  Future<MemoryItem?> capture(String text) async {
    final normalized = MemoryCaptureLogic.normalize(text);
    if (normalized.isEmpty) return null;

    final (title, description) = MemoryCaptureLogic.split(normalized);
    final effectiveDescription =
        description.isEmpty ? title : description;

    try {
      return await _create(
        title: title,
        description: effectiveDescription,
        category: MemoryCaptureLogic.categorize(text),
      );
    } catch (_) {
      // Capture is best-effort; failures should not break chat.
      return null;
    }
  }
}

/// Pure, side-effect-free helpers for deciding what to remember and how to
/// present it. Kept separate from [MemoryCaptureService] so it can be unit
/// tested without Riverpod.
class MemoryCaptureLogic {
  const MemoryCaptureLogic._();

  static const List<String> _triggers = [
    'remember that',
    'remember:',
    'note that',
    'note this',
    'note:',
    "don't forget",
    "don't let me forget",
    'keep in mind',
    'make sure to remember',
  ];

  static const List<String> _stopWords = [
    'please',
    'can you',
    'could you',
    'i want you to',
    'make sure',
  ];

  /// Returns true if [text] looks like a capture request.
  static bool shouldCapture(String text) {
    final lower = text.toLowerCase();
    return _triggers.any((t) => lower.contains(t));
  }

  /// Strips trigger phrases and polite wrappers from [text].
  static String normalize(String text) {
    var result = text.trim();
    final lower = result.toLowerCase();

    for (final trigger in _triggers) {
      if (lower.startsWith(trigger)) {
        result = result.substring(trigger.length).trim();
        break;
      }
      if (lower.contains(trigger)) {
        final idx = lower.indexOf(trigger);
        result = result.substring(idx + trigger.length).trim();
        break;
      }
    }

    for (final stop in _stopWords) {
      if (result.toLowerCase().startsWith(stop)) {
        result = result.substring(stop.length).trim();
      }
    }

    // Remove trailing punctuation.
    if (result.isNotEmpty && ".!?,".contains(result[result.length - 1])) {
      result = result.substring(0, result.length - 1);
    }

    return result.trim();
  }

  /// Splits [text] into a short title and longer description.
  static (String, String) split(String text) {
    const maxTitleWords = 8;
    final words = text.split(' ');
    if (words.length <= maxTitleWords) {
      return (text, '');
    }
    final titleWords = words.take(maxTitleWords).join(' ');
    final description = words.skip(maxTitleWords).join(' ');
    return ('$titleWords…', description);
  }

  static MemoryCategory categorize(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('birthday') ||
        lower.contains('meeting') ||
        lower.contains('event') ||
        lower.contains('appointment')) {
      return MemoryCategory.event;
    }
    if (lower.contains('goal') ||
        lower.contains('want to') ||
        lower.contains('need to')) {
      return MemoryCategory.goal;
    }
    if (lower.contains('prefer') ||
        lower.contains('like') ||
        lower.contains("don't like")) {
      return MemoryCategory.preference;
    }
    if (lower.contains('milestone') ||
        lower.contains('achieved') ||
        lower.contains('completed')) {
      return MemoryCategory.milestone;
    }
    return MemoryCategory.note;
  }
}
