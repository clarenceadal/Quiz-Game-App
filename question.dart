class Question {
  final String id;
  final String categoryId;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String difficulty;

  Question({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
  });
}
