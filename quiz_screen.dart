import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_category.dart';
import '../providers/quiz_providers.dart';
import '../models/quiz_result.dart';
import '../services/score_service.dart';
import 'review_screen.dart';

class QuizScreen extends ConsumerWidget {
  final QuizCategory category;
  const QuizScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider(category.id));
    final currentIndex = ref.watch(currentQuestionIndexProvider);
    final selectedAnswer = ref.watch(answerSelectionProvider);
    final score = ref.watch(scoreProvider);
    final streak = ref.watch(streakProvider);
    final answerSubmitted = ref.watch(answerSubmittedProvider);

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(category.name)),
        body: const Center(child: Text('No questions available')),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('${category.name} (Q${currentIndex + 1}/${questions.length})'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Question card
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
            const SizedBox(height: 20),

            // Options list
            ...question.options.map((option) {
              // Color logic: only color after submit
              Color optionColor = Colors.white;
              if (answerSubmitted) {
                if (option == question.correctAnswer) {
                  optionColor = Colors.green.shade200;
                } else if (option == selectedAnswer) {
                  optionColor = Colors.red.shade200;
                }
              }

              return Card(
                color: optionColor,
                child: ListTile(
                  title: Text(option),
                  onTap: () {
                    if (!answerSubmitted) {
                      // Can only select before submission
                      ref.read(answerSelectionProvider.notifier).state = option;
                    }
                  },
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            // Submit / Next button
            ElevatedButton(
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
                  // Submit answer
                  if (selectedAnswer != null) {
                    final correct = selectedAnswer == question.correctAnswer;
                    final points = ScoreService.calculate(
                      correct: correct,
                      timeRemaining: 0, // Replace with timer value if needed
                      totalTime: 15,
                      difficulty: question.difficulty,
                      currentStreak: streak,
                      penalizeWrong: true,
                    );
                    ref.read(scoreProvider.notifier).state += points;
                    ref.read(streakProvider.notifier).state = correct ? streak + 1 : 0;
                    ref.read(answerSubmittedProvider.notifier).state = true;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an answer before submitting')),
                    );
                  }
                } else {
                  // Next question or finish quiz
                  if (currentIndex < questions.length - 1) {
                    ref.read(currentQuestionIndexProvider.notifier).state++;
                    ref.read(answerSelectionProvider.notifier).state = null;
                    ref.read(answerSubmittedProvider.notifier).state = false;
                  } else {
                    // Quiz finished
                    ref.read(quizHistoryProvider.notifier).addResult(
                      QuizResult(
                        category: category.name,
                        score: score,
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
          ],
        ),
      ),
    );
  }
}
