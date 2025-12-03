import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_app/app/data/services/firestore_service.dart';
import 'package:learning_app/core/constant/firebase_collections.dart';
import 'package:learning_app/app/data/models/achievement_model.dart';

/// Provider untuk achievement data dari Firestore
class AchievementProvider {
  /// Get all achievements
  Future<List<AchievementModel>> getAllAchievements() async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.achievements,
        queryBuilder: (query) => query.orderBy('rarity'),
      );

      return docs.map((doc) => AchievementModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting achievements: $e');
      return [];
    }
  }

  /// Get achievement by ID
  Future<AchievementModel?> getAchievementById(String achievementId) async {
    try {
      final doc = await FirestoreService.getDocument(
        collection: FirebaseCollections.achievements,
        docId: achievementId,
      );

      if (doc != null && doc.exists) {
        return AchievementModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting achievement: $e');
      return null;
    }
  }

  /// Get user's unlocked achievements
  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.userAchievements,
        queryBuilder: (query) => query.where('userId', isEqualTo: userId),
      );

      // Get achievement IDs
      final achievementIds = docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['achievementId'] as String?;
          })
          .where((id) => id != null)
          .cast<String>()
          .toList();

      // Fetch full achievement details
      final achievements = <AchievementModel>[];
      for (var id in achievementIds) {
        final achievement = await getAchievementById(id);
        if (achievement != null) {
          achievements.add(achievement);
        }
      }

      return achievements;
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  /// Unlock achievement for user
  Future<bool> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      // Check if already unlocked
      final existing = await FirestoreService.getCollection(
        collection: FirebaseCollections.userAchievements,
        queryBuilder: (query) => query
            .where('userId', isEqualTo: userId)
            .where('achievementId', isEqualTo: achievementId),
        limit: 1,
      );

      if (existing.isNotEmpty) {
        return false; // Already unlocked
      }

      // Create user achievement record
      final docId = await FirestoreService.addDocument(
        collection: FirebaseCollections.userAchievements,
        data: {
          'userId': userId,
          'achievementId': achievementId,
          'unlockedAt': Timestamp.now(),
        },
      );

      return docId != null;
    } catch (e) {
      print('Error unlocking achievement: $e');
      return false;
    }
  }

  /// Get achievements by category
  Future<List<AchievementModel>> getAchievementsByCategory(
    String category,
  ) async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.achievements,
        queryBuilder: (query) => query.where('category', isEqualTo: category),
      );

      return docs.map((doc) => AchievementModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting achievements by category: $e');
      return [];
    }
  }
}
