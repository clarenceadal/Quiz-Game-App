import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_category.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import 'mock_data.dart';

// -----------------------------
// Categories Provider
// -----------------------------
final quizCategoriesProvider = Provider<List<QuizCategory>>((ref) {
  return mockCategories;
});

// -----------------------------
// Questions by Category
// -----------------------------
final questionsProvider = Provider.family<List<Question>, String>((ref, categoryId) {
  return mockQuestions.where((q) => q.categoryId == categoryId).toList();
});

// -----------------------------
// Current Question Index
// -----------------------------
final currentQuestionIndexProvider = StateProvider<int>((ref) => 0);

// -----------------------------
// Selected Answer
// -----------------------------
final answerSelectionProvider = StateProvider<String?>((ref) => null);

// -----------------------------
// Tracks whether the user has submitted the answer
// -----------------------------
final answerSubmittedProvider = StateProvider<bool>((ref) => false);

// -----------------------------
// Question Timer
// -----------------------------
final questionTimerProvider = StreamProvider.autoDispose<int>((ref) async* {
  const totalTime = 15;
  for (var i = totalTime; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
});

// -----------------------------
// Score Provider
// -----------------------------
final scoreProvider = StateProvider<int>((ref) => 0);

// -----------------------------
// Current streak of consecutive correct answers
// -----------------------------
final streakProvider = StateProvider<int>((ref) => 0);

// -----------------------------
// Quiz History Provider
// -----------------------------
final quizHistoryProvider = StateNotifierProvider<QuizHistoryNotifier, List<QuizResult>>(
  (ref) => QuizHistoryNotifier(),
);

class QuizHistoryNotifier extends StateNotifier<List<QuizResult>> {
  QuizHistoryNotifier() : super([]);

  void addResult(QuizResult result) {
    state = [...state, result]; // Add new result to history
  }
}
