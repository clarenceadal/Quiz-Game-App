import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_category.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/quiz_session.dart';
import '../models/game_state.dart';
import '../models/category_stats.dart';
import '../models/achievement.dart';
import '../data/mock_data.dart';
import '../services/score_service.dart';

final quizCategoriesProvider = Provider<List<QuizCategory>>((ref) {
  return mockCategories;
});

final questionsProvider = Provider.family<List<Question>, String>((ref, categoryId) {
  return mockQuestions.where((q) => q.categoryId == categoryId).toList();
});

final currentQuestionIndexProvider = StateProvider<int>((ref) => 0);

final answerSelectionProvider = StateProvider<String?>((ref) => null);

final answerSubmittedProvider = StateProvider<bool>((ref) => false);

// Per-question timer keyed by question index; resets per question
final questionTimerProvider = StreamProvider.family.autoDispose<int, int>((ref, questionIndex) async* {
  const totalTime = 15;
  for (var i = totalTime; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
});

final scoreProvider = StateProvider<int>((ref) => 0);

// Number of correct answers (for percentage display)
final correctAnswersProvider = StateProvider<int>((ref) => 0);

final streakProvider = StateProvider<int>((ref) => 0);

final quizHistoryProvider = StateNotifierProvider<QuizHistoryNotifier, List<QuizResult>>(
  (ref) => QuizHistoryNotifier(),
);

class QuizHistoryNotifier extends StateNotifier<List<QuizResult>> {
  QuizHistoryNotifier() : super([]);

  void addResult(QuizResult result) {
    state = [...state, result];
  }
}

// Optional settings
final penalizeWrongProvider = StateProvider<bool>((ref) => true);

// Score calculator service provider
final scoreCalculatorProvider = Provider<ScoreService>((ref) => ScoreService());

// Quiz session state machine
final quizSessionProvider = StateNotifierProvider<QuizSessionNotifier, QuizSession?>((ref) {
  return QuizSessionNotifier(ref);
});

class QuizSessionNotifier extends StateNotifier<QuizSession?> {
  final Ref ref;
  QuizSessionNotifier(this.ref) : super(null);

  void start(String categoryId) {
    final questions = ref.read(questionsProvider(categoryId));
    state = QuizSession(
      categoryId: categoryId,
      totalQuestions: questions.length,
      currentIndex: 0,
      selectedAnswer: null,
      answerSubmitted: false,
      streak: 0,
      correctAnswers: 0,
      penalizeWrong: ref.read(penalizeWrongProvider),
      state: GameState.questionShowing,
    );
    // Reset counters
    ref.read(scoreProvider.notifier).state = 0;
    ref.read(correctAnswersProvider.notifier).state = 0;
    ref.read(streakProvider.notifier).state = 0;
  }

  void selectAnswer(String option) {
    if (state == null) return;
    if (state!.state != GameState.questionShowing) return;
    state = state!.copyWith(selectedAnswer: option, state: GameState.answerSelected);
  }

  void submit({required int timeRemaining, required Question question}) {
    if (state == null) return;
    final selected = state!.selectedAnswer;
    if (selected == null) return;
    final correct = selected == question.correctAnswer;
    final streak = correct ? state!.streak + 1 : 0;
    final points = ScoreService.calculate(
      correct: correct,
      timeRemaining: timeRemaining,
      totalTime: 15,
      difficulty: question.difficulty,
      currentStreak: state!.streak,
      penalizeWrong: state!.penalizeWrong,
    );

    ref.read(scoreProvider.notifier).state += points;
    if (correct) {
      ref.read(correctAnswersProvider.notifier).state++;
    }
    ref.read(streakProvider.notifier).state = streak;
    state = state!.copyWith(answerSubmitted: true, streak: streak, state: GameState.reviewMode);
  }

  void skip() {
    _advance(resetSelection: true);
  }

  void next() {
    _advance(resetSelection: true);
  }

  void _advance({bool resetSelection = false}) {
    if (state == null) return;
    final nextIndex = state!.currentIndex + 1;
    if (nextIndex >= state!.totalQuestions) {
      state = state!.copyWith(state: GameState.completed);
      return;
    }
    state = state!.copyWith(
      currentIndex: nextIndex,
      selectedAnswer: resetSelection ? null : state!.selectedAnswer,
      answerSubmitted: false,
      state: GameState.questionShowing,
    );
  }
}

// Current question derived from session
final currentQuestionProvider = Provider<Question?>((ref) {
  final session = ref.watch(quizSessionProvider);
  if (session == null) return null;
  final qs = ref.watch(questionsProvider(session.categoryId));
  if (session.currentIndex < 0 || session.currentIndex >= qs.length) return null;
  return qs[session.currentIndex];
});

// Category stats provider
final categoryStatsProvider = Provider.family<CategoryStats, String>((ref, categoryId) {
  final history = ref.watch(quizHistoryProvider);
  final byCat = history.where((h) => h.category == categoryId).toList();
  if (byCat.isEmpty) {
    return CategoryStats(
      categoryId: categoryId,
      attempts: 0,
      bestCorrect: 0,
      totalQuestionsAttempted: 0,
      accuracy: 0,
    );
  }
  final attempts = byCat.length;
  final bestCorrect = byCat.map((h) => h.correctAnswers).fold<int>(0, (a, b) => a > b ? a : b);
  final totalQuestionsAttempted = byCat.map((h) => h.totalQuestions).fold<int>(0, (a, b) => a + b);
  final totalCorrect = byCat.map((h) => h.correctAnswers).fold<int>(0, (a, b) => a + b);
  final accuracy = totalQuestionsAttempted == 0 ? 0.0 : totalCorrect / totalQuestionsAttempted;
  return CategoryStats(
    categoryId: categoryId,
    attempts: attempts,
    bestCorrect: bestCorrect,
    totalQuestionsAttempted: totalQuestionsAttempted,
    accuracy: accuracy,
  );
});

// Achievements provider
final achievementsProvider = Provider<List<Achievement>>((ref) {
  final history = ref.watch(quizHistoryProvider);
  final List<Achievement> out = [];
  if (history.any((h) => h.correctAnswers == h.totalQuestions && h.totalQuestions > 0)) {
    out.add(const Achievement(id: 'perfect', title: 'Perfect Score', description: 'Answered all questions correctly'));
  }
  if (history.length >= 10) {
    out.add(const Achievement(id: 'veteran', title: 'Quiz Veteran', description: 'Completed 10+ quizzes'));
  }
  return out;
});

// Leaderboard: top by percentage correct
final leaderboardProvider = Provider<List<QuizResult>>((ref) {
  final history = [...ref.watch(quizHistoryProvider)];
  history.sort((a, b) => (b.correctAnswers / b.totalQuestions).compareTo(a.correctAnswers / a.totalQuestions));
  return history.take(10).toList();
});
