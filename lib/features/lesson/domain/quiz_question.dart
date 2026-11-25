import 'package:equatable/equatable.dart';

/// Dart 3 Sealed Class hierarchy representing Polymorphic Quiz Questions.
sealed class QuizQuestion extends Equatable {
  final String id;
  final String prompt;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.explanation,
  });

  @override
  List<Object?> get props => [id, prompt, explanation];
}

final class MultipleChoiceQuestion extends QuizQuestion {
  final List<String> options;
  final int correctIndex;

  const MultipleChoiceQuestion({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.options,
    required this.correctIndex,
  });

  @override
  List<Object?> get props => [...super.props, options, correctIndex];
}

final class FillInTheBlankQuestion extends QuizQuestion {
  final String sentenceWithBlank;
  final String correctAnswer;
  final List<String> wordBank;

  const FillInTheBlankQuestion({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.sentenceWithBlank,
    required this.correctAnswer,
    required this.wordBank,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        sentenceWithBlank,
        correctAnswer,
        wordBank,
      ];
}

final class SentenceOrderingQuestion extends QuizQuestion {
  final String vietnameseMeaning;
  final List<String> shuffledTokens;
  final List<String> correctOrder;

  const SentenceOrderingQuestion({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.vietnameseMeaning,
    required this.shuffledTokens,
    required this.correctOrder,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        vietnameseMeaning,
        shuffledTokens,
        correctOrder,
      ];
}

final class ListeningDictationQuestion extends QuizQuestion {
  final String audioText;
  final String ipaHint;

  const ListeningDictationQuestion({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.audioText,
    required this.ipaHint,
  });

  @override
  List<Object?> get props => [...super.props, audioText, ipaHint];
}

final class SpeakingPronunciationQuestion extends QuizQuestion {
  final String targetSentence;
  final String ipaTranscription;
  final String vietnameseTranslation;

  const SpeakingPronunciationQuestion({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.targetSentence,
    required this.ipaTranscription,
    required this.vietnameseTranslation,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        targetSentence,
        ipaTranscription,
        vietnameseTranslation,
      ];
}
