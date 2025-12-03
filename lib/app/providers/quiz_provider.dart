import 'package:learning_app/app/data/services/firestore_service.dart';
import 'package:learning_app/core/constant/firebase_collections.dart';
import 'package:learning_app/app/data/models/quiz_model.dart';
import 'package:learning_app/app/data/models/question_model.dart';
import 'package:learning_app/app/data/models/quiz_attempt_model.dart';

/// Provider untuk quiz data dari Firestore
class QuizProvider {
  /// Get all quizzes
  Future<List<QuizModel>> getAllQuizzes() async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.quizzes,
        queryBuilder: (query) => query.orderBy('createdAt', descending: true),
      );

      return docs.map((doc) => QuizModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting quizzes: $e');
      return [];
    }
  }

  /// Get quiz by ID
  Future<QuizModel?> getQuizById(String quizId) async {
    try {
      final doc = await FirestoreService.getDocument(
        collection: FirebaseCollections.quizzes,
        docId: quizId,
      );

      if (doc != null && doc.exists) {
        return QuizModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting quiz: $e');
      return null;
    }
  }

  /// Get quizzes by category
  Future<List<QuizModel>> getQuizzesByCategory(String category) async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.quizzes,
        queryBuilder: (query) =>
            query.where('category', isEqualTo: category),
      );

      return docs.map((doc) => QuizModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting quizzes by category: $e');
      return [];
    }
  }

  /// Get questions for quiz
  Future<List<QuestionModel>> getQuizQuestions(String quizId) async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.questions,
        queryBuilder: (query) =>
            query.where('quizId', isEqualTo: quizId).orderBy('order'),
      );

      return docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting questions: $e');
      return [];
    }
  }

  /// Save quiz attempt
  Future<String?> saveQuizAttempt(QuizAttemptModel attempt) async {
    try {
      return await FirestoreService.addDocument(
        collection: FirebaseCollections.quizAttempts,
        data: attempt.toMap(),
      );
    } catch (e) {
      print('Error saving quiz attempt: $e');
      return null;
    }
  }

  /// Get user quiz attempts
  Future<List<QuizAttemptModel>> getUserQuizAttempts({
    required String userId,
    required String quizId,
  }) async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.quizAttempts,
        queryBuilder: (query) => query
            .where('userId', isEqualTo: userId)
            .where('quizId', isEqualTo: quizId)
            .orderBy('createdAt', descending: true),
        limit: 10,
      );

      return docs.map((doc) => QuizAttemptModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting user quiz attempts: $e');
      return [];
    }
  }

  /// Get best quiz attempt
  Future<QuizAttemptModel?> getBestQuizAttempt({
    required String userId,
    required String quizId,
  }) async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.quizAttempts,
        queryBuilder: (query) => query
            .where('userId', isEqualTo: userId)
            .where('quizId', isEqualTo: quizId)
            .orderBy('score', descending: true),
        limit: 1,
      );

      if (docs.isNotEmpty) {
        return QuizAttemptModel.fromFirestore(docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting best quiz attempt: $e');
      return null;
    }
  }
}
