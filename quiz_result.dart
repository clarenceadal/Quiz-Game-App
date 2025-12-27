class QuizResult {
  final String category;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final DateTime date;

  QuizResult({
    required this.category,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.date,
  });
}
