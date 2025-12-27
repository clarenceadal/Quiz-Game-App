class CategoryStats {
  final String categoryId;
  final int attempts;
  final int bestCorrect;
  final int totalQuestionsAttempted;
  final double accuracy; // 0..1

  const CategoryStats({
    required this.categoryId,
    required this.attempts,
    required this.bestCorrect,
    required this.totalQuestionsAttempted,
    required this.accuracy,
  });
}
