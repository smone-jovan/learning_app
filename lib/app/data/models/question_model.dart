import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String questionId;
  final String quizId;
  final String questionText;
  final String type; // multiple_choice, true_false, text_input
  final List<String> options; // For multiple choice
  final String correctAnswer;
  final String? explanation;
  final int points;
  final int order;
  final DateTime createdAt;

  QuestionModel({
    required this.questionId,
    required this.quizId,
    required this.questionText,
    required this.type,
    this.options = const [],
    required this.correctAnswer,
    this.explanation,
    this.points = 10,
    required this.order,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'quizId': quizId,
      'questionText': questionText,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'points': points,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      questionId: doc.id,
      quizId: data['quizId'] ?? '',
      questionText: data['questionText'] ?? '',
      type: data['type'] ?? 'multiple_choice',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      explanation: data['explanation'],
      points: data['points'] ?? 10,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
