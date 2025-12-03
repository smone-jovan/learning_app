import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementModel {
  final String achievementId;
  final String title;
  final String description;
  final String iconUrl;
  final String category; // quiz, course, streak, points
  final int requirement; // e.g., 10 for "Complete 10 quizzes"
  final int pointsReward;
  final int coinsReward;
  final String rarity; // common, rare, epic, legendary
  final DateTime createdAt;

  AchievementModel({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.requirement,
    this.pointsReward = 0,
    this.coinsReward = 0,
    this.rarity = 'common',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'category': category,
      'requirement': requirement,
      'pointsReward': pointsReward,
      'coinsReward': coinsReward,
      'rarity': rarity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AchievementModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AchievementModel(
      achievementId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      category: data['category'] ?? 'quiz',
      requirement: data['requirement'] ?? 1,
      pointsReward: data['pointsReward'] ?? 0,
      coinsReward: data['coinsReward'] ?? 0,
      rarity: data['rarity'] ?? 'common',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
