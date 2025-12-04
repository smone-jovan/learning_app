// File: lib/app/data/models/daily_challenge_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyChallengeModel {
  final String challengeId;
  final String date; // 'YYYY-MM-DD'
  final String quizId;
  final String title;
  final String description;
  final int pointsReward;
  final int coinsReward;
  final DateTime expiresAt;
  final DateTime createdAt;

  DailyChallengeModel({
    required this.challengeId,
    required this.date,
    required this.quizId,
    required this.title,
    required this.description,
    this.pointsReward = 50,
    this.coinsReward = 20,
    required this.expiresAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'challengeId': challengeId,
      'date': date,
      'quizId': quizId,
      'title': title,
      'description': description,
      'pointsReward': pointsReward,
      'coinsReward': coinsReward,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create dari Firestore Document
  factory DailyChallengeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DailyChallengeModel(
      challengeId: doc.id,
      date: data['date'] ?? '',
      quizId: data['quizId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      pointsReward: data['pointsReward'] ?? 50,
      coinsReward: data['coinsReward'] ?? 20,
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Copy with method
  DailyChallengeModel copyWith({
    String? challengeId,
    String? date,
    String? quizId,
    String? title,
    String? description,
    int? pointsReward,
    int? coinsReward,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return DailyChallengeModel(
      challengeId: challengeId ?? this.challengeId,
      date: date ?? this.date,
      quizId: quizId ?? this.quizId,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsReward: pointsReward ?? this.pointsReward,
      coinsReward: coinsReward ?? this.coinsReward,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
