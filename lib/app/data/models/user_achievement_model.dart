import 'package:cloud_firestore/cloud_firestore.dart';

class UserAchievementModel {
  final String userAchievementId;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;
  final bool isClaimed;
  final DateTime? claimedAt;

  UserAchievementModel({
    required this.userAchievementId,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.isClaimed = false,
    this.claimedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userAchievementId': userAchievementId,
      'userId': userId,
      'achievementId': achievementId,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'isClaimed': isClaimed,
      'claimedAt': claimedAt != null ? Timestamp.fromDate(claimedAt!) : null,
    };
  }

  /// Create dari Firestore Document
  factory UserAchievementModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserAchievementModel(
      userAchievementId: doc.id,
      userId: data['userId'] ?? '',
      achievementId: data['achievementId'] ?? '',
      unlockedAt: (data['unlockedAt'] as Timestamp).toDate(),
      isClaimed: data['isClaimed'] ?? false,
      claimedAt: data['claimedAt'] != null
          ? (data['claimedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Copy with method
  UserAchievementModel copyWith({
    String? userAchievementId,
    String? userId,
    String? achievementId,
    DateTime? unlockedAt,
    bool? isClaimed,
    DateTime? claimedAt,
  }) {
    return UserAchievementModel(
      userAchievementId: userAchievementId ?? this.userAchievementId,
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  /// Check if this achievement can be claimed
  bool get canClaim => !isClaimed;

  /// Get days since unlocked
  int get daysSinceUnlocked {
    final now = DateTime.now();
    return now.difference(unlockedAt).inDays;
  }
}
