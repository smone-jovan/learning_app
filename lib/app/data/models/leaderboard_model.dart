import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardModel {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int totalPoints;
  final String rank; // Bronze, Silver, Gold, Platinum
  final int position; // Leaderboard position
  final DateTime updatedAt;

  LeaderboardModel({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.totalPoints,
    required this.rank,
    this.position = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'totalPoints': totalPoints,
      'rank': rank,
      'position': position,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory LeaderboardModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LeaderboardModel(
      userId: doc.id,
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      totalPoints: data['totalPoints'] ?? 0,
      rank: data['rank'] ?? 'Bronze',
      position: data['position'] ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
