import 'package:cyberpath/features/content/data/content_repository.dart';
import 'package:cyberpath/features/content/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every lesson has unique block ids and valid interactive blocks', () {
    final ids = <String>{};
    for (final l in kAllLessons) {
      expect(l.blocks, isNotEmpty);
      for (final b in l.blocks) {
        expect(ids.add(b.id), isTrue, reason: 'duplicate block id ${b.id}');
        if (b.type == BlockType.multipleChoice) {
          expect(b.answerIndex, inInclusiveRange(0, b.options.length - 1));
        }
        if (b.type == BlockType.ordering) expect(b.items.toSet().length, b.items.length);
        if (b.type == BlockType.matching) expect(b.pairs.values.toSet().length, b.pairs.length);
      }
    }
  });

  test('skills reference real lessons and flashcard ids are unique', () {
    for (final s in kSkills) {
      for (final id in s.lessonIds) {
        expect(lessonById(id), isNotNull);
      }
    }
    expect(kFlashcards.map((c) => c.id).toSet().length, kFlashcards.length);
  });

  test('quick quiz only contains multiple choice and search works', () {
    final q = buildQuickQuiz();
    expect(q.blocks.every((b) => b.type == BlockType.multipleChoice), isTrue);
    expect(searchContent('salt'), isNotEmpty);
    expect(searchContent(''), isEmpty);
  });
}
