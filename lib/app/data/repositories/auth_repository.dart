import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '/core/constant/firebase_collections.dart';
import '../models/user_model.dart';

/// Repository untuk authentication operations
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      rethrow;
    }
  }

  /// Register with email and password
  Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      if (credential.user != null) {
        final userModel = UserModel(
          userId: credential.user!.uid,
          email: email,
          displayName: displayName,
        );

        await FirestoreService.setDocument(
          collection: FirebaseCollections.users,
          docId: credential.user!.uid,
          data: userModel.toMap(),
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('Register error: ${e.message}');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.message}');
      rethrow;
    }
  }

  /// Update password
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      print('Update password error: ${e.message}');
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      // Delete user document from Firestore
      if (currentUser != null) {
        await FirestoreService.deleteDocument(
          collection: FirebaseCollections.users,
          docId: currentUser!.uid,
        );
      }

      // Delete auth account
      await currentUser?.delete();
    } catch (e) {
      print('Delete account error: $e');
      rethrow;
    }
  }

  /// Re-authenticate user (required for sensitive operations)
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Re-authenticate error: ${e.message}');
      rethrow;
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      print('Send verification error: $e');
      rethrow;
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Reload user data
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }
}
