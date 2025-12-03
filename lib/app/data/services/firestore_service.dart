import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore service untuk operasi database
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Firestore instance
  static FirebaseFirestore get instance => _firestore;

  // Generic methods

  /// Get document by ID
  static Future<DocumentSnapshot?> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  /// Get all documents in collection
  static Future<List<DocumentSnapshot>> getCollection({
    required String collection,
    Query Function(Query query)? queryBuilder,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      print('Error getting collection: $e');
      return [];
    }
  }

  /// Add document
  static Future<String?> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      final doc = await _firestore.collection(collection).add(data);
      return doc.id;
    } catch (e) {
      print('Error adding document: $e');
      return null;
    }
  }

  /// Set document (create or overwrite)
  static Future<bool> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
      return true;
    } catch (e) {
      print('Error setting document: $e');
      return false;
    }
  }

  /// Update document
  static Future<bool> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
      return true;
    } catch (e) {
      print('Error updating document: $e');
      return false;
    }
  }

  /// Delete document
  static Future<bool> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      return true;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  /// Stream document
  static Stream<DocumentSnapshot> streamDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Stream collection
  static Stream<QuerySnapshot> streamCollection({
    required String collection,
    Query Function(Query query)? queryBuilder,
  }) {
    Query query = _firestore.collection(collection);

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    return query.snapshots();
  }

  /// Batch write
  static Future<bool> batchWrite(
    List<Map<String, dynamic>> operations,
  ) async {
    try {
      final batch = _firestore.batch();

      for (var operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String?;
        final data = operation['data'] as Map<String, dynamic>?;

        final docRef = docId != null
            ? _firestore.collection(collection).doc(docId)
            : _firestore.collection(collection).doc();

        switch (type) {
          case 'set':
            batch.set(docRef, data!);
            break;
          case 'update':
            batch.update(docRef, data!);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error batch write: $e');
      return false;
    }
  }

  /// Query with where clause
  static Future<List<DocumentSnapshot>> queryWhere({
    required String collection,
    required String field,
    required dynamic isEqualTo,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: isEqualTo)
          .get();
      return snapshot.docs;
    } catch (e) {
      print('Error querying where: $e');
      return [];
    }
  }

  /// Query with array contains
  static Future<List<DocumentSnapshot>> queryArrayContains({
    required String collection,
    required String field,
    required dynamic value,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where(field, arrayContains: value)
          .get();
      return snapshot.docs;
    } catch (e) {
      print('Error querying array contains: $e');
      return [];
    }
  }

  /// Get document count
  static Future<int> getCount({
    required String collection,
    Query Function(Query query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting count: $e');
      return 0;
    }
  }
}
