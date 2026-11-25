import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/speech_audio_service.dart';
import '../../gamification/presentation/gamification_provider.dart';
import '../domain/pronunciation_exercise.dart';

class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});

  @override
  ConsumerState<PronunciationScreen> createState() =>
      _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen> {
  int _selectedIndex = 0;
  bool _isRecording = false;
  bool _hasEvaluated = true;

  static const List<PronunciationDrill> _drills = [
    PronunciationDrill(
      id: 'dr_1',
      sentence: 'We need a scalable architecture for our global users.',
      fullIpa: '/wiː niːd ə ˈskeɪləbl ˈɑːkɪtɛktʃə fɔːr ˈaʊə ˈɡləʊbl ˈjuːzəz/',
      vietnameseMeaning:
          'Chúng ta cần một kiến trúc có khả năng mở rộng cho người dùng toàn cầu.',
      wordBreakdown: [
        WordPronunciationScore(
          word: 'We',
          ipa: '/wiː/',
          accuracyPercent: 98,
          tip: 'Âm /iː/ kéo dài chuẩn xác.',
        ),
        WordPronunciationScore(
          word: 'need',
          ipa: '/niːd/',
          accuracyPercent: 95,
          tip: 'Phụ âm cuối /d/ rõ ràng.',
        ),
        WordPronunciationScore(
          word: 'a',
          ipa: '/ə/',
          accuracyPercent: 96,
          tip: 'Âm schwa /ə/ nhẹ tự nhiên.',
        ),
        WordPronunciationScore(
          word: 'scalable',
          ipa: '/ˈskeɪləbl/',
          accuracyPercent: 80,
          tip: 'Chú ý nguyên âm đôi /eɪ/ ở âm tiết đầu "sca-".',
        ),
        WordPronunciationScore(
          word: 'architecture',
          ipa: '/ˈɑːkɪtɛktʃə/',
          accuracyPercent: 66,
          tip: 'Chữ "ch" đầu đọc là /k/ (/ˈɑːkɪ.../), không đọc là /tʃ/.',
        ),
        WordPronunciationScore(
          word: 'for',
          ipa: '/fɔːr/',
          accuracyPercent: 94,
          tip: 'Nối âm mượt với từ tiếp theo.',
        ),
        WordPronunciationScore(
          word: 'our',
          ipa: '/ˈaʊə/',
          accuracyPercent: 91,
          tip: 'Phát âm rõ ràng.',
        ),
        WordPronunciationScore(
          word: 'global',
          ipa: '/ˈɡləʊbl/',
          accuracyPercent: 89,
          tip: 'Âm /əʊ/ và âm cuối /l/ tốt.',
        ),
        WordPronunciationScore(
          word: 'users',
          ipa: '/ˈjuːzəz/',
          accuracyPercent: 90,
          tip: 'Âm cuối /z/ rung thanh quản chuẩn.',
        ),
      ],
    ),
    PronunciationDrill(
      id: 'dr_2',
      sentence: 'Could I have an aisle seat and my original receipt please?',
      fullIpa: '/kʊd aɪ hæv ən aɪl siːt ænd maɪ əˈrɪdʒənl rɪˈsiːt pliːz/',
      vietnameseMeaning:
          'Cho tôi xin một ghế cạnh lối đi và biên lai gốc nhé?',
      wordBreakdown: [
        WordPronunciationScore(
          word: 'Could',
          ipa: '/kʊd/',
          accuracyPercent: 96,
          tip: 'Nguyên âm ngắn /ʊ/ chuẩn (chữ l câm).',
        ),
        WordPronunciationScore(
          word: 'I',
          ipa: '/aɪ/',
          accuracyPercent: 98,
          tip: 'Nối âm /kʊ-daɪ/.',
        ),
        WordPronunciationScore(
          word: 'have',
          ipa: '/hæv/',
          accuracyPercent: 95,
          tip: 'Âm cuối /v/ răng trên chạm môi dưới.',
        ),
        WordPronunciationScore(
          word: 'an',
          ipa: '/ən/',
          accuracyPercent: 96,
          tip: 'Nối âm sang "aisle": /ə-naɪl/.',
        ),
        WordPronunciationScore(
          word: 'aisle',
          ipa: '/aɪl/',
          accuracyPercent: 65,
          tip: 'Chữ "s" trong "aisle" là ÂM CÂM! Đọc giống "I\'ll" (/aɪl/).',
        ),
        WordPronunciationScore(
          word: 'seat',
          ipa: '/siːt/',
          accuracyPercent: 93,
          tip: 'Nguyên âm dài /iː/.',
        ),
        WordPronunciationScore(
          word: 'original',
          ipa: '/əˈrɪdʒənl/',
          accuracyPercent: 84,
          tip: 'Nhấn âm thứ 2 /ə-ˈRɪDƷ-ə-nl/.',
        ),
        WordPronunciationScore(
          word: 'receipt',
          ipa: '/rɪˈsiːt/',
          accuracyPercent: 64,
          tip: 'Chữ "p" trong "receipt" là ÂM CÂM! Đọc là /rɪ-ˈsiːt/.',
        ),
        WordPronunciationScore(
          word: 'please',
          ipa: '/pliːz/',
          accuracyPercent: 95,
          tip: 'Kết thúc bằng âm /z/.',
        ),
      ],
    ),
    PronunciationDrill(
      id: 'dr_3',
      sentence: 'Could you elaborate on the quarterly revenue forecast?',
      fullIpa: '/kʊd juː ɪˈlæbəreɪt ɒn ðə ˈkwɔːtəli ˈrɛvənjuː ˈfɔːkɑːst/',
      vietnameseMeaning:
          'Bạn có thể giải thích chi tiết hơn về dự báo doanh thu hàng quý không?',
      wordBreakdown: [
        WordPronunciationScore(
          word: 'Could',
          ipa: '/kʊd/',
          accuracyPercent: 95,
          tip: 'Nguyên âm ngắn /ʊ/ chuẩn.',
        ),
        WordPronunciationScore(
          word: 'you',
          ipa: '/juː/',
          accuracyPercent: 96,
          tip: 'Nối âm /d_juː/ rất tự nhiên.',
        ),
        WordPronunciationScore(
          word: 'elaborate',
          ipa: '/ɪˈlæbəreɪt/',
          accuracyPercent: 74,
          tip: 'Nhấn trọng âm vào âm tiết thứ 2: /ɪ-ˈLÆB-ə-reɪt/.',
        ),
        WordPronunciationScore(
          word: 'quarterly',
          ipa: '/ˈkwɔːtəli/',
          accuracyPercent: 86,
          tip: 'Tốt!',
        ),
        WordPronunciationScore(
          word: 'revenue',
          ipa: '/ˈrɛvənjuː/',
          accuracyPercent: 81,
          tip: 'Nhấn âm đầu /ˈrɛv-/.',
        ),
        WordPronunciationScore(
          word: 'forecast',
          ipa: '/ˈfɔːkɑːst/',
          accuracyPercent: 92,
          tip: 'Bật rõ âm cuối /st/.',
        ),
      ],
    ),
  ];

  Color _scoreColor(int score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return AppColors.warning;
    return AppColors.error;
  }

  Future<void> _recordAndAssess() async {
    final drill = _drills[_selectedIndex];
    HapticFeedback.selectionClick();
    setState(() {
      _isRecording = true;
      _hasEvaluated = false;
    });

    await ref.read(speechAudioServiceProvider).listenAndTranscribe(
          expectedSentence: drill.sentence,
        );

    if (!mounted) return;
    ref.read(gamificationProvider.notifier).addXp(15);
    setState(() {
      _isRecording = false;
      _hasEvaluated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final drill = _drills[_selectedIndex];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_drills.length, (idx) {
              final isSelected = idx == _selectedIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('Mẫu câu #${idx + 1}'),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedIndex = idx),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.record_voice_over_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Chạm từng từ để nghe riêng lẻ',
                        style: AppTypography.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Nghe chuẩn (1.0x)',
                      onPressed: () {
                        ref
                            .read(speechAudioServiceProvider)
                            .speakEnglish(drill.sentence, slow: false);
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
                            .speakEnglish(drill.sentence, slow: true);
                      },
                      icon: const Icon(
                        Icons.slow_motion_video_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: drill.wordBreakdown.map((w) {
                    final color = _hasEvaluated
                        ? _scoreColor(w.accuracyPercent)
                        : Theme.of(context).colorScheme.primary;
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => ref
                          .read(speechAudioServiceProvider)
                          .speakEnglish(w.word, slow: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color),
                        ),
                        child: Column(
                          children: [
                            Text(
                              w.word,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: color,
                              ),
                            ),
                            Text(
                              w.ipa,
                              style: AppTypography.ipaPhonetic.copyWith(
                                fontSize: 11,
                              ),
                            ),
                            if (_hasEvaluated)
                              Text(
                                '${w.accuracyPercent}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Text(drill.vietnameseMeaning, style: AppTypography.bodyMedium),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _isRecording ? null : _recordAndAssess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRecording ? AppColors.heartRed : AppColors.primary,
                  ),
                  icon: Icon(
                    _isRecording ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                  ),
                  label: Text(
                    _isRecording
                        ? 'Đang thu âm & phân tích IPA...'
                        : 'Thu âm & Chấm điểm Phát âm (+15 XP)',
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_hasEvaluated) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _scoreColor(drill.overallScore)
                            .withValues(alpha: 0.15),
                        child: Text(
                          '${drill.overallScore}%',
                          style: TextStyle(
                            color: _scoreColor(drill.overallScore),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nhận xét chi tiết từng từ (Xanh / Vàng / Đỏ)',
                              style: AppTypography.titleMedium,
                            ),
                            Text(
                              'Xanh (>=85%): Chuẩn • Vàng (70-84%): Khá • Đỏ (<70%): Âm câm / dễ sai',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ...drill.wordBreakdown.map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            w.accuracyPercent >= 85
                                ? Icons.check_circle_rounded
                                : Icons.info_rounded,
                            color: _scoreColor(w.accuracyPercent),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${w.word} (${w.ipa}) — ${w.accuracyPercent}%: ${w.tip}',
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
