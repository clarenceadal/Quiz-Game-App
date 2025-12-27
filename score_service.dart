class ScoreService {
  static int calculate({
    required bool correct,
    required int timeRemaining,
    required int totalTime,
    required String difficulty,
    required int currentStreak,
    bool penalizeWrong = false,
  }) {
    if (!correct) {
      return penalizeWrong ? -20 : 0;
    }

    int base = 100;
    int timeBonus = ((timeRemaining / totalTime) * 50).round();

    double multiplier = 1;
    if (difficulty == 'Medium') multiplier = 1.5;
    if (difficulty == 'Hard') multiplier = 2;

    int streakBonus = (currentStreak - 1) * 25;

    return ((base + timeBonus) * multiplier).round() + streakBonus;
  }
}
