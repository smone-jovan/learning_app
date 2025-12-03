import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase_options.dart'; // ✅ ADD THIS

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== INITIALIZATION ====================

  /// Initialize Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform, // ✅ USE THIS
      );
    } catch (e) {
      throw Exception('Failed to initialize Firebase: $e');
    }
  }

  // ==================== AUTH METHODS ====================

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Get current user UID
  String? getCurrentUserUID() {
    return _auth.currentUser?.uid;
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Register user with email and password
  Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName,
        'displayName': fullName.split(' ')[0],
        'photoURL': '',
        'points': 0,
        'coins': 0,
        'level': 1,
        'streak': 0,
        'longestStreak': 0,
        'totalXP': 0,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      print('✅ User registered: $email');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Registration error: ${e.message}');
      rethrow;
    }
  }

  /// Login user with email and password
  Future<UserCredential?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ User logged in: $email');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Login error: ${e.message}');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
      print('✅ User logged out');
    } catch (e) {
      print('❌ Logout error: $e');
      rethrow;
    }
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // ==================== USER PROFILE METHODS ====================

  /// Get user profile
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      print('✅ User profile fetched: $uid');
      return doc;
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      rethrow;
    }
  }

  /// Stream of user profile (real-time updates)
  Stream<DocumentSnapshot> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': Timestamp.now(),
      });
      print('✅ User profile updated');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update user points
  Future<void> updateUserPoints(String uid, int points) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final currentPoints = userDoc.get('points') ?? 0;

      await _firestore.collection('users').doc(uid).update({
        'points': currentPoints + points,
        'updatedAt': Timestamp.now(),
      });
      print('✅ Points updated: +$points');
    } catch (e) {
      print('❌ Error updating points: $e');
      rethrow;
    }
  }

  /// Update user coins
  Future<void> updateUserCoins(String uid, int coins) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final currentCoins = userDoc.get('coins') ?? 0;

      await _firestore.collection('users').doc(uid).update({
        'coins': currentCoins + coins,
        'updatedAt': Timestamp.now(),
      });
      print('✅ Coins updated: +$coins');
    } catch (e) {
      print('❌ Error updating coins: $e');
      rethrow;
    }
  }

  /// Update user level
  Future<void> updateUserLevel(String uid, int level) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'level': level,
        'updatedAt': Timestamp.now(),
      });
      print('✅ Level updated: $level');
    } catch (e) {
      print('❌ Error updating level: $e');
      rethrow;
    }
  }

  /// Update streak
  Future<void> updateStreak(String uid, int streak, int longestStreak) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'streak': streak,
        'longestStreak': longestStreak,
        'updatedAt': Timestamp.now(),
      });
      print('✅ Streak updated');
    } catch (e) {
      print('❌ Error updating streak: $e');
      rethrow;
    }
  }

  // ==================== COURSES METHODS ====================

  /// Get all courses
  Future<List<DocumentSnapshot>> getCourses() async {
    try {
      final querySnapshot = await _firestore.collection('courses').get();
      print('✅ Courses fetched: ${querySnapshot.docs.length}');
      return querySnapshot.docs;
    } catch (e) {
      print('❌ Error fetching courses: $e');
      rethrow;
    }
  }

  /// Stream of courses (real-time updates)
  Stream<QuerySnapshot> getCoursesStream() {
    return _firestore.collection('courses').snapshots();
  }

  /// Get single course
  Future<DocumentSnapshot> getCourse(String courseId) async {
    try {
      final doc = await _firestore.collection('courses').doc(courseId).get();
      print('✅ Course fetched: $courseId');
      return doc;
    } catch (e) {
      print('❌ Error fetching course: $e');
      rethrow;
    }
  }

  /// Enroll user in course
  Future<void> enrollInCourse(String uid, String courseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('enrolledCourses')
          .doc(courseId)
          .set({
        'courseId': courseId,
        'enrolledAt': Timestamp.now(),
        'progress': 0,
        'completed': false,
      });
      print('✅ Enrolled in course: $courseId');
    } catch (e) {
      print('❌ Error enrolling in course: $e');
      rethrow;
    }
  }

  // ==================== QUIZ METHODS ====================

  /// Get all quizzes
  Future<List<DocumentSnapshot>> getQuizzes() async {
    try {
      final querySnapshot = await _firestore.collection('quizzes').get();
      print('✅ Quizzes fetched: ${querySnapshot.docs.length}');
      return querySnapshot.docs;
    } catch (e) {
      print('❌ Error fetching quizzes: $e');
      rethrow;
    }
  }

  /// Stream of quizzes
  Stream<QuerySnapshot> getQuizzesStream() {
    return _firestore.collection('quizzes').snapshots();
  }

  /// Get quiz by ID
  Future<DocumentSnapshot> getQuiz(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();
      print('✅ Quiz fetched: $quizId');
      return doc;
    } catch (e) {
      print('❌ Error fetching quiz: $e');
      rethrow;
    }
  }

  /// Get daily challenge
  Future<DocumentSnapshot?> getDailyChallenge() async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final querySnapshot = await _firestore
          .collection('quizzes')
          .where('isDailyChallenge', isEqualTo: true)
          .where('date', isEqualTo: dateStr)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('✅ Daily challenge fetched');
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('❌ Error fetching daily challenge: $e');
      rethrow;
    }
  }

  /// Save quiz attempt
  Future<void> saveQuizAttempt(
    String uid,
    String quizId,
    Map<String, dynamic> attempt,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('quizAttempts')
          .add({
        'quizId': quizId,
        ...attempt,
        'createdAt': Timestamp.now(),
      });
      print('✅ Quiz attempt saved');
    } catch (e) {
      print('❌ Error saving quiz attempt: $e');
      rethrow;
    }
  }

  /// Get user quiz attempts
  Future<List<DocumentSnapshot>> getUserQuizAttempts(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('quizAttempts')
          .orderBy('createdAt', descending: true)
          .get();
      print('✅ Quiz attempts fetched: ${querySnapshot.docs.length}');
      return querySnapshot.docs;
    } catch (e) {
      print('❌ Error fetching quiz attempts: $e');
      rethrow;
    }
  }

  // ==================== LEADERBOARD METHODS ====================

  /// Get leaderboard (top users by points)
  Stream<QuerySnapshot> getLeaderboard({int limit = 100}) {
    return _firestore
        .collection('users')
        .orderBy('points', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Get leaderboard with pagination
  Future<List<DocumentSnapshot>> getLeaderboardPage(int page,
      {int pageSize = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .limit(pageSize * page)
          .get();

      final startIndex = pageSize * (page - 1);
      final endIndex = startIndex + pageSize > querySnapshot.docs.length
          ? querySnapshot.docs.length
          : startIndex + pageSize;

      print('✅ Leaderboard page fetched: page $page');
      return querySnapshot.docs.sublist(startIndex, endIndex);
    } catch (e) {
      print('❌ Error fetching leaderboard page: $e');
      rethrow;
    }
  }

  /// Get user rank
  Future<int> getUserRank(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userPoints = userDoc.get('points') ?? 0;

      final higherScores = await _firestore
          .collection('users')
          .where('points', isGreaterThan: userPoints)
          .count()
          .get();

      // ✅ FIX: Handle null value dengan ?? 0
      final rank = ((higherScores.count) ?? 0) + 1;
      print('✅ User rank fetched: $rank');
      return rank;
    } catch (e) {
      print('❌ Error fetching user rank: $e');
      rethrow;
    }
  }

  // ==================== ACHIEVEMENTS METHODS ====================

  /// Get all achievements
  Future<List<DocumentSnapshot>> getAllAchievements() async {
    try {
      final querySnapshot =
          await _firestore.collection('achievements').get();
      print('✅ Achievements fetched: ${querySnapshot.docs.length}');
      return querySnapshot.docs;
    } catch (e) {
      print('❌ Error fetching achievements: $e');
      rethrow;
    }
  }

  /// Get user achievements
  Future<List<DocumentSnapshot>> getUserAchievements(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievements')
          .get();
      print('✅ User achievements fetched: ${querySnapshot.docs.length}');
      return querySnapshot.docs;
    } catch (e) {
      print('❌ Error fetching user achievements: $e');
      rethrow;
    }
  }

  /// Add achievement to user
  Future<void> addAchievement(
    String uid,
    String achievementId,
    Map<String, dynamic> achievementData,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievements')
          .doc(achievementId)
          .set({
        ...achievementData,
        'unlockedAt': Timestamp.now(),
      });
      print('✅ Achievement unlocked: $achievementId');
    } catch (e) {
      print('❌ Error adding achievement: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if collection exists (has documents)
  Future<bool> collectionExists(String collectionPath) async {
    try {
      final querySnapshot =
          await _firestore.collection(collectionPath).limit(1).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Seed sample data for testing
  Future<void> seedSampleData() async {
    try {
      // Check if already seeded
      final coursesExist = await collectionExists('courses');
      if (coursesExist) {
        print('⚠️  Sample data already exists');
        return;
      }

      // Add sample courses
      await _firestore.collection('courses').doc('course_1').set({
        'title': 'Flutter Basics',
        'description': 'Learn Flutter fundamentals',
        'category': 'Mobile Development',
        'level': 'Beginner',
        'totalLessons': 10,
        'totalDuration': 300,
        'rating': 4.8,
        'createdAt': Timestamp.now(),
      });

      // Add sample quizzes
      await _firestore.collection('quizzes').doc('quiz_1').set({
        'title': 'Flutter Quiz 1',
        'description': 'Test your Flutter knowledge',
        'totalQuestions': 10,
        'isDailyChallenge': true,
        'date': DateTime.now().toString().split(' ')[0],
        'createdAt': Timestamp.now(),
      });

      print('✅ Sample data seeded successfully');
    } catch (e) {
      print('❌ Error seeding sample data: $e');
      rethrow;
    }
  }
}
