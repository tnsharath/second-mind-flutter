import 'package:aura/core/services/memory_capture_service.dart';
import 'package:aura/features/memory/domain/memory_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemoryCaptureLogic.shouldCapture', () {
    test('detects "remember that"', () {
      expect(
        MemoryCaptureLogic.shouldCapture('remember that I prefer tea'),
        isTrue,
      );
    });

    test('detects "note:" prefix', () {
      expect(
        MemoryCaptureLogic.shouldCapture('note: book flight by Friday'),
        isTrue,
      );
    });

    test('detects "don\'t forget"', () {
      expect(
        MemoryCaptureLogic.shouldCapture("don't forget mom's birthday"),
        isTrue,
      );
    });

    test('ignores normal chat', () {
      expect(
        MemoryCaptureLogic.shouldCapture('what is the weather today?'),
        isFalse,
      );
    });

    test('is case-insensitive', () {
      expect(
        MemoryCaptureLogic.shouldCapture('REMEMBER THAT I like jazz'),
        isTrue,
      );
    });
  });

  group('MemoryCaptureLogic.normalize', () {
    test('strips leading trigger phrase', () {
      expect(
        MemoryCaptureLogic.normalize('remember that I prefer tea'),
        'I prefer tea',
      );
    });

    test('stops at first trigger when multiple present', () {
      expect(
        MemoryCaptureLogic.normalize('hey, remember that I prefer tea'),
        'I prefer tea',
      );
    });

    test('strips polite wrappers', () {
      expect(
        MemoryCaptureLogic.normalize('please remember that I prefer tea'),
        'I prefer tea',
      );
    });

    test('trims trailing punctuation', () {
      expect(
        MemoryCaptureLogic.normalize('note: call Sarah!'),
        'call Sarah',
      );
    });
  });

  group('MemoryCaptureLogic.split', () {
    test('short text becomes title-only', () {
      expect(
        MemoryCaptureLogic.split('I prefer tea'),
        ('I prefer tea', ''),
      );
    });

    test('long text splits into title and description', () {
      const text =
          'I prefer to start my day with a short walk and then drink tea';
      final (title, description) = MemoryCaptureLogic.split(text);
      expect(title, 'I prefer to start my day with a short walk…');
      expect(description, 'and then drink tea');
    });
  });

  group('MemoryCaptureLogic.categorize', () {
    test('event keywords', () {
      expect(
        MemoryCaptureLogic.categorize('remember my meeting at 3'),
        MemoryCategory.event,
      );
    });

    test('goal keywords', () {
      expect(
        MemoryCaptureLogic.categorize('note: I want to run a 5k'),
        MemoryCategory.goal,
      );
    });

    test('preference keywords', () {
      expect(
        MemoryCaptureLogic.categorize('remember that I prefer tea'),
        MemoryCategory.preference,
      );
    });

    test('default is note', () {
      expect(
        MemoryCaptureLogic.categorize('remember the book title'),
        MemoryCategory.note,
      );
    });
  });

  group('MemoryCaptureService.capture', () {
    test('returns null for text without trigger', () async {
      final service = MemoryCaptureService(_fakeCreate);
      final result = await service.capture('hello there');
      expect(result, isNull);
    });

    test('persists a memory when trigger is present', () async {
      final captured = <Map<String, dynamic>>[];
      Future<MemoryItem> create({
        required String title,
        required String description,
        MemoryCategory category = MemoryCategory.note,
        bool isImportant = false,
      }) async {
        captured.add({
          'title': title,
          'description': description,
          'category': category,
        });
        return MemoryItem(
          id: 'm1',
          title: title,
          description: description,
          category: category,
          timestamp: DateTime.now(),
        );
      }

      final service = MemoryCaptureService(create);
      final result = await service.capture('remember that I prefer tea');

      expect(result, isNotNull);
      expect(captured, hasLength(1));
      expect(captured.first['title'], 'I prefer tea');
      expect(captured.first['description'], 'I prefer tea');
      expect(captured.first['category'], MemoryCategory.preference);
    });

    test('swallows create failures gracefully', () async {
      Future<MemoryItem> failingCreate({
        required String title,
        required String description,
        MemoryCategory category = MemoryCategory.note,
        bool isImportant = false,
      }) async {
        throw Exception('network down');
      }

      final service = MemoryCaptureService(failingCreate);
      final result = await service.capture('note: important thing');
      expect(result, isNull);
    });
  });
}

Future<MemoryItem> _fakeCreate({
  required String title,
  required String description,
  MemoryCategory category = MemoryCategory.note,
  bool isImportant = false,
}) async {
  return MemoryItem(
    id: 'fake',
    title: title,
    description: description,
    category: category,
    timestamp: DateTime.now(),
  );
}
