import 'package:flutter/material.dart';
import '../../features/ai_tutor/presentation/ai_tutor_screen.dart';
import '../../features/home/domain/learning_unit.dart';
import '../../features/home/presentation/home_learning_path_screen.dart';
import '../../features/lesson/presentation/lesson_player_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile_analytics/presentation/profile_analytics_screen.dart';
import '../../features/pronunciation/presentation/pronunciation_screen.dart';
import '../../features/vocabulary_srs/presentation/vocabulary_srs_screen.dart';
import '../widgets/main_shell_scaffold.dart';

/// Root Navigation Shell managing bottom navigation tabs, Lesson Player, and Placement Test.
class AppRootNavigator extends StatefulWidget {
  const AppRootNavigator({super.key});

  @override
  State<AppRootNavigator> createState() => _AppRootNavigatorState();
}

class _AppRootNavigatorState extends State<AppRootNavigator> {
  int _currentTab = 0;

  void _openLesson(LessonNode lesson) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonPlayerScreen(lesson: lesson),
      ),
    );
  }

  void _openOnboardingPlacement() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => OnboardingScreen(
          onFinished: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeLearningPathScreen(
        onStartLesson: _openLesson,
        onOpenPlacementTest: _openOnboardingPlacement,
      ),
      const VocabularySrsScreen(),
      const AiTutorScreen(),
      const PronunciationScreen(),
      const ProfileAnalyticsScreen(),
    ];

    return MainShellScaffold(
      currentIndex: _currentTab,
      onTabSelected: (index) => setState(() => _currentTab = index),
      body: IndexedStack(
        index: _currentTab,
        children: pages,
      ),
    );
  }
}
