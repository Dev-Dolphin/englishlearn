import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/gamification/presentation/gamification_provider.dart';
import '../constants/app_colors.dart';
import 'stat_badge.dart';

class MainShellScaffold extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Widget body;

  const MainShellScaffold({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.body,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 14,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'CEFR ${stats.cefrLevel}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatBadge(
                        icon: Icons.local_fire_department_rounded,
                        value: '${stats.streakDays}',
                        color: AppColors.streakOrange,
                        tooltip: 'Chuỗi ngày học (Daily Streak)',
                      ),
                      const SizedBox(width: 6),
                      StatBadge(
                        icon: Icons.bolt_rounded,
                        value: '${stats.xp} XP',
                        color: AppColors.xpGold,
                        tooltip: 'Điểm kinh nghiệm (XP)',
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => ref
                            .read(gamificationProvider.notifier)
                            .refillHearts(),
                        child: StatBadge(
                          icon: Icons.favorite_rounded,
                          value: '${stats.hearts}',
                          color: AppColors.heartRed,
                          tooltip: 'Chạm để hồi phục 5 Tim',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTabSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Lộ trình',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt_rounded),
            label: 'Từ vựng',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy_rounded),
            label: 'AI Tutor',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none_rounded),
            selectedIcon: Icon(Icons.mic_rounded),
            label: 'Phát âm',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }
}
