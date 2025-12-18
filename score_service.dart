
class ScoreService {
  static int calculate({
    required bool correct,
    required int timeRemaining,
    required int totalTime,
    required String difficulty, // "Easy", "Medium", "Hard"
    required int currentStreak,
    bool penalizeWrong = false,
  }) {
    if (!correct) {
      return penalizeWrong ? -20 : 0;
    }

    // Base points
    int base = 100;

    // Time bonus
    int timeBonus = ((timeRemaining / totalTime) * 50).round();

    // Difficulty multiplier
    double multiplier = 1;
    if (difficulty == 'Medium') multiplier = 1.5;
    if (difficulty == 'Hard') multiplier = 2;

    // Streak bonus
    int streakBonus = (currentStreak - 1) * 25;

    return ((base + timeBonus) * multiplier).round() + streakBonus;
  }
}
