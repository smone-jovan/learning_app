import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../app/data/models/user_model.dart';
import '../../app/data/repositories/auth_repository.dart';
import '../../app/data/repositories/user_repository.dart';
import 'package:learning_app/app/data/services/local_storage_services.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  // Observable user
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  // UI State
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;

  // Getters
  User? get currentUser => firebaseUser.value;
  bool get isAuthenticated => firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    // Bind Firebase auth state
    firebaseUser.bindStream(_authRepository.authStateChanges);

    // Listen to user changes
    ever(firebaseUser, _onUserChanged);
  }

  void _onUserChanged(User? user) async {
    if (user != null) {
      // Fetch user data from Firestore
      final userData = await _userRepository.getUserById(user.uid);
      userModel.value = userData;

      // Save to local storage
      await LocalStorageService.write(
        LocalStorageService.keyIsLoggedIn,
        true,
      );
      await LocalStorageService.write(
        LocalStorageService.keyUserId,
        user.uid,
      );
    } else {
      userModel.value = null;
      await LocalStorageService.clearAll();
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      await _authRepository.signInWithEmailPassword(
        email: email,
        password: password,
      );

      // Navigate to main page
      Get.offAllNamed(AppRoutes.MAIN);
      
      Get.snackbar(
        'Success',
        'Welcome back!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }

      Get.snackbar(
        'Login Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Register with email and password
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      isLoading.value = true;

      await _authRepository.registerWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Navigate to main page
      Get.offAllNamed(AppRoutes.MAIN);
      
      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed';
      }

      Get.snackbar(
        'Registration Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      isLoading.value = true;

      await _authRepository.sendPasswordResetEmail(email: email);

      Get.back(); // Go back to login

      Get.snackbar(
        'Success',
        'Password reset link sent to your email',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = e.message ?? 'Failed to send reset link';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      Get.offAllNamed(AppRoutes.LOGIN);
      
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
