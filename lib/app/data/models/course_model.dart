import 'package:cloud_firestore/cloud_firestore.dart';
class CourseModel {
final String courseId;
final String title;
final String description;
final String category;
final String level; // Beginner/Intermediate/Advanced
final String? thumbnailUrl;
final int totalLessons;
final int totalDuration; // dalam menit
final int enrolledStudents;
final double rating;
final int totalReviews;
final bool isPremium;
final int price;
final List<String> tags;
final DateTime createdAt;
final DateTime updatedAt;
CourseModel({
required this.courseId,
required this.title,
required this.description,
required this.category,
required this.level,
this.thumbnailUrl,
this.totalLessons = 0,
this.totalDuration = 0,
this.enrolledStudents = 0,
this.rating = 0.0,
this.totalReviews = 0,
this.isPremium = false,
this.price = 0,
this.tags = const [],
DateTime? createdAt,
DateTime? updatedAt,
}) : createdAt = createdAt ?? DateTime.now(),
updatedAt = updatedAt ?? DateTime.now();
Map<String, dynamic> toMap() {
return {
'courseId': courseId,
'title': title,
'description': description,
'category': category,
'level': level,
'thumbnailUrl': thumbnailUrl,
'totalLessons': totalLessons,
'totalDuration': totalDuration,
'enrolledStudents': enrolledStudents,
'rating': rating,
'totalReviews': totalReviews,
'isPremium': isPremium,
'price': price,
'tags': tags,
'createdAt': Timestamp.fromDate(createdAt),
'updatedAt': Timestamp.fromDate(updatedAt),
};
}
factory CourseModel.fromFirestore(DocumentSnapshot doc) {
Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
return CourseModel(
courseId: doc.id,
title: data['title'] ?? '',
description: data['description'] ?? '',
category: data['category'] ?? '',
level: data['level'] ?? 'Beginner',
thumbnailUrl: data['thumbnailUrl'],
totalLessons: data['totalLessons'] ?? 0,
totalDuration: data['totalDuration'] ?? 0,
enrolledStudents: data['enrolledStudents'] ?? 0,
rating: (data['rating'] ?? 0.0).toDouble(),
totalReviews: data['totalReviews'] ?? 0,
isPremium: data['isPremium'] ?? false,
price: data['price'] ?? 0,
tags: List<String>.from(data['tags'] ?? []),
createdAt: (data['createdAt'] as Timestamp).toDate(),
updatedAt: (data['updatedAt'] as Timestamp).toDate(),
);
}
}