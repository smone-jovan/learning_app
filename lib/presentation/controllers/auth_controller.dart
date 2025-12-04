import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../app/data/models/user_model.dart';
import '../../core/constant/firebase_collections.dart' as firebase_collections;
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text Editing Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Observable
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs; // ✅ TAMBAHAN - untuk toggle password visibility

  // Getter untuk current user
  User? get currentUser => firebaseUser.value;
  bool get isAuthenticated => firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    print('✅ AuthController onInit called');
    
    // Bind auth state changes
    firebaseUser.bindStream(_auth.authStateChanges());
    
    // Listen to user changes
    ever(firebaseUser, _handleAuthChanged);
  }

  @override
  void onReady() {
    super.onReady();
    print('✅ AuthController onReady called');
    
    // Load user data if already logged in
    if (currentUser != null) {
      loadUserData();
    }
  }

  /// ✅ TAMBAHAN - Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// Handle auth state changes
  void _handleAuthChanged(User? user) {
    if (user == null) {
      print('❌ User logged out');
      userModel.value = null;
    } else {
      print('✅ User logged in: ${user.email}');
      loadUserData();
    }
  }

  /// Load user data from Firestore
  Future<void> loadUserData() async {
    try {
      if (currentUser == null) {
        print('⚠️ Cannot load user data: no user logged in');
        return;
      }

      print('📥 Loading user data for: ${currentUser!.uid}');
      
      final userDoc = await _firestore
          .collection(firebase_collections.FirebaseCollections.users)
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        userModel.value = UserModel.fromFirestore(userDoc);
        print('✅ User data loaded: ${userModel.value?.displayName}');
      } else {
        print('⚠️ User document not found, creating new...');
        await createUserDocument();
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  /// Create user document in Firestore
  Future<void> createUserDocument() async {
    try {
      if (currentUser == null) return;

      final newUser = UserModel(
        userId: currentUser!.uid,
        email: currentUser!.email,
        displayName: currentUser!.displayName ?? 'User',
        photoURL: currentUser!.photoURL,
        points: 0,
        coins: 100,
        level: 1,
        currentStreak: 0,
        longestStreak: 0,
        enrolledCourses: [],
        completedQuizzes: [],
        createdAt: DateTime.now(),
        lastActiveDate: DateTime.now(),
      );

      await _firestore
          .collection(firebase_collections.FirebaseCollections.users)
          .doc(currentUser!.uid)
          .set(newUser.toMap());

      userModel.value = newUser;
      print('✅ User document created');
    } catch (e) {
      print('❌ Error creating user document: $e');
    }
  }

  /// ✅ TAMBAHAN - SignIn method (alias untuk login)
  Future<void> signIn() async {
    await login(emailController.text.trim(), passwordController.text.trim());
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    try {
      // Validation
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
        );
        return;
      }

      isLoading.value = true;
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Login successful: ${userCredential.user?.email}');
      
      // Clear text fields
      emailController.clear();
      passwordController.clear();
      
      // Navigate to main
      Get.offAllNamed(AppRoutes.MAIN);
    } on FirebaseAuthException catch (e) {
      print('❌ Login error: ${e.code}');
      
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many failed attempts. Please try again later';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      }
      
      Get.snackbar(
        'Login Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      print('❌ Unexpected login error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ TAMBAHAN - SignUp method
  Future<void> signUp() async {
    await register(
      emailController.text.trim(),
      passwordController.text.trim(),
      nameController.text.trim(),
    );
  }

  /// Register new user
  Future<void> register(String email, String password, String name) async {
    try {
      // Validation
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        Get.snackbar(
          'Error',
          'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
        );
        return;
      }

      if (password.length < 6) {
        Get.snackbar(
          'Error',
          'Password must be at least 6 characters',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
        );
        return;
      }

      isLoading.value = true;
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      
      print('✅ Registration successful: ${userCredential.user?.email}');
      
      // Create user document
      await createUserDocument();
      
      // Clear text fields
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      
      // Navigate to main
      Get.offAllNamed(AppRoutes.MAIN);
    } on FirebaseAuthException catch (e) {
      print('❌ Registration error: ${e.code}');
      
      String message = 'Registration failed';
      if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email already in use';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      }
      
      Get.snackbar(
        'Registration Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      print('❌ Unexpected registration error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      userModel.value = null;
      
      // Clear text fields
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      
      print('✅ Logout successful');
      
      // Navigate to login
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      print('❌ Logout error: $e');
      Get.snackbar(
        'Error',
        'Failed to logout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }

  /// ✅ TAMBAHAN - Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your email',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isLoading.value = true;
      
      await _auth.sendPasswordResetEmail(email: email);
      
      Get.snackbar(
        'Success',
        'Password reset email sent. Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
        duration: const Duration(seconds: 4),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send reset email';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      }
      
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    
    print('🔴 AuthController onClose called');
    super.onClose();
  }
}
