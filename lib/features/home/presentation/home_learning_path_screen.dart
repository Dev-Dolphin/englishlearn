import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/speech_audio_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../gamification/presentation/gamification_provider.dart';
import '../../vocabulary_srs/presentation/word_challenge_screen.dart';
import '../domain/learning_unit.dart';
import 'home_provider.dart';

class HomeLearningPathScreen extends ConsumerWidget {
  final ValueChanged<LessonNode> onStartLesson;
  final VoidCallback onOpenPlacementTest;

  const HomeLearningPathScreen({
    super.key,
    required this.onStartLesson,
    required this.onOpenPlacementTest,
  });

  void _showStudyGuideSheet(
    BuildContext context,
    WidgetRef ref,
    LearningUnit unit,
    LessonNode lesson,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.78,
          maxChildSize: 0.94,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'SỔ TAY LÝ THUYẾT • UNIT ${unit.unitNumber}',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(lesson.title, style: AppTypography.titleLarge),
                const SizedBox(height: 4),
                Text(lesson.subtitle, style: AppTypography.bodyMedium),
                if (lesson.grammarNote.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.secondary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💡 Trọng tâm Ngữ pháp & Giao tiếp:',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(lesson.grammarNote, style: AppTypography.bodyMedium),
                      ],
                    ),
                  ),
                ],
                if (lesson.keyVocab.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'Từ vựng & Mẫu câu cốt lõi trong bài:',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  ...lesson.keyVocab.map(
                    (v) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(v.word, style: AppTypography.titleMedium),
                            Text(
                              v.ipa,
                              style: AppTypography.ipaPhonetic.copyWith(
                                color: AppColors.secondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('${v.meaning}\n"${v.example}"'),
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
                                .speakEnglish(v.word);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppButton(
                  label: 'Bắt đầu làm bài tập (+${lesson.xpReward} XP)',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onStartLesson(lesson);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final stats = ref.watch(gamificationProvider);
    final units = ref.watch(homeLearningPathProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DailyGoalBanner(
          userName: user.name,
          learningGoal: user.learningGoal,
          dailyXpEarned: stats.dailyXpEarned,
          dailyGoalXp: stats.dailyGoalXp,
          progress: stats.dailyGoalProgress,
          onRetakePlacement: onOpenPlacementTest,
          onOpenWordChallenge: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WordChallengeScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        ...units.map(
          (unit) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _UnitCard(
              unit: unit,
              onStartLesson: onStartLesson,
              onOpenStudyGuide: (lesson) =>
                  _showStudyGuideSheet(context, ref, unit, lesson),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyGoalBanner extends StatelessWidget {
  final String userName;
  final String learningGoal;
  final int dailyXpEarned;
  final int dailyGoalXp;
  final double progress;
  final VoidCallback onRetakePlacement;
  final VoidCallback onOpenWordChallenge;

  const _DailyGoalBanner({
    required this.userName,
    required this.learningGoal,
    required this.dailyXpEarned,
    required this.dailyGoalXp,
    required this.progress,
    required this.onRetakePlacement,
    required this.onOpenWordChallenge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, $userName! 👋',
            style: AppTypography.titleLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            'Mục tiêu: $learningGoal',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: onOpenWordChallenge,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                ),
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text(
                  'Đấu Trường Đoán Từ Ẩn',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              TextButton.icon(
                onPressed: onRetakePlacement,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                ),
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Test trình độ'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ mục tiêu hôm nay',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$dailyXpEarned / $dailyGoalXp XP',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final LearningUnit unit;
  final ValueChanged<LessonNode> onStartLesson;
  final ValueChanged<LessonNode> onOpenStudyGuide;

  const _UnitCard({
    required this.unit,
    required this.onStartLesson,
    required this.onOpenStudyGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'UNIT ${unit.unitNumber} • ${unit.cefrLevel}',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(unit.completionProgress * 100).round()}% hoàn thành',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(unit.title, style: AppTypography.titleLarge),
            const SizedBox(height: 4),
            Text(unit.description, style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            ...unit.lessons.map(
              (lesson) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LessonNodeTile(
                  lesson: lesson,
                  onTapQuiz: () => onStartLesson(lesson),
                  onTapStudy: () => onOpenStudyGuide(lesson),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonNodeTile extends StatelessWidget {
  final LessonNode lesson;
  final VoidCallback onTapQuiz;
  final VoidCallback onTapStudy;

  const _LessonNodeTile({
    required this.lesson,
    required this.onTapQuiz,
    required this.onTapStudy,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    final IconData leadingIcon;
    final Color accentColor;

    if (lesson.isCompleted) {
      leadingIcon = Icons.check_circle_rounded;
      accentColor = AppColors.success;
    } else if (lesson.isLocked) {
      leadingIcon = Icons.lock_outline_rounded;
      accentColor = AppColors.textSecondaryLight;
    } else {
      leadingIcon = Icons.play_circle_fill_rounded;
      accentColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: lesson.isCompleted
              ? AppColors.success.withValues(alpha: 0.45)
              : borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(leadingIcon, color: accentColor, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title, style: AppTypography.titleMedium),
                    const SizedBox(height: 2),
                    Text(lesson.subtitle, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.xpGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${lesson.xpReward} XP',
                  style: const TextStyle(
                    color: AppColors.xpGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (!lesson.isLocked) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTapStudy,
                    icon: const Icon(Icons.menu_book_rounded, size: 16),
                    label: const Text('Lý thuyết'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onTapQuiz,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.quiz_rounded, size: 16),
                    label: const Text('Làm bài tập'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
