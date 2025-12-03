import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final int? points;
  final int? coins;
  final int? level;
  final int? currentStreak;
  final int? longestStreak;
  final List<String>? enrolledCourses;
  final List<String>? completedQuizzes;
  final DateTime? createdAt;
  final DateTime? lastActiveDate;

  UserModel({
    required this.userId,
    this.email,
    this.displayName,
    this.photoURL,
    this.points,
    this.coins,
    this.level,
    this.currentStreak,
    this.longestStreak,
    this.enrolledCourses,
    this.completedQuizzes,
    this.createdAt,
    this.lastActiveDate,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      return UserModel(userId: doc.id);
    }

    return UserModel(
      userId: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      points: data['points'] as int? ?? 0,
      coins: data['coins'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      enrolledCourses: (data['enrolledCourses'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      completedQuizzes: (data['completedQuizzes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'points': points ?? 0,
      'coins': coins ?? 0,
      'level': level ?? 1,
      'currentStreak': currentStreak ?? 0,
      'longestStreak': longestStreak ?? 0,
      'enrolledCourses': enrolledCourses ?? [],
      'completedQuizzes': completedQuizzes ?? [],
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastActiveDate': lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : FieldValue.serverTimestamp(),
    };
  }

  /// Copy with method for updates
  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? photoURL,
    int? points,
    int? coins,
    int? level,
    int? currentStreak,
    int? longestStreak,
    List<String>? enrolledCourses,
    List<String>? completedQuizzes,
    DateTime? createdAt,
    DateTime? lastActiveDate,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      points: points ?? this.points,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      completedQuizzes: completedQuizzes ?? this.completedQuizzes,
      createdAt: createdAt ?? this.createdAt,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
