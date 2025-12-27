import 'game_state.dart';

class QuizSession {
  final String categoryId;
  final int totalQuestions;
  final int currentIndex;
  final String? selectedAnswer;
  final bool answerSubmitted;
  final int streak;
  final int correctAnswers;
  final bool penalizeWrong;
  final GameState state;

  const QuizSession({
    required this.categoryId,
    required this.totalQuestions,
    required this.currentIndex,
    required this.selectedAnswer,
    required this.answerSubmitted,
    required this.streak,
    required this.correctAnswers,
    required this.penalizeWrong,
    required this.state,
  });

  QuizSession copyWith({
    String? categoryId,
    int? totalQuestions,
    int? currentIndex,
    String? selectedAnswer,
    bool? answerSubmitted,
    int? streak,
    int? correctAnswers,
    bool? penalizeWrong,
    GameState? state,
  }) {
    return QuizSession(
      categoryId: categoryId ?? this.categoryId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      answerSubmitted: answerSubmitted ?? this.answerSubmitted,
      streak: streak ?? this.streak,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      penalizeWrong: penalizeWrong ?? this.penalizeWrong,
      state: state ?? this.state,
    );
  }
}
