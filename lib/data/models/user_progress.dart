class UserProgress {
  const UserProgress({
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.rankTitle = 'React Apprentice',
    this.completedUnitIds = const {},
    this.weakTopicIds = const ['TOP-001'],
    this.lastInterviewScore = 0,
    this.dailyChallengeCompleted = false,
  });

  final int xp;
  final int level;
  final int streak;
  final String rankTitle;
  final Set<String> completedUnitIds;
  final List<String> weakTopicIds;
  final int lastInterviewScore;
  final bool dailyChallengeCompleted;

  int get xpToNextLevel => level * 200;

  UserProgress copyWith({
    int? xp,
    int? level,
    int? streak,
    String? rankTitle,
    Set<String>? completedUnitIds,
    List<String>? weakTopicIds,
    int? lastInterviewScore,
    bool? dailyChallengeCompleted,
  }) {
    return UserProgress(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      rankTitle: rankTitle ?? this.rankTitle,
      completedUnitIds: completedUnitIds ?? this.completedUnitIds,
      weakTopicIds: weakTopicIds ?? this.weakTopicIds,
      lastInterviewScore: lastInterviewScore ?? this.lastInterviewScore,
      dailyChallengeCompleted:
          dailyChallengeCompleted ?? this.dailyChallengeCompleted,
    );
  }
}
