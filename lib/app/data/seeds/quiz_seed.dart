import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_app/app/data/models/quiz_model.dart';
import 'package:learning_app/app/data/models/question_model.dart';
import 'package:uuid/uuid.dart';

/// Helper untuk seed data quiz sample
class QuizSeed {
  static final _firestore = FirebaseFirestore.instance;

  /// Seed sample quizzes ke Firestore
  static Future<void> seedQuizzes() async {
    try {
      // Cek apakah sudah ada quiz
      final existingQuizzes = await _firestore.collection('quizzes').get();
      if (existingQuizzes.docs.isNotEmpty) {
        print('Quizzes already seeded');
        return;
      }

      final quizzes = _getSampleQuizzes();

      // Tambahkan quiz ke Firestore
      for (var quiz in quizzes) {
        await _firestore.collection('quizzes').doc(quiz.quizId).set(quiz.toMap());
        print('Quiz created: ${quiz.title}');
      }

      print('Successfully seeded ${quizzes.length} quizzes');
    } catch (e) {
      print('Error seeding quizzes: $e');
    }
  }

  /// Seed sample questions untuk quiz tertentu
  static Future<void> seedQuestions(String quizId) async {
    try {
      final questions = _getSampleQuestions(quizId);

      // Tambahkan questions ke Firestore
      for (var question in questions) {
        await _firestore
            .collection('questions')
            .doc(question.questionId)
            .set(question.toMap());
        print('Question created: ${question.questionText}');
      }

      print('Successfully seeded ${questions.length} questions for quiz $quizId');
    } catch (e) {
      print('Error seeding questions: $e');
    }
  }

  /// Get sample quizzes data
  static List<QuizModel> _getSampleQuizzes() {
    return [
      QuizModel(
        quizId: 'flutter_basics_001',
        title: 'Flutter Basics',
        description: 'Test your knowledge about Flutter fundamentals',
        category: 'Flutter',
        difficulty: 'Easy',
        timeLimit: 600, // 10 minutes
        passingScore: 70,
        pointsReward: 100,
        coinsReward: 10,
        totalQuestions: 10,
        isPremium: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      QuizModel(
        quizId: 'dart_fundamentals_001',
        title: 'Dart Fundamentals',
        description: 'Master the basics of Dart programming language',
        category: 'Dart',
        difficulty: 'Easy',
        timeLimit: 900, // 15 minutes
        passingScore: 70,
        pointsReward: 150,
        coinsReward: 15,
        totalQuestions: 15,
        isPremium: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      QuizModel(
        quizId: 'flutter_widgets_001',
        title: 'Flutter Widgets Deep Dive',
        description: 'Advanced quiz about Flutter widgets and their usage',
        category: 'Flutter',
        difficulty: 'Medium',
        timeLimit: 1200, // 20 minutes
        passingScore: 75,
        pointsReward: 200,
        coinsReward: 20,
        totalQuestions: 20,
        isPremium: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      QuizModel(
        quizId: 'firebase_integration_001',
        title: 'Firebase Integration',
        description: 'Test your knowledge about Firebase and Flutter integration',
        category: 'Firebase',
        difficulty: 'Medium',
        timeLimit: 1500, // 25 minutes
        passingScore: 75,
        pointsReward: 250,
        coinsReward: 25,
        totalQuestions: 25,
        isPremium: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      QuizModel(
        quizId: 'advanced_flutter_001',
        title: 'Advanced Flutter Concepts',
        description: 'Challenge yourself with advanced Flutter topics',
        category: 'Flutter',
        difficulty: 'Hard',
        timeLimit: 1800, // 30 minutes
        passingScore: 80,
        pointsReward: 300,
        coinsReward: 30,
        totalQuestions: 30,
        isPremium: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Get sample questions for a quiz
  static List<QuestionModel> _getSampleQuestions(String quizId) {
    const uuid = Uuid();

    // Sample questions untuk Flutter Basics
    if (quizId == 'flutter_basics_001') {
      return [
        QuestionModel(
          questionId: uuid.v4(),
          quizId: quizId,
          type: 'multiple_choice',
          questionText: 'What is Flutter?',
          options: [
            'A mobile development framework',
            'A programming language',
            'A database system',
            'An operating system',
          ],
          correctAnswer: 'A',
          explanation:
              'Flutter is a UI toolkit by Google for building natively compiled applications for mobile, web, and desktop from a single codebase.',
          order: 1,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          questionId: uuid.v4(),
          quizId: quizId,
          type: 'multiple_choice',
          questionText: 'Which programming language is used in Flutter?',
          options: [
            'Java',
            'Kotlin',
            'Dart',
            'Swift',
          ],
          correctAnswer: 'C',
          explanation: 'Flutter uses Dart as its programming language.',
          order: 2,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          questionId: uuid.v4(),
          quizId: quizId,
          type: 'multiple_choice',
          questionText: 'What is a Widget in Flutter?',
          options: [
            'A database',
            'A building block of UI',
            'A network library',
            'A testing tool',
          ],
          correctAnswer: 'B',
          explanation:
              'In Flutter, everything is a widget. Widgets are the building blocks of a Flutter app\'s user interface.',
          order: 3,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          questionId: uuid.v4(),
          quizId: quizId,
          type: 'multiple_choice',
          questionText:
              'Which widget is used for creating a scrollable list?',
          options: [
            'Container',
            'Column',
            'ListView',
            'Row',
          ],
          correctAnswer: 'C',
          explanation:
              'ListView is the widget used for creating scrollable lists in Flutter.',
          order: 4,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          questionId: uuid.v4(),
          quizId: quizId,
          type: 'multiple_choice',
          questionText: 'What is StatelessWidget?',
          options: [
            'A widget that can change',
            'A widget that never changes',
            'A widget for animations',
            'A widget for navigation',
          ],
          correctAnswer: 'B',
          explanation:
              'StatelessWidget is a widget that never changes once built.',
          order: 5,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          questionId: uuid.v4(),
          quizId: quizId,
          type: 'multiple_choice',
          questionText: 'What is StatefulWidget?',
          options: [
            'A widget that never changes',
            'A widget that can change over time',
            'A widget for static content',
            'A widget for images',
          ],
          correctAnswer: 'B',
          explanation:
              'StatefulWidget is a widget that can change its appearance in response to events.',
          order: 6,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          questionId: uuid.v4(),
          quizId: quizId,
          type: 'multiple_choice',
          questionText: 'Which command is used to create a new Flutter project?',
          options: [
            'flutter create',
            'flutter new',
            'flutter init',
            'flutter start',
          ],
          correctAnswer: 'A',
          explanation:
              'The "flutter create" command is used to create a new Flutter project.',
          order: 7,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          questionId: uuid.v4(),
          quizId: quizId,
          type: 'multiple_choice',
          questionText: 'What is Hot Reload in Flutter?',
          options: [
            'Restarting the app',
            'Refreshing the UI without losing state',
            'Clearing cache',
            'Installing dependencies',
          ],
          correctAnswer: 'B',
          explanation:
              'Hot Reload allows you to see changes instantly without losing the current app state.',
          order: 8,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          questionId: uuid.v4(),
          quizId: quizId,
          type: 'multiple_choice',
          questionText: 'Which widget is used for horizontal layout?',
          options: [
            'Column',
            'Row',
            'Stack',
            'ListView',
          ],
          correctAnswer: 'B',
          explanation:
              'Row widget is used to arrange children horizontally.',
          order: 9,
          createdAt: DateTime.now(),
        ),
        QuestionModel(
          questionId: uuid.v4(),
          quizId: quizId,
          type: 'multiple_choice',
          questionText: 'What is the main entry point of a Flutter app?',
          options: [
            'start() function',
            'main() function',
            'init() function',
            'run() function',
          ],
          correctAnswer: 'B',
          explanation:
              'The main() function is the entry point of every Flutter application.',
          order: 10,
          createdAt: DateTime.now(),
        ),
      ];
    }

    return [];
  }

  /// Seed all data (quizzes + questions)
  static Future<void> seedAll() async {
    try {
      print('Starting to seed data...');
      
      // Seed quizzes
      await seedQuizzes();
      
      // Seed questions for each quiz
      await Future.delayed(const Duration(seconds: 2));
      await seedQuestions('flutter_basics_001');
      
      print('All data seeded successfully!');
    } catch (e) {
      print('Error seeding all data: $e');
    }
  }
}
