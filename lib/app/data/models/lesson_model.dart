import 'package:cloud_firestore/cloud_firestore.dart';

class LessonModel {
  final String lessonId;
  final String courseId;
  final String title;
  final String description;
  final String type; // video, text, quiz, pdf
  final String? contentUrl; // URL for video/pdf
  final String? contentText; // Text content for text lessons
  final int order;
  final int duration; // dalam menit
  final bool isFree; // Free preview lesson
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonModel({
    required this.lessonId,
    required this.courseId,
    required this.title,
    required this.description,
    required this.type,
    this.contentUrl,
    this.contentText,
    required this.order,
    this.duration = 0,
    this.isFree = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'courseId': courseId,
      'title': title,
      'description': description,
      'type': type,
      'contentUrl': contentUrl,
      'contentText': contentText,
      'order': order,
      'duration': duration,
      'isFree': isFree,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory LessonModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LessonModel(
      lessonId: doc.id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'text',
      contentUrl: data['contentUrl'],
      contentText: data['contentText'],
      order: data['order'] ?? 0,
      duration: data['duration'] ?? 0,
      isFree: data['isFree'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
