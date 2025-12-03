import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAttemptModel {
  final String attemptId;
  final String userId;
  final String quizId;
  final Map<String, String> userAnswers;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final int score;
  final double percentage;
  final int pointsEarned;
  final int coinsEarned;
  final bool isPassed;
  final int timeSpent;
  final DateTime createdAt;

  QuizAttemptModel({
    required this.attemptId,
    required this.userId,
    required this.quizId,
    required this.userAnswers,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    required this.score,
    required this.percentage,
    required this.pointsEarned,
    required this.coinsEarned,
    required this.isPassed,
    required this.timeSpent,
    required this.createdAt,
  });

  factory QuizAttemptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizAttemptModel(
      attemptId: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      userAnswers: Map<String, String>.from(data['userAnswers'] ?? {}),
      correctAnswers: data['correctAnswers'] ?? 0,
      wrongAnswers: data['wrongAnswers'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      score: data['score'] ?? 0,
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      pointsEarned: data['pointsEarned'] ?? 0,
      coinsEarned: data['coinsEarned'] ?? 0,
      isPassed: data['isPassed'] ?? false,
      timeSpent: data['timeSpent'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'quizId': quizId,
      'userAnswers': userAnswers,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'totalQuestions': totalQuestions,
      'score': score,
      'percentage': percentage,
      'pointsEarned': pointsEarned,
      'coinsEarned': coinsEarned,
      'isPassed': isPassed,
      'timeSpent': timeSpent,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
