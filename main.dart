import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/category_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: QuizApp(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quiz Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CategoryScreen(), // Make sure this is your category selection screen
    );
  }
}
