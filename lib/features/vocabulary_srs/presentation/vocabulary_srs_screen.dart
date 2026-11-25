import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/speech_audio_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../photo_vault/presentation/photo_vault_screen.dart';
import '../domain/flashcard_entity.dart';
import 'srs_provider.dart';
import 'word_challenge_screen.dart';

class VocabularySrsScreen extends ConsumerStatefulWidget {
  const VocabularySrsScreen({super.key});

  @override
  ConsumerState<VocabularySrsScreen> createState() =>
      _VocabularySrsScreenState();
}

class _VocabularySrsScreenState extends ConsumerState<VocabularySrsScreen> {
  int _subTab = 0; // 0 = Đoán Từ Ẩn, 1 = Thẻ SRS SM-2
  bool _isRevealed = false;
  String _selectedTopic = 'ALL';

  void _showAddCardDialog() {
    final wordCtrl = TextEditingController();
    final ipaCtrl = TextEditingController();
    final meaningCtrl = TextEditingController();
    final grammarCtrl = TextEditingController();
    final exampleCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm thẻ từ vựng Offline mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wordCtrl,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Từ tiếng Anh *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ipaCtrl,
                autocorrect: false,
                decoration:
                    const InputDecoration(labelText: 'Phiên âm IPA (tùy chọn)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: meaningCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nghĩa tiếng Việt *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: grammarCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú ngữ pháp / cách dùng',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: exampleCtrl,
                decoration:
                    const InputDecoration(labelText: 'Câu ví dụ ngữ cảnh'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (wordCtrl.text.trim().isEmpty ||
                  meaningCtrl.text.trim().isEmpty) {
                return;
              }
              ref.read(srsDeckProvider.notifier).addCustomCard(
                    word: wordCtrl.text.trim(),
                    ipa: ipaCtrl.text.trim(),
                    partOfSpeech: 'Vocabulary',
                    vietnameseMeaning: meaningCtrl.text.trim(),
                    grammarNote: grammarCtrl.text.trim(),
                    exampleSentence: exampleCtrl.text.trim().isEmpty
                        ? 'Practical example sentence with ${wordCtrl.text.trim()}.'
                        : exampleCtrl.text.trim(),
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('Lưu thẻ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _subTab == 2
          ? FloatingActionButton.extended(
              onPressed: _showAddCardDialog,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm từ mới'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _subTab,
                onValueChanged: (val) {
                  if (val != null) setState(() => _subTab = val);
                },
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Text(
                      '⚡ Đoán Từ',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Text(
                      '📸 Kho Ảnh',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Text(
                      '🗂️ Thẻ SRS',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                },
              ),
            ),
          ),
          Expanded(
            child: switch (_subTab) {
              0 => const WordChallengeScreen(showAppBar: false),
              1 => const PhotoVaultScreen(),
              _ => _buildSrsFlipDeckView(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSrsFlipDeckView() {
    final deck = ref.watch(srsDeckProvider);
    final topics = <String>{'ALL', ...deck.map((c) => c.topic)}.toList();
    final filtered = _selectedTopic == 'ALL'
        ? deck
        : deck.where((c) => c.topic == _selectedTopic).toList();
    final now = DateTime.now();
    final dueCards = filtered.where((c) => c.isDue(now)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SrsSummaryHeader(
          totalCards: deck.length,
          dueCount: dueCards.length,
          masteredCount: deck.where((c) => c.repetition >= 2).length,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: topics.map((t) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(t == 'ALL' ? 'Tất cả (${deck.length})' : t),
                  selected: _selectedTopic == t,
                  onSelected: (_) => setState(() {
                    _selectedTopic = t;
                    _isRevealed = false;
                  }),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (dueCards.isNotEmpty)
          _ActiveFlashcardReviewer(
            card: dueCards.first,
            isRevealed: _isRevealed,
            onReveal: () => setState(() => _isRevealed = true),
            onGrade: (grade) {
              ref
                  .read(srsDeckProvider.notifier)
                  .gradeCard(dueCards.first.id, grade);
              setState(() => _isRevealed = false);
            },
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bạn đã hoàn thành toàn bộ thẻ SRS đến hạn!',
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Chuyển sang ⚡ Đoán Từ Ẩn',
                    onPressed: () => setState(() => _subTab = 0),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 22),
        Text(
          'Kho từ vựng Offline (${filtered.length} từ)',
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: 10),
        ...filtered.map(
          (card) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                title: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(card.word, style: AppTypography.titleMedium),
                    Text(
                      card.ipa,
                      style: AppTypography.ipaPhonetic.copyWith(
                        color: AppColors.secondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  '${card.vietnameseMeaning}\n📐 ${card.grammarNote}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    ref
                        .read(speechAudioServiceProvider)
                        .speakEnglish(card.word);
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 70),
      ],
    );
  }
}

class _SrsSummaryHeader extends StatelessWidget {
  final int totalCards;
  final int dueCount;
  final int masteredCount;

  const _SrsSummaryHeader({
    required this.totalCards,
    required this.dueCount,
    required this.masteredCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: 'Cần ôn',
            value: '$dueCount',
            color: AppColors.streakOrange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            label: 'Tổng từ',
            value: '$totalCards',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            label: 'Thuộc sâu',
            value: '$masteredCount',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActiveFlashcardReviewer extends ConsumerWidget {
  final FlashcardEntity card;
  final bool isRevealed;
  final VoidCallback onReveal;
  final ValueChanged<SrsGrade> onGrade;

  const _ActiveFlashcardReviewer({
    required this.card,
    required this.isRevealed,
    required this.onReveal,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${card.topic} • ${card.partOfSpeech}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Nghe chuẩn (1.0x)',
                  onPressed: () {
                    ref
                        .read(speechAudioServiceProvider)
                        .speakEnglish(card.word, slow: false);
                  },
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  tooltip: 'Nghe chậm (0.7x)',
                  onPressed: () {
                    ref
                        .read(speechAudioServiceProvider)
                        .speakEnglish(card.word, slow: true);
                  },
                  icon: const Icon(
                    Icons.slow_motion_video_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(child: Text(card.word, style: AppTypography.displayLarge)),
            const SizedBox(height: 6),
            Center(
              child: Text(
                card.ipa,
                style: AppTypography.ipaPhonetic.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!isRevealed)
              AppButton(
                label: 'Lật thẻ xem nghĩa, ngữ pháp & ví dụ',
                icon: Icons.flip_rounded,
                isOutlined: true,
                onPressed: onReveal,
              )
            else ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                card.vietnameseMeaning,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"${card.exampleSentence}"',
                style: AppTypography.bodyLarge.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '📐 Ngữ pháp: ${card.grammarNote}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '💬 Cách dùng: ${card.usageTip}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 18),
              const Text(
                'Đánh giá mức độ nhớ của bạn (Thuật toán SM-2):',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SrsGradeButton(
                      label: 'Quên\n(1 ngày)',
                      color: AppColors.error,
                      onTap: () => onGrade(SrsGrade.again),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SrsGradeButton(
                      label: 'Khó\n(2 ngày)',
                      color: AppColors.warning,
                      onTap: () => onGrade(SrsGrade.hard),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SrsGradeButton(
                      label: 'Nhớ\n(4 ngày)',
                      color: AppColors.info,
                      onTap: () => onGrade(SrsGrade.good),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SrsGradeButton(
                      label: 'Rất dễ\n(7 ngày)',
                      color: AppColors.success,
                      onTap: () => onGrade(SrsGrade.easy),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SrsGradeButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SrsGradeButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
