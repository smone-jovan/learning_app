import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_app/app/data/services/firestore_service.dart';
import '../../../core/constant/firebase_collections.dart';
import 'package:learning_app/app/data/models/user_model.dart';

/// Provider untuk user data dari Firestore
class UserProvider {
  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await FirestoreService.getDocument(
        collection: FirebaseCollections.users,
        docId: userId,
      );

      if (doc != null && doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Stream user data
  Stream<UserModel?> streamUser(String userId) {
    return FirestoreService.streamDocument(
      collection: FirebaseCollections.users,
      docId: userId,
    ).map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Update user
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      return await FirestoreService.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: data,
      );
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  /// Create user
  Future<bool> createUser(UserModel user) async {
    try {
      return await FirestoreService.setDocument(
        collection: FirebaseCollections.users,
        docId: user.userId,
        data: user.toMap(),
      );
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  /// Get users by rank
  Future<List<UserModel>> getUsersByRank(String rank) async {
    try {
      final docs = await FirestoreService.getCollection(
        collection: FirebaseCollections.users,
        queryBuilder: (query) => query.where('rank', isEqualTo: rank),
      );

      return docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting users by rank: $e');
      return [];
    }
  }
}
