class AppConfig {
  const AppConfig._();

  static const String appName = 'LingoAI English';
  static const String appVersion = '1.0.0';
  static const String apiBaseUrl = 'https://api.lingoai.example.com/v1';
  static const String aiModelName = 'gemini-2.5-flash';

  /// Default daily goal in XP
  static const int defaultDailyGoalXp = 50;

  /// Maximum hearts before needing practice/refill
  static const int maxHearts = 5;
}
