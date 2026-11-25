import 'package:equatable/equatable.dart';

class LessonVocabItem extends Equatable {
  final String word;
  final String ipa;
  final String meaning;
  final String example;

  const LessonVocabItem({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
  });

  @override
  List<Object?> get props => [word, ipa, meaning, example];
}

class LessonNode extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final int xpReward;
  final String grammarNote;
  final List<LessonVocabItem> keyVocab;
  final bool isCompleted;
  final bool isLocked;

  const LessonNode({
    required this.id,
    required this.title,
    required this.subtitle,
    this.xpReward = 25,
    this.grammarNote = '',
    this.keyVocab = const [],
    this.isCompleted = false,
    this.isLocked = false,
  });

  LessonNode copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? xpReward,
    String? grammarNote,
    List<LessonVocabItem>? keyVocab,
    bool? isCompleted,
    bool? isLocked,
  }) {
    return LessonNode(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      xpReward: xpReward ?? this.xpReward,
      grammarNote: grammarNote ?? this.grammarNote,
      keyVocab: keyVocab ?? this.keyVocab,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        xpReward,
        grammarNote,
        keyVocab,
        isCompleted,
        isLocked,
      ];
}

class LearningUnit extends Equatable {
  final String id;
  final int unitNumber;
  final String title;
  final String description;
  final String cefrLevel;
  final List<LessonNode> lessons;

  const LearningUnit({
    required this.id,
    required this.unitNumber,
    required this.title,
    required this.description,
    required this.cefrLevel,
    required this.lessons,
  });

  double get completionProgress {
    if (lessons.isEmpty) return 0;
    final doneCount = lessons.where((l) => l.isCompleted).length;
    return doneCount / lessons.length;
  }

  LearningUnit copyWith({
    List<LessonNode>? lessons,
  }) {
    return LearningUnit(
      id: id,
      unitNumber: unitNumber,
      title: title,
      description: description,
      cefrLevel: cefrLevel,
      lessons: lessons ?? this.lessons,
    );
  }

  @override
  List<Object?> get props => [
        id,
        unitNumber,
        title,
        description,
        cefrLevel,
        lessons,
      ];
}
