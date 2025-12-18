import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_providers.dart';
import '../models/quiz_result.dart';
import 'package:intl/intl.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(quizHistoryProvider);

    if (history.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz History'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: Text(
            'No quizzes completed yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final totalQuizzes = history.length;
    final totalScore = history.fold<int>(0, (sum, q) => sum + q.score);
    final averageScore = (totalScore / totalQuizzes).toStringAsFixed(1);
    final highestScore = history.map((q) => q.score).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Gradient stats panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.shade200.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Quizzes: $totalQuizzes',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Average Score: $averageScore',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Highest Score: $highestScore',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Colors.grey),

          // Quiz history list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final QuizResult result = history[index];
                final dateStr = DateFormat('yyyy-MM-dd – kk:mm').format(result.date);
                final scorePercent = (result.score / result.totalQuestions) * 100;

                // Card color based on score
                Color cardColor;
                if (scorePercent == 100) {
                  cardColor = Colors.green.shade100;
                } else if (scorePercent >= 70) {
                  cardColor = Colors.amber.shade100;
                } else {
                  cardColor = Colors.red.shade100;
                }

                return InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    color: cardColor,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with number and category
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${result.category} - ${result.score}/${result.totalQuestions}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              if (scorePercent == 100)
                                const Icon(Icons.emoji_events, color: Colors.amber)
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Date
                          Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),

                          const SizedBox(height: 6),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: result.score / result.totalQuestions,
                              minHeight: 8,
                              color: Colors.deepPurple,
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
