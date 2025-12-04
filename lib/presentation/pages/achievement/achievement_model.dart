// File: lib/app/data/models/achievement_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementModel {
  final String achievementId;
  final String title;
  final String description;
  final String category; // 'quiz', 'course', 'streak', 'points', 'general'
  final String iconUrl;
  final int pointsReward;
  final int coinsReward;
  final Map<String, dynamic> condition; // { type: 'quiz_count', value: 5 }
  final String tier; // 'bronze', 'silver', 'gold', 'platinum'
  final DateTime createdAt;

  AchievementModel({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.category,
    required this.iconUrl,
    required this.pointsReward,
    required this.coinsReward,
    required this.condition,
    this.tier = 'bronze',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'title': title,
      'description': description,
      'category': category,
      'iconUrl': iconUrl,
      'pointsReward': pointsReward,
      'coinsReward': coinsReward,
      'condition': condition,
      'tier': tier,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AchievementModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AchievementModel(
      achievementId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'general',
      iconUrl: data['iconUrl'] ?? '',
      pointsReward: data['pointsReward'] ?? 0,
      coinsReward: data['coinsReward'] ?? 0,
      condition: Map<String, dynamic>.from(data['condition'] ?? {}),
      tier: data['tier'] ?? 'bronze',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
