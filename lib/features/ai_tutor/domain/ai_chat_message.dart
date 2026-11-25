import 'package:equatable/equatable.dart';

class AiChatMessage extends Equatable {
  final String id;
  final bool isUser;
  final String text;
  final String? vietnameseTranslation;
  final String? grammarCorrection;
  final List<String> suggestions;
  final DateTime timestamp;

  const AiChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.vietnameseTranslation,
    this.grammarCorrection,
    this.suggestions = const [],
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        isUser,
        text,
        vietnameseTranslation,
        grammarCorrection,
        suggestions,
        timestamp,
      ];
}

class RoleplayScenario extends Equatable {
  final String id;
  final String title;
  final String roleDescription;
  final String targetCefr;
  final List<String> targetVocabulary;
  final String initialAiGreeting;

  const RoleplayScenario({
    required this.id,
    required this.title,
    required this.roleDescription,
    required this.targetCefr,
    required this.targetVocabulary,
    required this.initialAiGreeting,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        roleDescription,
        targetCefr,
        targetVocabulary,
        initialAiGreeting,
      ];
}
