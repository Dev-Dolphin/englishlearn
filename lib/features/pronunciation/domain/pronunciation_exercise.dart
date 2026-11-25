import 'package:equatable/equatable.dart';

class WordPronunciationScore extends Equatable {
  final String word;
  final String ipa;
  final int accuracyPercent;
  final String tip;

  const WordPronunciationScore({
    required this.word,
    required this.ipa,
    required this.accuracyPercent,
    required this.tip,
  });

  @override
  List<Object?> get props => [word, ipa, accuracyPercent, tip];
}

class PronunciationDrill extends Equatable {
  final String id;
  final String sentence;
  final String fullIpa;
  final String vietnameseMeaning;
  final List<WordPronunciationScore> wordBreakdown;

  const PronunciationDrill({
    required this.id,
    required this.sentence,
    required this.fullIpa,
    required this.vietnameseMeaning,
    required this.wordBreakdown,
  });

  int get overallScore {
    if (wordBreakdown.isEmpty) return 0;
    final sum = wordBreakdown.fold<int>(
      0,
      (acc, w) => acc + w.accuracyPercent,
    );
    return (sum / wordBreakdown.length).round();
  }

  @override
  List<Object?> get props => [
        id,
        sentence,
        fullIpa,
        vietnameseMeaning,
        wordBreakdown,
      ];
}
