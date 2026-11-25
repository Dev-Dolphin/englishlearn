import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Offline-first Local Storage Service backing SRS cards, Word Challenge stats, streak, XP, and user profile.
class LocalStorageService {
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keyCefrLevel = 'cefr_level';
  static const String _keyDailyGoalMinutes = 'daily_goal_minutes';
  static const String _keyUserXp = 'user_xp';
  static const String _keyUserStreak = 'user_streak';
  static const String _keyUserHearts = 'user_hearts';
  static const String _keySrsCards = 'srs_flashcards_v2';
  static const String _keyCompletedLessons = 'completed_lessons_v2';
  static const String _keyWordChallengeStats = 'word_challenge_stats_v1';

  final Map<String, Object> _memoryFallback = {};

  Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await _prefs();
    if (prefs != null) {
      return prefs.getBool(key) ?? defaultValue;
    }
    return (_memoryFallback[key] as bool?) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    _memoryFallback[key] = value;
    final prefs = await _prefs();
    await prefs?.setBool(key, value);
  }

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final prefs = await _prefs();
    if (prefs != null) {
      return prefs.getInt(key) ?? defaultValue;
    }
    return (_memoryFallback[key] as int?) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    _memoryFallback[key] = value;
    final prefs = await _prefs();
    await prefs?.setInt(key, value);
  }

  Future<String> getString(String key, {String defaultValue = ''}) async {
    final prefs = await _prefs();
    if (prefs != null) {
      return prefs.getString(key) ?? defaultValue;
    }
    return (_memoryFallback[key] as String?) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    _memoryFallback[key] = value;
    final prefs = await _prefs();
    await prefs?.setString(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    final raw = await getString(key);
    if (raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => e.toString()).toList();
  }

  Future<void> setStringList(String key, List<String> values) async {
    await setString(key, jsonEncode(values));
  }

  Future<Map<String, dynamic>> getJsonMap(String key) async {
    final raw = await getString(key);
    if (raw.isEmpty) return {};
    return (jsonDecode(raw) as Map<dynamic, dynamic>).cast<String, dynamic>();
  }

  Future<void> setJsonMap(String key, Map<String, dynamic> map) async {
    await setString(key, jsonEncode(map));
  }

  Future<List<Map<String, dynamic>>> getJsonList(String key) async {
    final raw = await getString(key);
    if (raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> list) async {
    await setString(key, jsonEncode(list));
  }

  // Convenience keys
  String get keyOnboardingDone => _keyOnboardingDone;
  String get keyCefrLevel => _keyCefrLevel;
  String get keyDailyGoalMinutes => _keyDailyGoalMinutes;
  String get keyUserXp => _keyUserXp;
  String get keyUserStreak => _keyUserStreak;
  String get keyUserHearts => _keyUserHearts;
  String get keySrsCards => _keySrsCards;
  String get keyCompletedLessons => _keyCompletedLessons;
  String get keyWordChallengeStats => _keyWordChallengeStats;
}
