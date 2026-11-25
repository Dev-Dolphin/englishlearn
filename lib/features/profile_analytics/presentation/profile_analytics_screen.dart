import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../gamification/presentation/gamification_provider.dart';
import '../../vocabulary_srs/presentation/srs_provider.dart';

class ProfileAnalyticsScreen extends ConsumerWidget {
  const ProfileAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final stats = ref.watch(gamificationProvider);
    final deck = ref.watch(srsDeckProvider);
    final themeMode = ref.watch(themeModeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    user.name.characters.first,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: AppTypography.titleLarge),
                      Text(user.email, style: AppTypography.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${stats.level} • CEFR ${stats.cefrLevel} • ${user.dailyGoalMinutes} phút/ngày',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Đổi giao diện Sáng / Tối',
                  onPressed: () {
                    final next = themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark;
                    ref.read(themeModeProvider.notifier).state = next;
                  },
                  icon: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.streakOrange,
                value: '${stats.streakDays} ngày',
                label: 'Daily Streak',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.bolt_rounded,
                color: AppColors.xpGold,
                value: '${stats.xp} XP',
                label: 'Tổng kinh nghiệm',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.style_rounded,
                color: AppColors.secondary,
                value: '${deck.length} từ',
                label: 'Từ vựng SRS',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phân tích 4 Kỹ năng Ngôn ngữ (AI Skill Radar)',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 14),
                const _SkillProgressRow(
                  skill: 'Listening (Nghe hiểu)',
                  percent: 0.84,
                  color: AppColors.info,
                ),
                const SizedBox(height: 10),
                const _SkillProgressRow(
                  skill: 'Speaking & IPA (Phát âm & Phản xạ)',
                  percent: 0.78,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                const _SkillProgressRow(
                  skill: 'Vocabulary SRS (Từ vựng dài hạn)',
                  percent: 0.88,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 10),
                const _SkillProgressRow(
                  skill: 'Grammar & Writing (Ngữ pháp)',
                  percent: 0.75,
                  color: AppColors.xpGold,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bảng xếp hạng Tuần (Emerald League)',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 12),
                _LeaderboardRow(
                  rank: 1,
                  name: 'Hoàng Nam',
                  xp: stats.xp + 95,
                  isCurrentUser: false,
                ),
                _LeaderboardRow(
                  rank: 2,
                  name: '${user.name} (Bạn)',
                  xp: stats.xp,
                  isCurrentUser: true,
                ),
                _LeaderboardRow(
                  rank: 3,
                  name: 'Thanh Thảo',
                  xp: (stats.xp - 40).clamp(50, 99999),
                  isCurrentUser: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Huy hiệu Thành tựu',
                      style: AppTypography.titleLarge,
                    ),
                    const Spacer(),
                    if (stats.hearts < 5)
                      TextButton.icon(
                        onPressed: () {
                          ref
                              .read(gamificationProvider.notifier)
                              .refillHearts();
                        },
                        icon: const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.heartRed,
                          size: 16,
                        ),
                        label: const Text('Hồi phục 5 Tim'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: stats.unlockedBadges.map((badge) {
                    return Chip(
                      avatar: const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.xpGold,
                        size: 18,
                      ),
                      label: Text(badge),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillProgressRow extends StatelessWidget {
  final String skill;
  final double percent;
  final Color color;

  const _SkillProgressRow({
    required this.skill,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(skill, style: AppTypography.bodyMedium),
            Text(
              '${(percent * 100).round()}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.12)
            : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor:
                rank == 1 ? AppColors.xpGold : AppColors.borderLight,
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: rank == 1 ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTypography.titleMedium,
            ),
          ),
          Text(
            '$xp XP',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
