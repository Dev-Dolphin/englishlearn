import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
import '../../vocabulary_srs/domain/flashcard_entity.dart';
import '../domain/photo_vocab_entry.dart';

class PhotoVaultState extends Equatable {
  final List<PhotoVocabEntry> photos;
  final Set<String> selectedWordIds;
  final bool autoSelectNewUploads;
  final bool isUploading;
  final String syncServerUrl;

  const PhotoVaultState({
    required this.photos,
    required this.selectedWordIds,
    this.autoSelectNewUploads = true,
    this.isUploading = false,
    this.syncServerUrl = 'http://localhost:3000',
  });

  List<FlashcardEntity> get selectedWords {
    final result = <FlashcardEntity>[];
    for (final p in photos) {
      for (final w in p.words) {
        if (selectedWordIds.contains(w.id)) {
          result.add(w);
        }
      }
    }
    return result;
  }

  int get totalVaultWords =>
      photos.fold<int>(0, (sum, p) => sum + p.words.length);

  PhotoVaultState copyWith({
    List<PhotoVocabEntry>? photos,
    Set<String>? selectedWordIds,
    bool? autoSelectNewUploads,
    bool? isUploading,
    String? syncServerUrl,
  }) {
    return PhotoVaultState(
      photos: photos ?? this.photos,
      selectedWordIds: selectedWordIds ?? this.selectedWordIds,
      autoSelectNewUploads: autoSelectNewUploads ?? this.autoSelectNewUploads,
      isUploading: isUploading ?? this.isUploading,
      syncServerUrl: syncServerUrl ?? this.syncServerUrl,
    );
  }

  @override
  List<Object?> get props => [
        photos,
        selectedWordIds,
        autoSelectNewUploads,
        isUploading,
        syncServerUrl,
      ];
}

class PhotoVaultNotifier extends Notifier<PhotoVaultState> {
  static const String _separateStorageKey = 'photo_vocab_separate_vault_v1';
  Timer? _livePollTimer;

  @override
  PhotoVaultState build() {
    final seed = _seedEntry();
    final seedIds = seed.words.map((w) => w.id).toSet();

    _loadFromSeparateStorage();
    _startContinuousSyncTimer();
    ref.onDispose(() => _livePollTimer?.cancel());

    return PhotoVaultState(
      photos: [seed],
      selectedWordIds: seedIds,
    );
  }

  PhotoVocabEntry _seedEntry() {
    final now = DateTime.now();
    return PhotoVocabEntry(
      id: 'photo_seed_1',
      title: 'Ảnh mẫu: Ghi chú IELTS & Công nghệ',
      uploadedAt: now,
      ocrText:
          'Sustainable innovation drives remarkable growth.\nStreamline: Tinh gọn tối ưu quy trình\nPrerequisite: Điều kiện tiên quyết',
      words: [
        FlashcardEntity(
          id: 'pv_seed_1',
          word: 'Sustainable',
          ipa: '/səˈsteɪnəbl/',
          cefr: 'B2',
          partOfSpeech: 'Adjective • B2',
          topic: '📸 Ghi chú IELTS & Công nghệ',
          vietnameseMeaning: 'Bền vững, thân thiện lâu dài',
          exampleSentence: 'Sustainable innovation drives remarkable growth.',
          grammarNote: 'sustainable development / growth / energy',
          usageTip: 'Trích xuất từ Kho Từ Ảnh riêng biệt.',
          collocations: const ['sustainable growth'],
          wordFamily: 'Sustainable (adj)',
          synonyms: const ['Viable', 'Eco-friendly'],
          nextReviewDate: now,
        ),
        FlashcardEntity(
          id: 'pv_seed_2',
          word: 'Streamline',
          ipa: '/ˈstriːmlaɪn/',
          cefr: 'C1',
          partOfSpeech: 'Verb • C1',
          topic: '📸 Ghi chú IELTS & Công nghệ',
          vietnameseMeaning: 'Tinh gọn tối ưu quy trình',
          exampleSentence: 'We need to streamline our daily workflow.',
          grammarNote: 'streamline workflow / operations',
          usageTip: 'Trích xuất trực tiếp từ ảnh chụp ghi chú.',
          collocations: const ['streamline workflow'],
          wordFamily: 'Streamline (v)',
          synonyms: const ['Optimize', 'Simplify'],
          nextReviewDate: now,
        ),
        FlashcardEntity(
          id: 'pv_seed_3',
          word: 'Prerequisite',
          ipa: '/ˌpriːˈrɛkwɪzɪt/',
          cefr: 'C1',
          partOfSpeech: 'Noun • C1',
          topic: '📸 Ghi chú IELTS & Công nghệ',
          vietnameseMeaning: 'Điều kiện tiên quyết',
          exampleSentence: 'Vocabulary is a prerequisite for fluent speaking.',
          grammarNote: 'a prerequisite FOR something',
          usageTip: 'Trích xuất trực tiếp từ ảnh chụp ghi chú.',
          collocations: const ['prerequisite for'],
          wordFamily: 'Prerequisite (n)',
          synonyms: const ['Requirement'],
          nextReviewDate: now,
        ),
      ],
    );
  }

  Future<void> _loadFromSeparateStorage() async {
    final storage = ref.read(localStorageServiceProvider);
    final rawList = await storage.getJsonList(_separateStorageKey);
    if (rawList.isEmpty) return;

    final loaded = rawList.map(PhotoVocabEntry.fromJson).toList();
    final ids = <String>{};
    for (final p in loaded) {
      for (final w in p.words) {
        ids.add(w.id);
      }
    }
    state = state.copyWith(photos: loaded, selectedWordIds: ids);
  }

  Future<void> _persistSeparateVault() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setJsonList(
      _separateStorageKey,
      state.photos.map((p) => p.toJson()).toList(),
    );
  }

  /// Continuously polls the local Photo Vault OCR Server (if reachable on Wi-Fi/Simulator)
  /// so new screenshots uploaded on PC/Web immediately appear on iOS too!
  void _startContinuousSyncTimer() {
    if (kIsWeb) return;
    _livePollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      syncWithRemoteVaultSilently();
    });
    syncWithRemoteVaultSilently();
  }

  void updateSyncServerUrl(String url) {
    final cleaned = url.trim().replaceAll(RegExp(r'/$'), '');
    if (cleaned.isEmpty) return;
    state = state.copyWith(syncServerUrl: cleaned);
    syncWithRemoteVaultSilently();
  }

  Future<void> syncWithRemoteVaultSilently() async {
    if (kIsWeb) return;
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 2);
      final req = await client
          .getUrl(Uri.parse('${state.syncServerUrl}/api/photo-vault'));
      final resp = await req.close();
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        final decoded = jsonDecode(body) as Map<String, dynamic>;
        final remotePhotos = (decoded['photos'] as List<dynamic>? ?? [])
            .map((e) =>
                PhotoVocabEntry.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
        _mergeRemotePhotos(remotePhotos);
      }
      client.close();
    } catch (_) {
      // Offline mode: keep local separate vault working seamlessly
    }
  }

  void _mergeRemotePhotos(List<PhotoVocabEntry> incoming) {
    final knownWordIds = <String>{
      for (final p in state.photos)
        for (final w in p.words) w.id,
    };
    final existingById = <String, PhotoVocabEntry>{
      for (final p in state.photos) p.id: p,
    };

    final updatedSelected = Set<String>.from(state.selectedWordIds);
    for (final rp in incoming) {
      existingById[rp.id] = rp;
      for (final w in rp.words) {
        if (!knownWordIds.contains(w.id) && state.autoSelectNewUploads) {
          updatedSelected.add(w.id);
        }
      }
    }

    final mergedList = existingById.values.toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    if (mergedList.length != state.photos.length ||
        updatedSelected.length != state.selectedWordIds.length) {
      state = state.copyWith(
        photos: mergedList,
        selectedWordIds: updatedSelected,
      );
      _persistSeparateVault();
    }
  }

  /// Uploads picked photo to OCR server if connected, AND parses offline notes locally on iOS.
  Future<void> addPhotoAndExtractWords({
    required String title,
    String? localImagePath,
    String manualOrLiveText = '',
  }) async {
    state = state.copyWith(isUploading: true);

    // 1. Try OCR server if reachable
    if (!kIsWeb && localImagePath != null && localImagePath.isNotEmpty) {
      try {
        final bytes = await File(localImagePath).readAsBytes();
        final b64 = base64Encode(bytes);
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 3);
        final req = await client
            .postUrl(Uri.parse('${state.syncServerUrl}/api/photo-vault/upload'));
        req.headers.contentType = ContentType.json;
        req.write(jsonEncode({
          'title': title,
          'fileName': localImagePath.split(Platform.pathSeparator).last,
          'imageBase64': b64,
          'manualText': manualOrLiveText,
        }));
        final resp = await req.close();
        if (resp.statusCode == 200) {
          final body = await resp.transform(utf8.decoder).join();
          final data = jsonDecode(body) as Map<String, dynamic>;
          if (data['ok'] == true && data['photo'] != null) {
            final serverEntry = PhotoVocabEntry.fromJson(
              (data['photo'] as Map).cast<String, dynamic>(),
            ).copyWith(localImagePath: localImagePath);
            _prependEntry(serverEntry);
            state = state.copyWith(isUploading: false);
            client.close();
            return;
          }
        }
        client.close();
      } catch (_) {
        // Fallback to pure on-device offline extraction below
      }
    }

    // 2. Pure On-Device Offline Extraction (supports iOS Live Text / Manual Notes)
    final extracted = _extractOfflineWordsFromText(manualOrLiveText, title);
    final newEntry = PhotoVocabEntry(
      id: 'photo_ios_${DateTime.now().millisecondsSinceEpoch}',
      title: title.isEmpty ? 'Ảnh chụp mới' : title,
      localImagePath: localImagePath,
      uploadedAt: DateTime.now(),
      ocrText: manualOrLiveText.isEmpty
          ? '(Đã lưu ảnh vào Kho Riêng — chạm "+ Thêm từ" hoặc dùng Live Text trên bàn phím iOS để quét chữ)'
          : manualOrLiveText,
      words: extracted,
    );

    _prependEntry(newEntry);
    state = state.copyWith(isUploading: false);
  }

  void _prependEntry(PhotoVocabEntry entry) {
    final updatedSelected = Set<String>.from(state.selectedWordIds);
    if (state.autoSelectNewUploads) {
      for (final w in entry.words) {
        updatedSelected.add(w.id);
      }
    }
    state = state.copyWith(
      photos: [entry, ...state.photos.where((p) => p.id != entry.id)],
      selectedWordIds: updatedSelected,
    );
    _persistSeparateVault();
  }

  List<FlashcardEntity> _extractOfflineWordsFromText(
    String rawText,
    String photoTitle,
  ) {
    final now = DateTime.now();
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final results = <FlashcardEntity>[];
    final pairRegex = RegExp(r'^([A-Za-z][A-Za-z\-]{2,24})\s*[:\-–=]\s*(.+)$');

    for (var i = 0; i < lines.length; i++) {
      final m = pairRegex.firstMatch(lines[i]);
      if (m != null) {
        final w = m.group(1)!.trim();
        final meaning = m.group(2)!.trim();
        final display = w[0].toUpperCase() + w.substring(1);
        results.add(
          FlashcardEntity(
            id: 'pv_ios_${now.millisecondsSinceEpoch}_$i',
            word: display,
            ipa: '/${w.toLowerCase()}/',
            cefr: 'B1',
            partOfSpeech: 'Photo Vocab • B1',
            topic: '📸 $photoTitle',
            vietnameseMeaning: meaning,
            exampleSentence: 'Context from photo "$photoTitle": $display.',
            grammarNote: 'Từ vựng trích xuất từ ảnh chụp "$photoTitle".',
            usageTip: 'Ôn tập chủ động qua Đấu trường Đoán Từ Ẩn.',
            collocations: [w.toLowerCase()],
            wordFamily: display,
            nextReviewDate: now,
          ),
        );
      }
    }

    if (results.isEmpty && rawText.trim().isNotEmpty) {
      final tokens = RegExp(r'\b[A-Za-z]{5,18}\b')
          .allMatches(rawText)
          .map((m) => m.group(0)!)
          .toSet()
          .take(10)
          .toList();
      for (var i = 0; i < tokens.length; i++) {
        final tok = tokens[i];
        final display = tok[0].toUpperCase() + tok.substring(1).toLowerCase();
        results.add(
          FlashcardEntity(
            id: 'pv_ios_tok_${now.millisecondsSinceEpoch}_$i',
            word: display,
            ipa: '/${tok.toLowerCase()}/',
            cefr: 'B2',
            partOfSpeech: 'Photo Word • B2',
            topic: '📸 $photoTitle',
            vietnameseMeaning: 'Từ trích xuất từ ảnh "$photoTitle" (chạm sửa nghĩa)',
            exampleSentence: rawText.trim(),
            grammarNote: 'Xuất hiện trong ngữ cảnh ảnh bạn đã tải lên.',
            nextReviewDate: now,
          ),
        );
      }
    }
    return results;
  }

  void togglePhotoSelection(String photoId) {
    final photo = state.photos.where((p) => p.id == photoId).firstOrNull;
    if (photo == null) return;
    final allSelected = photo.words.isNotEmpty &&
        photo.words.every((w) => state.selectedWordIds.contains(w.id));
    final next = Set<String>.from(state.selectedWordIds);
    for (final w in photo.words) {
      if (allSelected) {
        next.remove(w.id);
      } else {
        next.add(w.id);
      }
    }
    state = state.copyWith(selectedWordIds: next);
  }

  void toggleSingleWord(String wordId) {
    final next = Set<String>.from(state.selectedWordIds);
    if (next.contains(wordId)) {
      next.remove(wordId);
    } else {
      next.add(wordId);
    }
    state = state.copyWith(selectedWordIds: next);
  }

  void selectAll(bool selectAllFlag) {
    if (!selectAllFlag) {
      state = state.copyWith(selectedWordIds: {});
      return;
    }
    final all = <String>{
      for (final p in state.photos)
        for (final w in p.words) w.id,
    };
    state = state.copyWith(selectedWordIds: all);
  }

  void toggleAutoSelectNewUploads() {
    state = state.copyWith(autoSelectNewUploads: !state.autoSelectNewUploads);
  }

  Future<void> addOrUpdateWordInPhoto({
    required String photoId,
    String? wordId,
    required String word,
    required String ipa,
    required String meaning,
    required String example,
  }) async {
    final updatedPhotos = state.photos.map((p) {
      if (p.id != photoId) return p;
      if (wordId != null && wordId.isNotEmpty) {
        return p.copyWith(
          words: p.words.map((w) {
            if (w.id != wordId) return w;
            return w.copyWith(
              word: word,
              ipa: ipa.isEmpty ? w.ipa : ipa,
              vietnameseMeaning: meaning,
              exampleSentence: example.isEmpty ? w.exampleSentence : example,
            );
          }).toList(),
        );
      }
      final newCard = FlashcardEntity(
        id: 'pv_manual_${DateTime.now().millisecondsSinceEpoch}',
        word: word,
        ipa: ipa.isEmpty ? '/${word.toLowerCase()}/' : ipa,
        cefr: 'B1',
        partOfSpeech: 'Photo Vocab • B1',
        topic: '📸 ${p.title}',
        vietnameseMeaning: meaning,
        exampleSentence:
            example.isEmpty ? 'Example sentence with $word.' : example,
        nextReviewDate: DateTime.now(),
      );
      return p.copyWith(words: [newCard, ...p.words]);
    }).toList();

    final nextSelected = Set<String>.from(state.selectedWordIds);
    for (final p in updatedPhotos) {
      if (p.id == photoId && p.words.isNotEmpty) {
        nextSelected.add(p.words.first.id);
      }
    }

    state = state.copyWith(
      photos: updatedPhotos,
      selectedWordIds: nextSelected,
    );
    await _persistSeparateVault();
  }

  Future<void> deletePhoto(String photoId) async {
    final remaining = state.photos.where((p) => p.id != photoId).toList();
    state = state.copyWith(photos: remaining);
    await _persistSeparateVault();
  }
}

final photoVaultProvider =
    NotifierProvider<PhotoVaultNotifier, PhotoVaultState>(
  PhotoVaultNotifier.new,
);
