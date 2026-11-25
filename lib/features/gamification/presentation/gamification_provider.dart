import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/local_storage_service.dart';

class GamificationState extends Equatable {
  final int xp;
  final int dailyXpEarned;
  final int dailyGoalXp;
  final int streakDays;
  final int hearts;
  final String cefrLevel;
  final List<String> unlockedBadges;

  const GamificationState({
    this.xp = 320,
    this.dailyXpEarned = 30,
    this.dailyGoalXp = AppConfig.defaultDailyGoalXp,
    this.streakDays = 7,
    this.hearts = AppConfig.maxHearts,
    this.cefrLevel = 'B1',
    this.unlockedBadges = const [
      '7-Day Streak Flame',
      'First 100 Vocabulary Words',
      'AI Roleplay Pioneer',
    ],
  });

  int get level => (xp ~/ 100) + 1;
  double get dailyGoalProgress =>
      (dailyXpEarned / dailyGoalXp).clamp(0.0, 1.0);

  GamificationState copyWith({
    int? xp,
    int? dailyXpEarned,
    int? dailyGoalXp,
    int? streakDays,
    int? hearts,
    String? cefrLevel,
    List<String>? unlockedBadges,
  }) {
    return GamificationState(
      xp: xp ?? this.xp,
      dailyXpEarned: dailyXpEarned ?? this.dailyXpEarned,
      dailyGoalXp: dailyGoalXp ?? this.dailyGoalXp,
      streakDays: streakDays ?? this.streakDays,
      hearts: hearts ?? this.hearts,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
    );
  }

  @override
  List<Object?> get props => [
        xp,
        dailyXpEarned,
        dailyGoalXp,
        streakDays,
        hearts,
        cefrLevel,
        unlockedBadges,
      ];
}

class GamificationNotifier extends Notifier<GamificationState> {
  @override
  GamificationState build() {
    _loadPersistedStats();
    return const GamificationState();
  }

  Future<void> _loadPersistedStats() async {
    final storage = ref.read(localStorageServiceProvider);
    final xp = await storage.getInt(storage.keyUserXp, defaultValue: 320);
    final streak = await storage.getInt(storage.keyUserStreak, defaultValue: 7);
    final hearts = await storage.getInt(
      storage.keyUserHearts,
      defaultValue: AppConfig.maxHearts,
    );
    final cefr = await storage.getString(
      storage.keyCefrLevel,
      defaultValue: 'B1',
    );
    state = state.copyWith(
      xp: xp,
      streakDays: streak,
      hearts: hearts,
      cefrLevel: cefr,
    );
  }

  Future<void> addXp(int earnedXp) async {
    final storage = ref.read(localStorageServiceProvider);
    final newXp = state.xp + earnedXp;
    final newDaily = state.dailyXpEarned + earnedXp;
    final crossedDailyGoal =
        state.dailyXpEarned < state.dailyGoalXp && newDaily >= state.dailyGoalXp;
    final newStreak = crossedDailyGoal ? state.streakDays + 1 : state.streakDays;

    state = state.copyWith(
      xp: newXp,
      dailyXpEarned: newDaily,
      streakDays: newStreak,
    );

    await storage.setInt(storage.keyUserXp, newXp);
    await storage.setInt(storage.keyUserStreak, newStreak);
  }

  Future<void> loseHeart() async {
    if (state.hearts <= 0) return;
    final storage = ref.read(localStorageServiceProvider);
    final updated = state.hearts - 1;
    state = state.copyWith(hearts: updated);
    await storage.setInt(storage.keyUserHearts, updated);
  }

  Future<void> refillHearts() async {
    final storage = ref.read(localStorageServiceProvider);
    state = state.copyWith(hearts: AppConfig.maxHearts);
    await storage.setInt(storage.keyUserHearts, AppConfig.maxHearts);
  }

  Future<void> setCefrLevel(String level, {int? dailyGoalMinutes}) async {
    final storage = ref.read(localStorageServiceProvider);
    final goalXp = (dailyGoalMinutes ?? 10) * 5;
    state = state.copyWith(cefrLevel: level, dailyGoalXp: goalXp);
    await storage.setString(storage.keyCefrLevel, level);
  }
}

final gamificationProvider =
    NotifierProvider<GamificationNotifier, GamificationState>(
  GamificationNotifier.new,
);
