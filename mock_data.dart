import '../models/quiz_category.dart';
import '../models/question.dart';

final mockCategories = [
  QuizCategory(
      id: 'science',
      name: 'Science',
      questionCount: 10,
      difficulty: 'Medium',
      highScore: 80),
  QuizCategory(
      id: 'history',
      name: 'History',
      questionCount: 10,
      difficulty: 'Medium',
      highScore: 75),
  QuizCategory(
      id: 'geography',
      name: 'Geography',
      questionCount: 10,
      difficulty: 'Medium',
      highScore: 70),
  QuizCategory(
      id: 'movies',
      name: 'Movies',
      questionCount: 10,
      difficulty: 'Easy',
      highScore: 85),
  QuizCategory(
      id: 'sports',
      name: 'Sports',
      questionCount: 10,
      difficulty: 'Medium',
      highScore: 80),
  QuizCategory(
      id: 'technology',
      name: 'Technology',
      questionCount: 10,
      difficulty: 'Hard',
      highScore: 90),
];

final mockQuestions = [
  // Science
  Question(
      id: 'q1',
      categoryId: 'science',
      question: 'What is the boiling point of water?',
      options: ['90°C', '100°C', '110°C', '120°C'],
      correctAnswer: '100°C',
      difficulty: 'Easy'),
  Question(
      id: 'q2',
      categoryId: 'science',
      question: 'What planet is known as the Red Planet?',
      options: ['Earth', 'Mars', 'Jupiter', 'Venus'],
      correctAnswer: 'Mars',
      difficulty: 'Easy'),

  // History
  Question(
      id: 'q3',
      categoryId: 'history',
      question: 'Who was the first president of the USA?',
      options: ['Abraham Lincoln', 'George Washington', 'Thomas Jefferson', 'John Adams'],
      correctAnswer: 'George Washington',
      difficulty: 'Easy'),

  // Geography
  Question(
      id: 'q4',
      categoryId: 'geography',
      question: 'Which is the largest continent?',
      options: ['Africa', 'Asia', 'Europe', 'North America'],
      correctAnswer: 'Asia',
      difficulty: 'Medium'),

  // Movies
  Question(
      id: 'q5',
      categoryId: 'movies',
      question: 'Which movie features the character "Forrest Gump"?',
      options: ['Forrest Gump', 'Titanic', 'Inception', 'Avatar'],
      correctAnswer: 'Forrest Gump',
      difficulty: 'Easy'),

  // Sports
  Question(
      id: 'q6',
      categoryId: 'sports',
      question: 'How many players are there in a football (soccer) team on the field?',
      options: ['9', '10', '11', '12'],
      correctAnswer: '11',
      difficulty: 'Easy'),

  // Technology
  Question(
      id: 'q7',
      categoryId: 'technology',
      question: 'What does CPU stand for?',
      options: ['Central Process Unit', 'Central Processing Unit', 'Computer Processing Unit', 'Central Power Unit'],
      correctAnswer: 'Central Processing Unit',
      difficulty: 'Medium'),
];





