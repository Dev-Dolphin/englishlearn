import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/speech_audio_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../gamification/presentation/gamification_provider.dart';
import '../../photo_vault/presentation/photo_vault_provider.dart';
import '../domain/flashcard_entity.dart';
import 'srs_provider.dart';

enum WordChallengeMode {
  levelTest('Kiểm tra Trình độ'),
  endless('Vô tận Sinh tồn'),
  daily('Mỗi Ngày Tốt Hơn 1%');

  final String title;
  const WordChallengeMode(this.title);
}

class WordChallengeScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  final List<FlashcardEntity>? initialCustomCards;
  final WordChallengeMode? initialMode;
  final String? customTitle;

  const WordChallengeScreen({
    super.key,
    this.showAppBar = true,
    this.initialCustomCards,
    this.initialMode,
    this.customTitle,
  });

  @override
  ConsumerState<WordChallengeScreen> createState() =>
      _WordChallengeScreenState();
}

class _WordChallengeScreenState extends ConsumerState<WordChallengeScreen> {
  String _selectedCefrTier = 'B1-B2';
  int _levelTestCount = 10;
  WordChallengeMode? _activeMode;

  // Persisted high scores & daily progress
  int _bestEndlessScore = 0;
  int _bestEndlessCombo = 0;
  int _dailyStreak = 1;
  double _prevDailyAvgTime = 11.5;
  int _prevDailyAccuracy = 60;
  List<String> _mistakeWordIds = [];

  // Active session state
  List<FlashcardEntity> _queue = [];
  int _currentIndex = 0;
  bool _isFeedbackPhase = false;
  bool _isSummaryPhase = false;

  Set<int> _revealedIndices = {};
  int _extraHintsUsed = 0;
  bool _synonymHintShown = false;
  final TextEditingController _answerCtrl = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  Timer? _countdownTimer;
  double _maxSeconds = 20;
  double _remainingSeconds = 20;
  DateTime _questionStartTime = DateTime.now();

  int _score = 0;
  int _combo = 0;
  int _maxSessionCombo = 0;
  int _lives = 3;
  int _correctCount = 0;
  int _answeredCount = 0;
  double _totalElapsedSec = 0;
  final List<FlashcardEntity> _sessionWrongWords = [];

  bool _lastExact = false;
  bool _lastNearMiss = false;
  bool _lastTimedOut = false;
  String _lastUserAnswer = '';
  double _lastResponseSec = 0;
  int _lastEarnedPoints = 0;
  bool _lastBonusHeart = false;

  @override
  void initState() {
    super.initState();
    _loadChallengeStats().then((_) {
      if (mounted &&
          widget.initialCustomCards != null &&
          widget.initialCustomCards!.isNotEmpty) {
        _startMode(
          widget.initialMode ?? WordChallengeMode.levelTest,
          customCards: widget.initialCustomCards,
        );
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _answerCtrl.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadChallengeStats() async {
    final storage = ref.read(localStorageServiceProvider);
    final map = await storage.getJsonMap(storage.keyWordChallengeStats);
    if (map.isEmpty || !mounted) return;

    setState(() {
      _selectedCefrTier = map['selectedTier'] as String? ?? 'B1-B2';
      _levelTestCount = map['levelTestCount'] as int? ?? 10;
      _bestEndlessScore = map['bestEndlessScore'] as int? ?? 0;
      _bestEndlessCombo = map['bestEndlessCombo'] as int? ?? 0;
      _dailyStreak = map['dailyStreak'] as int? ?? 1;
      _prevDailyAvgTime =
          (map['prevDailyAvgTime'] as num?)?.toDouble() ?? 11.5;
      _prevDailyAccuracy = map['prevDailyAccuracy'] as int? ?? 60;
      _mistakeWordIds = (map['mistakeWordIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
    });
  }

  Future<void> _saveChallengeStats() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setJsonMap(storage.keyWordChallengeStats, {
      'selectedTier': _selectedCefrTier,
      'levelTestCount': _levelTestCount,
      'bestEndlessScore': _bestEndlessScore,
      'bestEndlessCombo': _bestEndlessCombo,
      'dailyStreak': _dailyStreak,
      'prevDailyAvgTime': _prevDailyAvgTime,
      'prevDailyAccuracy': _prevDailyAccuracy,
      'mistakeWordIds': _mistakeWordIds,
    });
  }

  double _secondsForTier(String tier) {
    return switch (tier) {
      'A1-A2' => 30,
      'C1-C2' => 12,
      _ => 20,
    };
  }

  double _multiplierForTier(String tier) {
    return switch (tier) {
      'A1-A2' => 1.0,
      'C1-C2' => 2.0,
      _ => 1.5,
    };
  }

  List<FlashcardEntity> _filteredPoolForTier(
    List<FlashcardEntity> all,
    String tier,
  ) {
    final subset = all.where((c) {
      if (tier == 'A1-A2') return c.cefr == 'A1' || c.cefr == 'A2';
      if (tier == 'B1-B2') return c.cefr == 'B1' || c.cefr == 'B2';
      return c.cefr == 'C1' || c.cefr == 'C2' || c.cefr == 'B2';
    }).toList();
    return subset.length >= 5 ? subset : List<FlashcardEntity>.from(all);
  }

  void _startMode(
    WordChallengeMode mode, {
    List<FlashcardEntity>? customCards,
  }) {
    final deck = List<FlashcardEntity>.from(ref.read(srsDeckProvider));
    List<FlashcardEntity> selectedQueue;

    if (customCards != null && customCards.isNotEmpty) {
      selectedQueue = List<FlashcardEntity>.from(customCards);
    } else if (mode == WordChallengeMode.levelTest) {
      final pool = _filteredPoolForTier(deck, _selectedCefrTier)..shuffle();
      selectedQueue = pool.take(min(_levelTestCount, pool.length)).toList();
    } else if (mode == WordChallengeMode.daily) {
      final mistakes =
          deck.where((c) => _mistakeWordIds.contains(c.id)).toList();
      final rest =
          deck.where((c) => !_mistakeWordIds.contains(c.id)).toList()
            ..shuffle();
      selectedQueue = [...mistakes, ...rest].take(min(5, deck.length)).toList();
    } else {
      selectedQueue = deck..shuffle();
    }

    setState(() {
      _activeMode = mode;
      _queue = selectedQueue;
      _currentIndex = 0;
      _score = 0;
      _combo = 0;
      _maxSessionCombo = 0;
      _lives = 3;
      _correctCount = 0;
      _answeredCount = 0;
      _totalElapsedSec = 0;
      _sessionWrongWords.clear();
      _isSummaryPhase = false;
    });
    _prepareCurrentWord();
  }

  void _prepareCurrentWord() {
    _countdownTimer?.cancel();
    if (_activeMode == WordChallengeMode.endless &&
        _currentIndex >= _queue.length) {
      if (widget.initialCustomCards != null) {
        final latestSelected = ref.read(photoVaultProvider).selectedWords;
        if (latestSelected.isNotEmpty) {
          _queue = List<FlashcardEntity>.from(latestSelected);
        }
      }
      _queue.shuffle(Random());
      _currentIndex = 0;
    }

    final card = _queue[_currentIndex];
    final secs = _secondsForTier(_selectedCefrTier);

    setState(() {
      _isFeedbackPhase = false;
      _answerCtrl.clear();
      _extraHintsUsed = 0;
      _synonymHintShown = false;
      _revealedIndices = card.initialHintIndices(cefrTier: _selectedCefrTier);
      _maxSeconds = secs;
      _remainingSeconds = secs;
      _questionStartTime = DateTime.now();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _answerFocusNode.requestFocus();
      }
    });

    _countdownTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final elapsed =
          DateTime.now().difference(_questionStartTime).inMilliseconds / 1000.0;
      final left = (_maxSeconds - elapsed).clamp(0.0, _maxSeconds);
      setState(() => _remainingSeconds = left);
      if (left <= 0) {
        timer.cancel();
        _evaluateAnswer(timedOut: true);
      }
    });
  }

  void _revealOneMoreLetter() {
    if (_extraHintsUsed >= 2) return;
    final card = _queue[_currentIndex];
    final hidden = <int>[];
    for (var i = 0; i < card.word.length; i++) {
      if (RegExp(r'[a-zA-Z]').hasMatch(card.word[i]) &&
          !_revealedIndices.contains(i)) {
        hidden.add(i);
      }
    }
    if (hidden.length <= 1) return;
    hidden.shuffle();
    HapticFeedback.selectionClick();
    setState(() {
      _revealedIndices = {..._revealedIndices, hidden.first};
      _extraHintsUsed++;
    });
  }

  String _maskWordInSentence(String sentence, String targetWord) {
    final stem = targetWord.length > 5
        ? targetWord.substring(0, targetWord.length - 1)
        : targetWord;
    final escaped = RegExp.escape(stem);
    final regex = RegExp('\\b$escaped[a-zA-Z]*\\b', caseSensitive: false);
    final mask = '[${'_' * max(6, targetWord.length)}]';
    return sentence.replaceAll(regex, mask);
  }

  int _levenshtein(String a, String b) {
    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (var i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      dp[0][j] = j;
    }
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce(min);
      }
    }
    return dp[m][n];
  }

  void _evaluateAnswer({bool timedOut = false}) {
    _countdownTimer?.cancel();
    FocusScope.of(context).unfocus();

    final card = _queue[_currentIndex];
    final rawTyped = _answerCtrl.text.trim();
    final typed = rawTyped.toLowerCase();
    final target = card.word.trim().toLowerCase();

    final elapsed = (DateTime.now()
                .difference(_questionStartTime)
                .inMilliseconds /
            1000.0)
        .clamp(0.1, _maxSeconds);

    final isExact = !timedOut && typed == target;
    final isNearMiss = !isExact &&
        !timedOut &&
        typed.isNotEmpty &&
        target.length >= 5 &&
        _levenshtein(typed, target) == 1;

    _answeredCount++;
    _totalElapsedSec += elapsed;

    int earned = 0;
    bool bonusHeart = false;

    if (isExact) {
      HapticFeedback.mediumImpact();
      _correctCount++;
      _combo++;
      if (_combo > _maxSessionCombo) _maxSessionCombo = _combo;

      final comboMult = _combo >= 5
          ? 3.0
          : (_combo >= 3 ? 2.0 : (_combo >= 2 ? 1.5 : 1.0));
      final speedBonus = ((_remainingSeconds / _maxSeconds) * 15).round();
      earned = max(
        10,
        ((20 + speedBonus - _extraHintsUsed * 3) *
                _multiplierForTier(_selectedCefrTier) *
                comboMult)
            .round(),
      );
      _score += earned;

      if (_activeMode == WordChallengeMode.endless &&
          _combo % 5 == 0 &&
          _lives < 3) {
        _lives++;
        bonusHeart = true;
      }

      _mistakeWordIds.remove(card.id);
      ref.read(srsDeckProvider.notifier).gradeCard(
            card.id,
            elapsed <= _maxSeconds * 0.5 ? SrsGrade.easy : SrsGrade.good,
            awardXp: false,
          );
      ref.read(gamificationProvider.notifier).addXp(10);
    } else {
      HapticFeedback.heavyImpact();
      _combo = 0;
      if (_activeMode == WordChallengeMode.endless) {
        _lives = max(0, _lives - 1);
      }
      if (!_sessionWrongWords.any((w) => w.id == card.id)) {
        _sessionWrongWords.add(card);
      }
      if (!_mistakeWordIds.contains(card.id)) {
        _mistakeWordIds.add(card.id);
      }
      ref
          .read(srsDeckProvider.notifier)
          .gradeCard(card.id, SrsGrade.again, awardXp: false);
    }

    // Auto speak the English word to reinforce auditory memory
    ref.read(speechAudioServiceProvider).speakEnglish(card.word);
    _saveChallengeStats();

    setState(() {
      _isFeedbackPhase = true;
      _lastExact = isExact;
      _lastNearMiss = isNearMiss;
      _lastTimedOut = timedOut;
      _lastUserAnswer = rawTyped;
      _lastResponseSec = double.parse(elapsed.toStringAsFixed(1));
      _lastEarnedPoints = earned;
      _lastBonusHeart = bonusHeart;
    });
  }

  void _nextWordOrSummary() {
    if (_activeMode == WordChallengeMode.endless && _lives <= 0) {
      _finishSession();
      return;
    }
    if (_activeMode != WordChallengeMode.endless &&
        _currentIndex >= _queue.length - 1) {
      _finishSession();
      return;
    }
    setState(() => _currentIndex++);
    _prepareCurrentWord();
  }

  void _finishSession() {
    _countdownTimer?.cancel();
    if (_activeMode == WordChallengeMode.endless) {
      if (_score > _bestEndlessScore) _bestEndlessScore = _score;
      if (_maxSessionCombo > _bestEndlessCombo) {
        _bestEndlessCombo = _maxSessionCombo;
      }
    }
    setState(() => _isSummaryPhase = true);
    _saveChallengeStats();
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: _activeMode == null
          ? _buildLobby()
          : (_isSummaryPhase ? _buildSummary() : _buildArena()),
    );

    if (!widget.showAppBar) {
      return content;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_activeMode?.title ?? '⚡ Đấu Trường Đoán Từ Ẩn'),
        actions: [
          if (_activeMode != null)
            TextButton(
              onPressed: () {
                _countdownTimer?.cancel();
                setState(() => _activeMode = null);
              },
              child: const Text('Đổi chế độ'),
            ),
        ],
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildLobby() {
    final deck = ref.watch(srsDeckProvider);
    final mistakeCards =
        deck.where((c) => _mistakeWordIds.contains(c.id)).toList();
    final tiers = ['A1-A2', 'B1-B2', 'C1-C2'];

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚡ Đoán Từ Ẩn & Đếm Ngược Theo Trình Độ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Từ mới chỉ hiện 1-2 chữ cái gợi ý. Gõ đúng trước khi hết giờ để mở khóa Ngữ pháp, Cách dùng, Collocations & Đồng/Trái nghĩa!',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Chọn Trình Độ Đếm Ngược (CEFR Timer)',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tiers.map((tier) {
            final secs = _secondsForTier(tier).round();
            final mult = _multiplierForTier(tier);
            return ChoiceChip(
              label: Text('$tier (${secs}s • ${mult}x)'),
              selected: _selectedCefrTier == tier,
              onSelected: (_) {
                setState(() => _selectedCefrTier = tier);
                _saveChallengeStats();
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Mode 1: Level Test
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎯 1. Kiểm tra Trình độ (Level Test)',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Test phản xạ từ vựng với số lượng câu cố định và xếp loại tốc độ cuối bài.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [5, 10].map((cnt) {
                    return ChoiceChip(
                      label: Text('Gói $cnt từ'),
                      selected: _levelTestCount == cnt,
                      onSelected: (_) {
                        setState(() => _levelTestCount = cnt);
                        _saveChallengeStats();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                AppButton(
                  label:
                      'Bắt đầu Test $_levelTestCount từ ($_selectedCefrTier)',
                  onPressed: () => _startMode(WordChallengeMode.levelTest),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Mode 2: Endless Survival
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔥 2. Chế độ Vô tận (Endless Survival)',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '3 Tim sinh tồn + Combo x3. Đúng 5 từ liên tiếp hồi +1 Tim!\n🏆 Kỷ lục: $_bestEndlessScore điểm • Max Combo: $_bestEndlessCombo',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Chiến Chế độ Vô tận',
                  backgroundColor: AppColors.secondary,
                  onPressed: () => _startMode(WordChallengeMode.endless),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Mode 3: Daily Challenge
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📅 3. Thử thách Mỗi Ngày (Tốt Hơn Mỗi Ngày 1%)',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '5 từ chọn lọc hôm nay (ưu tiên từ hay sai). Chuỗi hiện tại: $_dailyStreak ngày • Lần trước: $_prevDailyAccuracy% (${_prevDailyAvgTime}s/từ).',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Chinh phục 5 Từ Hôm Nay',
                  onPressed: () => _startMode(WordChallengeMode.daily),
                ),
              ],
            ),
          ),
        ),

        if (mistakeCards.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📕 Sổ tay Từ Cần Khắc Phục (${mistakeCards.length} từ)',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: mistakeCards
                        .map((c) => Chip(label: Text(c.word)))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Ôn riêng ${mistakeCards.length} từ từng sai',
                    isOutlined: true,
                    onPressed: () => _startMode(
                      WordChallengeMode.levelTest,
                      customCards: mistakeCards,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildArena() {
    final card = _queue[_currentIndex];
    final progress = (_remainingSeconds / _maxSeconds).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Row(
          children: [
            if (!widget.showAppBar)
              IconButton(
                onPressed: () {
                  _countdownTimer?.cancel();
                  setState(() => _activeMode = null);
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            Expanded(
              child: Text(
                _activeMode == WordChallengeMode.endless
                    ? '🔥 Vô tận • ❤️ $_lives • Điểm: $_score (x${max(1, _combo)})'
                    : 'Câu ${_currentIndex + 1}/${_queue.length} • ⚡ $_score điểm (x${max(1, _combo)})',
                style: AppTypography.labelLarge,
              ),
            ),
            Text(
              '⏱️ ${_remainingSeconds.toStringAsFixed(1)}s',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: _remainingSeconds <= 5
                    ? AppColors.error
                    : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          minHeight: 9,
          borderRadius: BorderRadius.circular(8),
          color: _remainingSeconds <= 5 ? AppColors.error : AppColors.primary,
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  '🇻🇳 ${card.vietnameseMeaning}',
                  textAlign: TextAlign.center,
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${card.topic} • ${card.partOfSpeech} (${card.word.length} ký tự)',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: List.generate(card.word.length, (idx) {
                    final ch = card.word[idx];
                    if (ch == ' ') return const SizedBox(width: 14);
                    final show =
                        _isFeedbackPhase || _revealedIndices.contains(idx);
                    return Container(
                      width: 38,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: show
                            ? AppColors.primary.withValues(alpha: 0.14)
                            : null,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: show ? AppColors.primary : tileBorder,
                          width: 1.8,
                        ),
                      ),
                      child: Text(
                        show ? ch.toUpperCase() : '_',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: show ? AppColors.primary : null,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '📝 Ngữ cảnh: "${_isFeedbackPhase ? card.exampleSentence : _maskWordInSentence(card.exampleSentence, card.word)}"',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                if (_synonymHintShown && card.synonyms.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '🧩 Từ đồng nghĩa gợi ý: ${card.synonyms.join(", ")}',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (!_isFeedbackPhase) ...[
                  Wrap(
                    spacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed:
                            _extraHintsUsed >= 2 ? null : _revealOneMoreLetter,
                        icon: const Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 18,
                        ),
                        label: Text('Mở chữ (${2 - _extraHintsUsed})'),
                      ),
                      TextButton.icon(
                        onPressed: () => ref
                            .read(speechAudioServiceProvider)
                            .speakEnglish(card.word, slow: true),
                        icon: const Icon(Icons.volume_up_rounded, size: 18),
                        label: const Text('Nghe gợi ý'),
                      ),
                      if (card.synonyms.isNotEmpty && !_synonymHintShown)
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _synonymHintShown = true),
                          icon: const Icon(Icons.extension_rounded, size: 18),
                          label: const Text('Đồng nghĩa'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Crucial on iOS: disable QuickType auto-complete & auto-correct so keyboard doesn't spoil the word!
                  TextField(
                    controller: _answerCtrl,
                    focusNode: _answerFocusNode,
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    smartDashesType: SmartDashesType.disabled,
                    textInputAction: TextInputAction.done,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                    onSubmitted: (_) => _evaluateAnswer(),
                    decoration: const InputDecoration(
                      hintText: 'Gõ đầy đủ từ tiếng Anh...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Kiểm tra đáp án',
                    onPressed: _evaluateAnswer,
                  ),
                ] else ...[
                  _buildDeepKnowledgeCard(card),
                  const SizedBox(height: 14),
                  AppButton(
                    label: (_activeMode == WordChallengeMode.endless &&
                            _lives <= 0)
                        ? 'Xem Bảng Tổng Kết Kỷ Lục'
                        : 'Tiếp tục →',
                    onPressed: _nextWordOrSummary,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDeepKnowledgeCard(FlashcardEntity card) {
    final statusColor = _lastExact ? AppColors.success : AppColors.error;
    final String statusText;
    if (_lastExact) {
      statusText =
          '✅ Chính xác trong ${_lastResponseSec}s! (+$_lastEarnedPoints điểm${_lastBonusHeart ? " • ❤️ Hồi +1 Tim!" : ""})';
    } else if (_lastTimedOut) {
      statusText = '⏰ Hết thời gian! Đáp án chuẩn: ${card.word}';
    } else if (_lastNearMiss) {
      statusText =
          '🤏 Rất sát! Bạn gõ "$_lastUserAnswer" (lệch 1 ký tự so với "${card.word}").';
    } else {
      statusText =
          '❌ Chưa khớp (Bạn nhập: "${_lastUserAnswer.isEmpty ? "trống" : _lastUserAnswer}"). Đáp án: ${card.word}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                '${card.word}  ${card.ipa}',
                style: AppTypography.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Nghe chuẩn (1.0x)',
              onPressed: () => ref
                  .read(speechAudioServiceProvider)
                  .speakEnglish(card.word, slow: false),
              icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
            ),
            IconButton(
              tooltip: 'Nghe chậm (0.7x)',
              onPressed: () => ref
                  .read(speechAudioServiceProvider)
                  .speakEnglish(card.word, slow: true),
              icon: const Icon(
                Icons.slow_motion_video_rounded,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const Divider(height: 18),
        Text(
          '📐 Ngữ pháp & Cấu trúc: ${card.grammarNote}',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '💬 Cách dùng & Lưu ý: ${card.usageTip}',
          style: AppTypography.bodyMedium,
        ),
        if (card.collocations.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '🔗 Cụm từ cố định: ${card.collocations.join(" • ")}',
            style: AppTypography.bodyMedium,
          ),
        ],
        if (card.wordFamily.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '🧬 Gia đình từ: ${card.wordFamily}',
            style: AppTypography.bodyMedium,
          ),
        ],
        if (card.synonyms.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '🔄 Đồng nghĩa: ${card.synonyms.join(", ")}${card.antonyms.isNotEmpty ? "  |  Trái nghĩa: ${card.antonyms.join(", ")}" : ""}',
            style: AppTypography.bodyMedium,
          ),
        ],
      ],
    );
  }

  Widget _buildSummary() {
    final acc = _answeredCount > 0
        ? ((_correctCount / _answeredCount) * 100).round()
        : 0;
    final avgSec = _answeredCount > 0
        ? double.parse((_totalElapsedSec / _answeredCount).toStringAsFixed(1))
        : 0.0;

    final accDiff = acc - _prevDailyAccuracy;
    final speedDiff =
        double.parse((_prevDailyAvgTime - avgSec).toStringAsFixed(1));

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.xpGold,
                  size: 52,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hoàn thành Đấu Trường Từ Vựng!',
                  textAlign: TextAlign.center,
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Điểm: $_score • Chính xác: $acc% ($_correctCount/$_answeredCount) • Tốc độ TB: ${avgSec}s/từ',
                  textAlign: TextAlign.center,
                  style: AppTypography.titleMedium,
                ),
                if (_activeMode == WordChallengeMode.daily) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      '🌱 Tốt Hơn Mỗi Ngày 1%:\n'
                      '• Độ chính xác: ${accDiff >= 0 ? "+$accDiff%" : "$accDiff%"} so với lần trước\n'
                      '• Phản xạ: ${speedDiff >= 0 ? "Nhanh hơn ${speedDiff}s/từ ⚡" : "Chậm hơn ${speedDiff.abs()}s/từ"}',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],
                if (_sessionWrongWords.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '📌 Các từ cần lưu ý ôn lại:',
                      style: AppTypography.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ..._sessionWrongWords.map(
                    (w) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${w.word} ${w.ipa}'),
                      subtitle: Text(w.vietnameseMeaning),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.primary,
                        ),
                        onPressed: () => ref
                            .read(speechAudioServiceProvider)
                            .speakEnglish(w.word),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppButton(
                  label: 'Quay về Sảnh Chọn Chế Độ',
                  onPressed: () {
                    if (_activeMode == WordChallengeMode.daily) {
                      _dailyStreak++;
                      _prevDailyAccuracy = acc;
                      _prevDailyAvgTime = avgSec;
                      _saveChallengeStats();
                    }
                    setState(() => _activeMode = null);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
