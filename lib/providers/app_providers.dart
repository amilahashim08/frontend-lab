import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../data/models/user_progress.dart';
import '../data/repositories/interview_repository.dart';
import '../data/repositories/learning_repository.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/services/progress_service.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepository();
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository();
});

final interviewRepositoryProvider = Provider<InterviewRepository>((ref) {
  return InterviewRepository();
});

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
  return UserProgressNotifier(ref.watch(progressServiceProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.watch(progressServiceProvider));
});

class UserProgressNotifier extends StateNotifier<UserProgress> {
  UserProgressNotifier(this._service) : super(const UserProgress()) {
    _load();
  }

  final ProgressService _service;

  Future<void> _load() async {
    state = await _service.loadProgress();
  }

  Future<void> completeUnit(String unitId, {int bonusXp = 0}) async {
    final updated = _service.awardXp(
      state,
      AppConstants.xpPerUnitComplete + bonusXp,
    );
    state = updated.copyWith(
      completedUnitIds: {...updated.completedUnitIds, unitId},
      streak: updated.streak + 1,
    );
    await _service.saveProgress(state);
  }

  Future<void> recordInterviewScore(int score) async {
    state = _service
        .awardXp(state, AppConstants.xpPerInterviewSession)
        .copyWith(lastInterviewScore: score);
    await _service.saveProgress(state);
  }

  Future<void> recordQuizPass() async {
    state = _service.awardXp(state, AppConstants.xpPerQuizPass);
    await _service.saveProgress(state);
  }
}

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier(this._service) : super(false) {
    _load();
  }

  final ProgressService _service;

  Future<void> _load() async {
    state = await _service.isAuthenticated();
  }

  Future<void> login() async {
    await _service.setAuthenticated(true);
    state = true;
  }

  Future<void> logout() async {
    await _service.setAuthenticated(false);
    state = false;
  }
}
