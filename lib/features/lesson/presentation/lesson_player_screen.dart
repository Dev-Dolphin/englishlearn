import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/speech_audio_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../gamification/presentation/gamification_provider.dart';
import '../../home/domain/learning_unit.dart';
import '../../home/presentation/home_provider.dart';
import '../data/lesson_repository.dart';
import '../domain/quiz_question.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  final LessonNode lesson;

  const LessonPlayerScreen({
    super.key,
    required this.lesson,
  });

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  late final List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int _correctCount = 0;

  int? _selectedOptionIndex;
  String? _selectedBlankWord;
  final List<String> _orderedTokens = [];
  final TextEditingController _dictationController = TextEditingController();
  bool _hasRecordedSpeech = false;
  bool _isRecordingSpeech = false;
  String _recognizedSpeechPreview = '';

  bool _hasChecked = false;
  bool _isCurrentCorrect = false;

  @override
  void initState() {
    super.initState();
    _questions = ref
        .read(lessonRepositoryProvider)
        .getQuestionsForLesson(widget.lesson.id);
  }

  @override
  void dispose() {
    _dictationController.dispose();
    super.dispose();
  }

  QuizQuestion get _currentQuestion => _questions[_currentIndex];

  bool get _canCheckAnswer {
    final q = _currentQuestion;
    return switch (q) {
      MultipleChoiceQuestion() => _selectedOptionIndex != null,
      FillInTheBlankQuestion() => _selectedBlankWord != null,
      SentenceOrderingQuestion() => _orderedTokens.isNotEmpty,
      ListeningDictationQuestion() =>
        _dictationController.text.trim().isNotEmpty,
      SpeakingPronunciationQuestion() => _hasRecordedSpeech,
    };
  }

  void _checkAnswer() {
    FocusScope.of(context).unfocus();
    final q = _currentQuestion;
    final bool correct = switch (q) {
      MultipleChoiceQuestion(correctIndex: final idx) =>
        _selectedOptionIndex == idx,
      FillInTheBlankQuestion(correctAnswer: final ans) =>
        _selectedBlankWord?.toLowerCase() == ans.toLowerCase(),
      SentenceOrderingQuestion(correctOrder: final order) =>
        _orderedTokens.join(' ') == order.join(' '),
      ListeningDictationQuestion(audioText: final audio) =>
        _normalizeText(_dictationController.text) == _normalizeText(audio),
      SpeakingPronunciationQuestion() => _hasRecordedSpeech,
    };

    if (correct) {
      HapticFeedback.mediumImpact();
      _correctCount++;
    } else {
      HapticFeedback.heavyImpact();
      ref.read(gamificationProvider.notifier).loseHeart();
    }

    setState(() {
      _hasChecked = true;
      _isCurrentCorrect = correct;
    });
  }

  String _normalizeText(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _selectedBlankWord = null;
        _orderedTokens.clear();
        _dictationController.clear();
        _hasRecordedSpeech = false;
        _recognizedSpeechPreview = '';
        _hasChecked = false;
        _isCurrentCorrect = false;
      });
    } else {
      ref.read(gamificationProvider.notifier).addXp(widget.lesson.xpReward);
      ref
          .read(homeLearningPathProvider.notifier)
          .markLessonCompleted(widget.lesson.id);
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final accuracy = ((_correctCount / _questions.length) * 100).round();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: AppColors.xpGold, size: 32),
            SizedBox(width: 10),
            Expanded(child: Text('Hoàn thành bài học!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.lesson.title, style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            Text('• Độ chính xác: $accuracy% ($_correctCount/${_questions.length} câu)'),
            Text('• Phần thưởng: +${widget.lesson.xpReward} XP'),
          ],
        ),
        actions: [
          AppButton(
            label: 'Quay về Lộ trình học',
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(gamificationProvider);
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.heartRed,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${stats.hearts}',
                  style: const TextStyle(
                    color: AppColors.heartRed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Câu ${_currentIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(_currentQuestion.prompt, style: AppTypography.titleLarge),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: _buildPolymorphicQuestionBody(_currentQuestion),
                ),
              ),
              if (_hasChecked) ...[
                _FeedbackBanner(
                  isCorrect: _isCurrentCorrect,
                  explanation: _currentQuestion.explanation,
                ),
                const SizedBox(height: 12),
              ],
              AppButton(
                label: _hasChecked
                    ? (_currentIndex == _questions.length - 1
                        ? 'Nhận thưởng +${widget.lesson.xpReward} XP'
                        : 'Câu tiếp theo')
                    : 'Kiểm tra đáp án',
                backgroundColor: _hasChecked
                    ? (_isCurrentCorrect ? AppColors.success : AppColors.primary)
                    : AppColors.primary,
                onPressed: _hasChecked
                    ? _nextQuestion
                    : (_canCheckAnswer ? _checkAnswer : null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolymorphicQuestionBody(QuizQuestion question) {
    return switch (question) {
      MultipleChoiceQuestion() => _buildMultipleChoice(question),
      FillInTheBlankQuestion() => _buildFillInTheBlank(question),
      SentenceOrderingQuestion() => _buildSentenceOrdering(question),
      ListeningDictationQuestion() => _buildListeningDictation(question),
      SpeakingPronunciationQuestion() => _buildSpeakingPronunciation(question),
    };
  }

  Widget _buildMultipleChoice(MultipleChoiceQuestion q) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      children: List.generate(q.options.length, (idx) {
        final isSelected = _selectedOptionIndex == idx;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _hasChecked
                ? null
                : () => setState(() => _selectedOptionIndex = idx),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : borderCol,
                  width: isSelected ? 2.2 : 1.4,
                ),
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : null,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isSelected ? AppColors.primary : borderCol,
                    child: Text(
                      String.fromCharCode(65 + idx),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(q.options[idx], style: AppTypography.bodyLarge),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFillInTheBlank(FillInTheBlankQuestion q) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final displaySentence = q.sentenceWithBlank.replaceFirst(
      '_____',
      _selectedBlankWord != null ? '[ $_selectedBlankWord ]' : '_____',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol, width: 1.5),
          ),
          child: Text(displaySentence, style: AppTypography.titleLarge),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: q.wordBank.map((word) {
            final isSelected = _selectedBlankWord == word;
            return ChoiceChip(
              label: Text(word),
              selected: isSelected,
              onSelected: _hasChecked
                  ? null
                  : (_) => setState(() => _selectedBlankWord = word),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSentenceOrdering(SentenceOrderingQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Nghĩa tiếng Việt: "${q.vietnameseMeaning}"',
            style: AppTypography.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: _orderedTokens.isEmpty
              ? const Text(
                  'Chạm vào các từ bên dưới để ghép câu...',
                  style: TextStyle(color: AppColors.textSecondaryLight),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _orderedTokens.map((token) {
                    return ActionChip(
                      label: Text(token),
                      onPressed: _hasChecked
                          ? null
                          : () => setState(() => _orderedTokens.remove(token)),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: q.shuffledTokens.map((token) {
            final isUsed = _orderedTokens.contains(token);
            return ActionChip(
              label: Text(token),
              onPressed: (isUsed || _hasChecked)
                  ? null
                  : () => setState(() => _orderedTokens.add(token)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildListeningDictation(ListeningDictationQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(speechAudioServiceProvider)
                    .speakEnglish(q.audioText, slow: false);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Nghe chuẩn (1.0x)'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(speechAudioServiceProvider)
                    .speakEnglish(q.audioText, slow: true);
              },
              icon: const Icon(Icons.slow_motion_video_rounded),
              label: const Text('Nghe chậm (0.7x)'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Gợi ý IPA: ${q.ipaHint}',
            textAlign: TextAlign.center,
            style: AppTypography.ipaPhonetic.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _dictationController,
          enabled: !_hasChecked,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          maxLines: 2,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (_canCheckAnswer) _checkAnswer();
          },
          decoration: const InputDecoration(
            hintText: 'Nhập lại câu tiếng Anh bạn nghe được...',
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakingPronunciation(SpeakingPronunciationQuestion q) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(q.targetSentence, style: AppTypography.titleLarge),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(speechAudioServiceProvider)
                        .speakEnglish(q.targetSentence),
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                q.ipaTranscription,
                style: AppTypography.ipaPhonetic.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(q.vietnameseTranslation, style: AppTypography.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: _hasChecked || _isRecordingSpeech
                ? null
                : () async {
                    HapticFeedback.selectionClick();
                    setState(() => _isRecordingSpeech = true);
                    final transcript = await ref
                        .read(speechAudioServiceProvider)
                        .listenAndTranscribe(
                          expectedSentence: q.targetSentence,
                        );
                    if (!mounted) return;
                    setState(() {
                      _isRecordingSpeech = false;
                      _hasRecordedSpeech = true;
                      _recognizedSpeechPreview = transcript;
                    });
                  },
            child: CircleAvatar(
              radius: 42,
              backgroundColor: _hasRecordedSpeech
                  ? AppColors.success
                  : (_isRecordingSpeech
                      ? AppColors.heartRed
                      : AppColors.primary),
              child: Icon(
                _hasRecordedSpeech
                    ? Icons.check_rounded
                    : (_isRecordingSpeech
                        ? Icons.graphic_eq_rounded
                        : Icons.mic_rounded),
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _hasRecordedSpeech
                ? 'Đã nhận giọng đọc: "$_recognizedSpeechPreview"'
                : (_isRecordingSpeech
                    ? 'Đang lắng nghe qua Microphone iOS...'
                    : 'Chạm vào Micro để đọc to câu trên'),
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final String explanation;

  const _FeedbackBanner({
    required this.isCorrect,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.success : AppColors.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Chính xác! Tuyệt vời!' : 'Chưa chính xác',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(explanation, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
