import 'package:equatable/equatable.dart';
import '../../vocabulary_srs/domain/flashcard_entity.dart';

class PhotoVocabEntry extends Equatable {
  final String id;
  final String title;
  final String? localImagePath;
  final String? remoteImageUrl;
  final DateTime uploadedAt;
  final String ocrText;
  final List<FlashcardEntity> words;

  const PhotoVocabEntry({
    required this.id,
    required this.title,
    this.localImagePath,
    this.remoteImageUrl,
    required this.uploadedAt,
    required this.ocrText,
    required this.words,
  });

  PhotoVocabEntry copyWith({
    String? title,
    String? localImagePath,
    String? remoteImageUrl,
    String? ocrText,
    List<FlashcardEntity>? words,
  }) {
    return PhotoVocabEntry(
      id: id,
      title: title ?? this.title,
      localImagePath: localImagePath ?? this.localImagePath,
      remoteImageUrl: remoteImageUrl ?? this.remoteImageUrl,
      uploadedAt: uploadedAt,
      ocrText: ocrText ?? this.ocrText,
      words: words ?? this.words,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'localImagePath': localImagePath,
        'remoteImageUrl': remoteImageUrl,
        'uploadedAt': uploadedAt.toIso8601String(),
        'ocrText': ocrText,
        'words': words.map((w) => w.toJson()).toList(),
      };

  factory PhotoVocabEntry.fromJson(Map<String, dynamic> json) {
    final rawWords = (json['words'] as List<dynamic>? ?? []);
    return PhotoVocabEntry(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Ảnh chụp từ vựng',
      localImagePath: json['localImagePath'] as String?,
      remoteImageUrl: (json['remoteImageUrl'] ?? json['imageUrl']) as String?,
      uploadedAt: DateTime.tryParse(json['uploadedAt'] as String? ?? '') ??
          DateTime.now(),
      ocrText: json['ocrText'] as String? ?? '',
      words: rawWords.map((item) {
        final map = (item as Map<dynamic, dynamic>).cast<String, dynamic>();
        return FlashcardEntity.fromJson({
          ...map,
          'nextReviewDate':
              map['nextReviewDate'] ?? DateTime.now().toIso8601String(),
        });
      }).toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        localImagePath,
        remoteImageUrl,
        uploadedAt,
        ocrText,
        words,
      ];
}
