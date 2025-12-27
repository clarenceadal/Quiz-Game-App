import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_category.dart';
import '../providers/quiz_providers.dart';
import '../models/quiz_result.dart';
import '../services/score_service.dart';
import 'review_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final QuizCategory category;
  const QuizScreen({super.key, required this.category});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsProvider(widget.category.id));
    final currentIndex = ref.watch(currentQuestionIndexProvider);
    final selectedAnswer = ref.watch(answerSelectionProvider);
    final score = ref.watch(scoreProvider);
    final correctAnswers = ref.watch(correctAnswersProvider);
    final streak = ref.watch(streakProvider);
    final answerSubmitted = ref.watch(answerSubmittedProvider);
    final timerAsync = ref.watch(questionTimerProvider(currentIndex));
    final timeRemaining = timerAsync.maybeWhen(data: (v) => v, orElse: () => 0);
    final penalizeWrong = ref.watch(penalizeWrongProvider);

    // Auto-advance when timer hits 0
    ref.listen(questionTimerProvider(currentIndex), (previous, next) {
      next.whenData((time) {
        if (time == 0 && !answerSubmitted) {
          // Timer expired, auto-advance
          if (currentIndex < questions.length - 1) {
            ref.read(currentQuestionIndexProvider.notifier).state++;
            ref.read(answerSelectionProvider.notifier).state = null;
            ref.read(answerSubmittedProvider.notifier).state = false;
          } else {
            // Last question, finish quiz
            ref.read(quizHistoryProvider.notifier).addResult(
              QuizResult(
                category: widget.category.name,
                score: score,
                correctAnswers: correctAnswers,
                totalQuestions: questions.length,
                date: DateTime.now(),
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ReviewScreen()),
            );
          }
        }
      });
    });

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.name)),
        body: const Center(child: Text('No questions available')),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('${widget.category.name} (${currentIndex + 1}/${questions.length})'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question.question,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Timer display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: ${timeRemaining}s', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                Text('Streak: $streak', style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 20),

            ...question.options.map((option) {
              // Pre-submit: grey border for selected; Post-submit: green/red background for correct/wrong
              final bool isSelectedPreSubmit = !answerSubmitted && selectedAnswer == option;
              Color optionCardColor = Colors.white;
              Border? cardBorder;

              if (isSelectedPreSubmit) {
                cardBorder = Border.all(color: Colors.grey.shade700, width: 2.5);
              } else if (answerSubmitted && selectedAnswer != null) {
                if (option == question.correctAnswer) {
                  optionCardColor = Colors.green.shade200;
                } else if (option == selectedAnswer) {
                  optionCardColor = Colors.red.shade200;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: optionCardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: cardBorder,
                ),
                child: ListTile(
                  title: Text(option),
                  onTap: () {
                    if (!answerSubmitted) {
                      ref.read(answerSelectionProvider.notifier).state = option;
                    }
                  },
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            Row(
              children: [
                if (!answerSubmitted)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      onPressed: () {
                        // Skip advances or finishes quiz
                        if (currentIndex < questions.length - 1) {
                          ref.read(currentQuestionIndexProvider.notifier).state++;
                          ref.read(answerSelectionProvider.notifier).state = null;
                          ref.read(answerSubmittedProvider.notifier).state = false;
                        } else {
                          // Last question - finish quiz without answering
                          ref.read(quizHistoryProvider.notifier).addResult(
                            QuizResult(
                              category: widget.category.name,
                              score: score,
                              correctAnswers: correctAnswers,
                              totalQuestions: questions.length,
                              date: DateTime.now(),
                            ),
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const ReviewScreen()),
                          );
                        }
                      },
                      child: const Text('Skip'),
                    ),
                  ),
                if (!answerSubmitted)
                  const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.teal,
                    ),
                    child: Text(
                      answerSubmitted ? 'Next' : 'Submit',
                      style: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                if (!answerSubmitted) {
                  if (selectedAnswer != null) {
                    final correct = selectedAnswer == question.correctAnswer;
                    final points = ScoreService.calculate(
                      correct: correct,
                      timeRemaining: timeRemaining,
                      totalTime: 15,
                      difficulty: question.difficulty,
                      currentStreak: streak,
                      penalizeWrong: penalizeWrong,
                    );
                    ref.read(scoreProvider.notifier).state += points;
                    if (correct) {
                      ref.read(correctAnswersProvider.notifier).state++;
                    }
                    ref.read(streakProvider.notifier).state = correct ? streak + 1 : 0;
                    ref.read(answerSubmittedProvider.notifier).state = true;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an answer before submitting')),
                    );
                  }
                } else {
                  if (currentIndex < questions.length - 1) {
                    ref.read(currentQuestionIndexProvider.notifier).state++;
                    ref.read(answerSelectionProvider.notifier).state = null;
                    ref.read(answerSubmittedProvider.notifier).state = false;
                  } else {
                    ref.read(quizHistoryProvider.notifier).addResult(
                      QuizResult(
                        category: widget.category.name,
                        score: score,
                        correctAnswers: correctAnswers,
                        totalQuestions: questions.length,
                        date: DateTime.now(),
                      ),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const ReviewScreen()),
                    );
                  }
                }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
