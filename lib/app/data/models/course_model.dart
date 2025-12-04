import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String courseId;
  final String title;
  final String description;
  final String category;
  final String level; // Beginner, Intermediate, Advanced
  final String imageUrl;
  final int lessonsCount;
  final int duration; // in minutes
  final bool isPublished;
  final bool isPremium;
  final int pointsReward;
  final int coinsReward;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.courseId,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    this.imageUrl = '',
    this.lessonsCount = 0,
    this.duration = 0,
    this.isPublished = true,
    this.isPremium = false,
    this.pointsReward = 500,
    this.coinsReward = 250,
    required this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CourseModel(
      courseId: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      level: data['level'] ?? 'Beginner',
      imageUrl: data['imageUrl'] ?? '',
      lessonsCount: data['lessonsCount'] ?? 0,
      duration: data['duration'] ?? 0,
      isPublished: data['isPublished'] ?? true,
      isPremium: data['isPremium'] ?? false,
      pointsReward: data['pointsReward'] ?? 500,
      coinsReward: data['coinsReward'] ?? 250,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'imageUrl': imageUrl,
      'lessonsCount': lessonsCount,
      'duration': duration,
      'isPublished': isPublished,
      'isPremium': isPremium,
      'pointsReward': pointsReward,
      'coinsReward': coinsReward,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
