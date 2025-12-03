import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgressModel {
  final String progressId;
  final String userId;
  final String courseId;
  final List<String> completedLessons;
  final int totalLessons;
  final double progressPercentage;
  final DateTime? lastAccessedDate;
  final bool isCompleted;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProgressModel({
    required this.progressId,
    required this.userId,
    required this.courseId,
    this.completedLessons = const [],
    required this.totalLessons,
    this.progressPercentage = 0.0,
    this.lastAccessedDate,
    this.isCompleted = false,
    this.completedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'progressId': progressId,
      'userId': userId,
      'courseId': courseId,
      'completedLessons': completedLessons,
      'totalLessons': totalLessons,
      'progressPercentage': progressPercentage,
      'lastAccessedDate': lastAccessedDate != null
          ? Timestamp.fromDate(lastAccessedDate!)
          : null,
      'isCompleted': isCompleted,
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserProgressModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProgressModel(
      progressId: doc.id,
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      completedLessons: List<String>.from(data['completedLessons'] ?? []),
      totalLessons: data['totalLessons'] ?? 0,
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      lastAccessedDate: data['lastAccessedDate'] != null
          ? (data['lastAccessedDate'] as Timestamp).toDate()
          : null,
      isCompleted: data['isCompleted'] ?? false,
      completedDate: data['completedDate'] != null
          ? (data['completedDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  UserProgressModel copyWith({
    String? progressId,
    String? userId,
    String? courseId,
    List<String>? completedLessons,
    int? totalLessons,
    double? progressPercentage,
    DateTime? lastAccessedDate,
    bool? isCompleted,
    DateTime? completedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProgressModel(
      progressId: progressId ?? this.progressId,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      completedLessons: completedLessons ?? this.completedLessons,
      totalLessons: totalLessons ?? this.totalLessons,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastAccessedDate: lastAccessedDate ?? this.lastAccessedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
