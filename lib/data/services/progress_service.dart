import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_progress.dart';

class ProgressService {
  static const _keyProgress = 'user_progress';
  static const _keyOnboarding = 'onboarding_done';
  static const _keyAuth = 'is_authenticated';
  static const _keyFocus = 'learning_focus';
  static const _keyLevel = 'experience_level';

  Future<UserProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProgress);
    if (raw == null) return const UserProgress();
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return UserProgress(
      xp: map['xp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      streak: map['streak'] as int? ?? 0,
      rankTitle: map['rankTitle'] as String? ?? 'React Apprentice',
      completedUnitIds: (map['completedUnitIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      weakTopicIds: (map['weakTopicIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['TOP-001'],
      lastInterviewScore: map['lastInterviewScore'] as int? ?? 0,
      dailyChallengeCompleted: map['dailyChallengeCompleted'] as bool? ?? false,
    );
  }

  Future<void> saveProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyProgress,
      jsonEncode({
        'xp': progress.xp,
        'level': progress.level,
        'streak': progress.streak,
        'rankTitle': progress.rankTitle,
        'completedUnitIds': progress.completedUnitIds.toList(),
        'weakTopicIds': progress.weakTopicIds,
        'lastInterviewScore': progress.lastInterviewScore,
        'dailyChallengeCompleted': progress.dailyChallengeCompleted,
      }),
    );
  }

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }

  Future<void> setOnboardingDone({
    required LearningFocus focus,
    required ExperienceLevel level,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
    await prefs.setString(_keyFocus, focus.name);
    await prefs.setString(_keyLevel, level.name);
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAuth) ?? false;
  }

  Future<void> setAuthenticated(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAuth, value);
  }

  UserProgress awardXp(UserProgress current, int amount) {
    var xp = current.xp + amount;
    var level = current.level;
    var rank = current.rankTitle;
    while (xp >= level * 200) {
      xp -= level * 200;
      level++;
      final rankIndex = (level - 1).clamp(0, AppConstants.rankTitles.length - 1);
      rank = AppConstants.rankTitles[rankIndex];
    }
    return current.copyWith(xp: xp, level: level, rankTitle: rank);
  }
}
