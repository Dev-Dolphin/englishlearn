import 'package:english_app/features/lesson/data/lesson_repository.dart';
import 'package:english_app/features/lesson/domain/quiz_question.dart';
import 'package:english_app/features/vocabulary_srs/domain/flashcard_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SM-2 Spaced Repetition Algorithm Tests', () {
    final baseTime = DateTime(2026, 11, 25, 10, 0);
    final initialCard = FlashcardEntity(
      id: 'test_1',
      word: 'Resilient',
      ipa: '/rɪˈzɪliənt/',
      partOfSpeech: 'Adjective',
      vietnameseMeaning: 'Kiên cường',
      exampleSentence: 'A resilient system recovers quickly.',
      topic: 'Tech',
      nextReviewDate: baseTime,
    );

    test('Grading Easy on first review schedules 3 days ahead and boosts EF', () {
      final updated = initialCard.review(SrsGrade.easy, now: baseTime);

      expect(updated.repetition, 1);
      expect(updated.intervalDays, 3);
      expect(updated.easeFactor, closeTo(2.65, 0.01));
      expect(
        updated.nextReviewDate,
        baseTime.add(const Duration(days: 3)),
      );
    });

    test('Grading Again resets repetition to 0 and schedules 1 day ahead', () {
      final firstReview = initialCard.review(SrsGrade.good, now: baseTime);
      final forgotten = firstReview.review(SrsGrade.again, now: baseTime);

      expect(forgotten.repetition, 0);
      expect(forgotten.intervalDays, 1);
      expect(forgotten.easeFactor, lessThan(firstReview.easeFactor));
    });

    test('Masked Word Challenge generates 1-3 hint letter indices by CEFR tier', () {
      final c1Hints = initialCard.initialHintIndices(cefrTier: 'C1-C2');
      final b1Hints = initialCard.initialHintIndices(cefrTier: 'B1-B2');
      final a1Hints = initialCard.initialHintIndices(cefrTier: 'A1-A2');

      expect(c1Hints.length, 1);
      expect(b1Hints.length, 2);
      expect(a1Hints.length, 3);
      expect(c1Hints.contains(0), isTrue);
    });
  });

  group('Polymorphic Lesson Quiz Repository Tests', () {
    test('Lesson returns all 5 polymorphic question types', () {
      final repo = LessonRepository();
      final questions = repo.getQuestionsForLesson('lesson_1_1');

      expect(questions.length, 5);
      expect(questions[0], isA<MultipleChoiceQuestion>());
      expect(questions[1], isA<FillInTheBlankQuestion>());
      expect(questions[2], isA<SentenceOrderingQuestion>());
      expect(questions[3], isA<ListeningDictationQuestion>());
      expect(questions[4], isA<SpeakingPronunciationQuestion>());
    });
  });
}
