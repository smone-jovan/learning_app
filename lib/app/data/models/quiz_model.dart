import 'package:cloud_firestore/cloud_firestore.dart';
class QuizModel {
final String quizId;
final String title;
final String description;
final String category;
final String difficulty; // Easy/Medium/Hard
final String? courseId;
final int timeLimit; // dalam detik, 0 = unlimited
final int passingScore; // persentase
final int pointsReward;
final int coinsReward;
final int totalQuestions;
final String? thumbnailUrl;
final bool isPremium;
final DateTime createdAt;
final DateTime updatedAt;
final int totalAttempts;
QuizModel({
required this.quizId,
required this.title,
required this.description,
required this.category,
required this.difficulty,
this.courseId,
this.timeLimit = 0,
this.passingScore = 70,
this.pointsReward = 100,
this.coinsReward = 10,
required this.totalQuestions,
this.thumbnailUrl,
this.isPremium = false,
DateTime? createdAt,
DateTime? updatedAt,
this.totalAttempts = 0,
}) : createdAt = createdAt ?? DateTime.now(),
updatedAt = updatedAt ?? DateTime.now();
Map<String, dynamic> toMap() {
return {
'quizId': quizId,
'title': title,
'description': description,
'category': category,
'difficulty': difficulty,
'courseId': courseId,
'timeLimit': timeLimit,
'passingScore': passingScore,
'pointsReward': pointsReward,
'coinsReward': coinsReward,
'totalQuestions': totalQuestions,
'thumbnailUrl': thumbnailUrl,
'isPremium': isPremium,
'createdAt': Timestamp.fromDate(createdAt),
'updatedAt': Timestamp.fromDate(updatedAt),
'totalAttempts': totalAttempts,
};
}
factory QuizModel.fromFirestore(DocumentSnapshot doc) {
Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
return QuizModel(
quizId: doc.id,
title: data['title'] ?? '',
description: data['description'] ?? '',
category: data['category'] ?? '',
difficulty: data['difficulty'] ?? 'Medium',
courseId: data['courseId'],
timeLimit: data['timeLimit'] ?? 0,
passingScore: data['passingScore'] ?? 70,
pointsReward: data['pointsReward'] ?? 100,
coinsReward: data['coinsReward'] ?? 10,
totalQuestions: data['totalQuestions'] ?? 0,
thumbnailUrl: data['thumbnailUrl'],
isPremium: data['isPremium'] ?? false,
createdAt: (data['createdAt'] as Timestamp).toDate(),
updatedAt: (data['updatedAt'] as Timestamp).toDate(),
totalAttempts: data['totalAttempts'] ?? 0,
);
}
}