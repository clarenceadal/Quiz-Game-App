import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_providers.dart';
import 'quiz_screen.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  // Map categories to icons (example)
  IconData _getCategoryIcon(String id) {
    switch (id) {
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history_edu;
      case 'geography':
        return Icons.public;
      case 'movies':
        return Icons.movie;
      case 'sports':
        return Icons.sports_soccer;
      case 'technology':
        return Icons.computer;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(quizCategoriesProvider);
    final history = ref.watch(quizHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Quiz Categories'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3 / 2,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];

            // Questions & difficulty summary
            final categoryQuestions = ref.read(questionsProvider(category.id));
            final totalQuestions = categoryQuestions.length;
            final difficultyCount = {
              'Easy': categoryQuestions.where((q) => q.difficulty == 'Easy').length,
              'Medium': categoryQuestions.where((q) => q.difficulty == 'Medium').length,
              'Hard': categoryQuestions.where((q) => q.difficulty == 'Hard').length,
            };

            // High score & completion
            final categoryHistory = history.where((h) => h.category == category.name);
            final highScore = categoryHistory.isNotEmpty
                ? categoryHistory.map((h) => h.score).reduce((a, b) => a > b ? a : b)
                : 0;
            final completed = categoryHistory.isNotEmpty;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuizScreen(category: category)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: completed
                      ? const LinearGradient(
                          colors: [Colors.green, Colors.lightGreenAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: completed
                          ? Colors.greenAccent.shade200
                          : Colors.deepPurpleAccent.shade100,
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(category.id),
                      size: 36,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Questions: $totalQuestions',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Easy: ${difficultyCount['Easy']} | Med: ${difficultyCount['Medium']} | Hard: ${difficultyCount['Hard']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'High Score: $highScore',
                      style: const TextStyle(
                          color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
