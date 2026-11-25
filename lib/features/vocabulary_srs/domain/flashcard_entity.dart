import 'package:equatable/equatable.dart';

/// User recall rating after flipping a flashcard in Spaced Repetition (SM-2 / FSRS).
enum SrsGrade {
  again(0, 'Quên (Again)'),
  hard(1, 'Khó (Hard)'),
  good(2, 'Nhớ (Good)'),
  easy(3, 'Dễ (Easy)');

  final int quality;
  final String label;
  const SrsGrade(this.quality, this.label);
}

class FlashcardEntity extends Equatable {
  final String id;
  final String word;
  final String ipa;
  final String cefr;
  final String partOfSpeech;
  final String vietnameseMeaning;
  final String exampleSentence;
  final String topic;

  // Deep linguistic annotations for Post-Answer Reveal in Word Challenge
  final String grammarNote;
  final String usageTip;
  final List<String> collocations;
  final String wordFamily;
  final List<String> synonyms;
  final List<String> antonyms;

  // SM-2 Spaced Repetition parameters
  final int repetition;
  final double easeFactor;
  final int intervalDays;
  final DateTime nextReviewDate;

  const FlashcardEntity({
    required this.id,
    required this.word,
    required this.ipa,
    this.cefr = 'B1',
    required this.partOfSpeech,
    required this.vietnameseMeaning,
    required this.exampleSentence,
    required this.topic,
    this.grammarNote = 'Sử dụng đúng vị trí từ loại và giới từ đi kèm trong câu.',
    this.usageTip = 'Áp dụng phổ biến trong giao tiếp công việc và bài thi quốc tế.',
    this.collocations = const [],
    this.wordFamily = '',
    this.synonyms = const [],
    this.antonyms = const [],
    this.repetition = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    required this.nextReviewDate,
  });

  bool isDue(DateTime now) => !nextReviewDate.isAfter(now);

  /// Generates initial revealed character indices (1-2 letters) based on CEFR difficulty.
  Set<int> initialHintIndices({required String cefrTier}) {
    final letterPositions = <int>[];
    for (var i = 0; i < word.length; i++) {
      if (RegExp(r'[a-zA-Z]').hasMatch(word[i])) {
        letterPositions.add(i);
      }
    }
    if (letterPositions.isEmpty) return {};

    final revealed = <int>{letterPositions.first};
    if (cefrTier != 'C1-C2' && letterPositions.length >= 6) {
      revealed.add(letterPositions[(letterPositions.length * 0.6).floor()]);
    }
    if (cefrTier == 'A1-A2' && letterPositions.length >= 9) {
      revealed.add(letterPositions.last);
    }
    return revealed;
  }

  /// Applies the SuperMemo SM-2 algorithm to schedule the next review interval.
  FlashcardEntity review(SrsGrade grade, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    int newRepetition = repetition;
    int newInterval = intervalDays;
    double newEase = easeFactor;

    if (grade == SrsGrade.again) {
      newRepetition = 0;
      newInterval = 1;
      newEase = (easeFactor - 0.2).clamp(1.3, 3.0);
    } else {
      newRepetition = repetition + 1;
      if (newRepetition == 1) {
        newInterval = grade == SrsGrade.easy ? 3 : 1;
      } else if (newRepetition == 2) {
        newInterval = grade == SrsGrade.easy ? 7 : 4;
      } else {
        final multiplier = switch (grade) {
          SrsGrade.hard => 1.2,
          SrsGrade.good => easeFactor,
          SrsGrade.easy => easeFactor * 1.3,
          SrsGrade.again => 1.0,
        };
        newInterval = (intervalDays * multiplier).round().clamp(1, 365);
      }

      final delta = switch (grade) {
        SrsGrade.hard => -0.15,
        SrsGrade.good => 0.0,
        SrsGrade.easy => 0.15,
        SrsGrade.again => -0.2,
      };
      newEase = (easeFactor + delta).clamp(1.3, 3.0);
    }

    return copyWith(
      repetition: newRepetition,
      easeFactor: double.parse(newEase.toStringAsFixed(2)),
      intervalDays: newInterval,
      nextReviewDate: currentTime.add(Duration(days: newInterval)),
    );
  }

  FlashcardEntity copyWith({
    String? id,
    String? word,
    String? ipa,
    String? cefr,
    String? partOfSpeech,
    String? vietnameseMeaning,
    String? exampleSentence,
    String? topic,
    String? grammarNote,
    String? usageTip,
    List<String>? collocations,
    String? wordFamily,
    List<String>? synonyms,
    List<String>? antonyms,
    int? repetition,
    double? easeFactor,
    int? intervalDays,
    DateTime? nextReviewDate,
  }) {
    return FlashcardEntity(
      id: id ?? this.id,
      word: word ?? this.word,
      ipa: ipa ?? this.ipa,
      cefr: cefr ?? this.cefr,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      vietnameseMeaning: vietnameseMeaning ?? this.vietnameseMeaning,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      topic: topic ?? this.topic,
      grammarNote: grammarNote ?? this.grammarNote,
      usageTip: usageTip ?? this.usageTip,
      collocations: collocations ?? this.collocations,
      wordFamily: wordFamily ?? this.wordFamily,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      repetition: repetition ?? this.repetition,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'ipa': ipa,
        'cefr': cefr,
        'partOfSpeech': partOfSpeech,
        'vietnameseMeaning': vietnameseMeaning,
        'exampleSentence': exampleSentence,
        'topic': topic,
        'grammarNote': grammarNote,
        'usageTip': usageTip,
        'collocations': collocations,
        'wordFamily': wordFamily,
        'synonyms': synonyms,
        'antonyms': antonyms,
        'repetition': repetition,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'nextReviewDate': nextReviewDate.toIso8601String(),
      };

  factory FlashcardEntity.fromJson(Map<String, dynamic> json) {
    return FlashcardEntity(
      id: json['id'] as String,
      word: json['word'] as String,
      ipa: json['ipa'] as String,
      cefr: json['cefr'] as String? ?? 'B1',
      partOfSpeech: json['partOfSpeech'] as String,
      vietnameseMeaning: json['vietnameseMeaning'] as String,
      exampleSentence: json['exampleSentence'] as String,
      topic: json['topic'] as String,
      grammarNote: json['grammarNote'] as String? ??
          'Sử dụng đúng vị trí từ loại và giới từ đi kèm trong câu.',
      usageTip: json['usageTip'] as String? ??
          'Áp dụng phổ biến trong giao tiếp công việc và bài thi quốc tế.',
      collocations: (json['collocations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      wordFamily: json['wordFamily'] as String? ?? '',
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      antonyms: (json['antonyms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      repetition: json['repetition'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: json['intervalDays'] as int? ?? 0,
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        word,
        ipa,
        cefr,
        partOfSpeech,
        vietnameseMeaning,
        exampleSentence,
        topic,
        grammarNote,
        usageTip,
        collocations,
        wordFamily,
        synonyms,
        antonyms,
        repetition,
        easeFactor,
        intervalDays,
        nextReviewDate,
      ];
}
