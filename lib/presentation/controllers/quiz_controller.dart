import 'dart:async';
import 'package:get/get.dart';
import 'package:learning_app/app/data/models/quiz_model.dart';
import 'package:learning_app/app/data/models/question_model.dart';
import 'package:learning_app/app/data/models/quiz_attempt_model.dart';
import 'package:learning_app/app/providers/quiz_provider.dart';
import 'package:learning_app/app/data/repositories/user_repository.dart';
import 'package:learning_app/app/routes/app_routes.dart';
import 'package:uuid/uuid.dart';
import 'auth_controller.dart';
import 'home_controller.dart'; // ✅ TAMBAH: Import HomeController
import '../pages/quiz/quiz_result_page.dart';

class QuizController extends GetxController {
  final QuizProvider _quizProvider = QuizProvider();
  final UserRepository _userRepository = UserRepository();

  // Observable lists
  final RxList<QuizModel> quizzes = <QuizModel>[].obs;
  final RxList<QuestionModel> questions = <QuestionModel>[].obs;
  final RxList<QuizAttemptModel> quizAttempts = <QuizAttemptModel>[].obs;

  // Selected quiz & attempt
  final Rx<QuizModel?> selectedQuiz = Rx<QuizModel?>(null);
  final Rx<QuizAttemptModel?> bestQuizAttempt = Rx<QuizAttemptModel?>(null);

  // Quiz state
  final RxInt currentQuestionIndex = 0.obs;
  final RxMap<String, String> userAnswers = <String, String>{}.obs;
  final RxBool isQuizStarted = false.obs;
  final RxInt remainingTime = 0.obs;

  // Filter state
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedDifficulty = 'All'.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Timer
  Timer? _quizTimer;

  @override
  void onInit() {
    super.onInit();
    loadQuizzes();
  }

  @override
  void onClose() {
    _quizTimer?.cancel();
    super.onClose();
  }

  /// Load all quizzes - ✅ FILTER HIDDEN QUIZZES
  Future<void> loadQuizzes() async {
    try {
      isLoading.value = true;
      final allQuizzes = await _quizProvider.getAllQuizzes();
      
      // ✅ Filter out hidden quizzes from user view
      quizzes.value = allQuizzes
          .where((quiz) => quiz.isHidden != true)
          .toList();
    } catch (e) {
      print('Error loading quizzes: $e');
      Get.snackbar(
        'Error',
        'Failed to load quizzes',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load quiz detail
  Future<void> loadQuizDetail(String quizId) async {
    try {
      isLoading.value = true;

      final quiz = await _quizProvider.getQuizById(quizId);
      if (quiz == null) {
        Get.snackbar('Error', 'Quiz not found');
        return;
      }
      
      // ✅ Check if quiz is hidden
      if (quiz.isHidden == true) {
        Get.snackbar(
          'Error',
          'This quiz is not available',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
        return;
      }
      
      selectedQuiz.value = quiz;

      final authController = Get.find<AuthController>();
      final user = authController.currentUser;

      if (user != null) {
        final attempts = await _quizProvider.getUserQuizAttempts(
          userId: user.uid,
          quizId: quizId,
        );
        quizAttempts.value = attempts;

        final best = await _quizProvider.getBestQuizAttempt(
          userId: user.uid,
          quizId: quizId,
        );
        bestQuizAttempt.value = best;
      }
    } catch (e) {
      print('Error loading quiz detail: $e');
      Get.snackbar(
        'Error',
        'Failed to load quiz details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Start quiz
  Future<void> startQuiz(String quizId) async {
    try {
      isLoading.value = true;

      if (selectedQuiz.value?.quizId != quizId) {
        await loadQuizDetail(quizId);
      }

      final quizQuestions = await _quizProvider.getQuizQuestions(quizId);
      if (quizQuestions.isEmpty) {
        Get.snackbar('Error', 'No questions available for this quiz');
        return;
      }

      questions.value = quizQuestions;
      currentQuestionIndex.value = 0;
      userAnswers.clear();
      isQuizStarted.value = true;

      final quiz = selectedQuiz.value;
      if (quiz != null && quiz.timeLimit > 0) {
        remainingTime.value = quiz.timeLimit;
        _startTimer();
      }
    } catch (e) {
      print('Error starting quiz: $e');
      Get.snackbar(
        'Error',
        'Failed to start quiz',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Start countdown timer
  void _startTimer() {
    _quizTimer?.cancel();
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;

        if (remainingTime.value == 60) {
          Get.snackbar(
            'Time Warning',
            'Only 1 minute remaining!',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
        }

        if (remainingTime.value == 0) {
          timer.cancel();
          Get.snackbar(
            'Time Up!',
            'Quiz will be submitted automatically',
            snackPosition: SnackPosition.TOP,
          );
          Future.delayed(const Duration(seconds: 1), () {
            submitQuiz();
          });
        }
      }
    });
  }

  /// Select answer for a question
  void selectAnswer(String questionId, String answer) {
    userAnswers[questionId] = answer;
  }

  /// Go to next question
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  /// Go to previous question
  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  /// Go to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      currentQuestionIndex.value = index;
    }
  }

  /// ✅ NEW: Check if user has ever passed this quiz before
  Future<bool> hasEverPassedQuiz(String userId, String quizId) async {
    try {
      final attempts = await _quizProvider.getUserQuizAttempts(
        userId: userId,
        quizId: quizId,
      );
      
      // Check if any previous attempt has isPassed = true
      return attempts.any((attempt) => attempt.isPassed == true);
    } catch (e) {
      print('Error checking previous passes: $e');
      return false;
    }
  }

  /// Submit quiz - ✅ UPDATED: Award rewards ONLY on FIRST PASS with detailed logging + reload user data
  Future<void> submitQuiz() async {
    try {
      isLoading.value = true;
      _quizTimer?.cancel();

      final quiz = selectedQuiz.value;
      if (quiz == null) return;

      final timeSpent = quiz.timeLimit > 0
          ? quiz.timeLimit - remainingTime.value
          : 0;

      int correctAnswers = 0;
      int wrongAnswers = 0;

      for (var question in questions) {
        final userAnswer = userAnswers[question.questionId];
        if (userAnswer != null &&
            userAnswer.toLowerCase().trim() ==
                question.correctAnswer.toLowerCase().trim()) {
          correctAnswers++;
        } else {
          wrongAnswers++;
        }
      }

      final totalQuestions = questions.length;
      final percentage = (correctAnswers / totalQuestions * 100);
      final score = percentage.round();

      final isPassed = score >= quiz.passingScore;

      final authController = Get.find<AuthController>();
      final user = authController.currentUser;

      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // ✅ NEW: Check if user has passed this quiz before
      print('🔍 Checking if user has passed quiz before...');
      final hasPassedBefore = await hasEverPassedQuiz(user.uid, quiz.quizId);
      print('📊 hasPassedBefore: $hasPassedBefore');
      
      // ✅ NEW: Award rewards ONLY if passing for the FIRST TIME
      final bool shouldAwardRewards = isPassed && !hasPassedBefore;
      print('🎁 shouldAwardRewards: $shouldAwardRewards (isPassed: $isPassed, hasPassedBefore: $hasPassedBefore)');
      
      final pointsEarned = shouldAwardRewards ? quiz.pointsReward : 0;
      final coinsEarned = shouldAwardRewards ? quiz.coinsReward : 0;
      
      print('💰 Calculated rewards: $pointsEarned points, $coinsEarned coins');

      final attempt = QuizAttemptModel(
        attemptId: const Uuid().v4(),
        userId: user.uid,
        quizId: quiz.quizId,
        userAnswers: Map<String, String>.from(userAnswers),
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        totalQuestions: totalQuestions,
        score: score,
        percentage: percentage,
        pointsEarned: pointsEarned,
        coinsEarned: coinsEarned,
        isPassed: isPassed,
        timeSpent: timeSpent,
        createdAt: DateTime.now(),
      );

      print('💾 Saving quiz attempt to Firestore...');
      await _quizProvider.saveQuizAttempt(attempt);
      print('✅ Quiz attempt saved successfully');

      // ✅ NEW: Update user stats ONLY if rewards are awarded
      if (shouldAwardRewards) {
        print('🎯 Updating user stats with rewards...');
        print('📍 User ID: ${user.uid}');
        print('⭐ Points to add: $pointsEarned');
        print('🪙 Coins to add: $coinsEarned');
        
        try {
          // Update points
          print('⏳ Calling updatePoints...');
          final pointsUpdated = await _userRepository.updatePoints(
            userId: user.uid,
            points: pointsEarned,
          );
          print('✅ updatePoints result: $pointsUpdated');
          
          // Update coins
          print('⏳ Calling updateCoins...');
          final coinsUpdated = await _userRepository.updateCoins(
            userId: user.uid,
            coins: coinsEarned,
          );
          print('✅ updateCoins result: $coinsUpdated');
          
          if (pointsUpdated && coinsUpdated) {
            print('🎉 REWARDS SUCCESSFULLY UPDATED!');
            print('✅ Total rewards earned: $pointsEarned points, $coinsEarned coins');
            
            // ✅ FIX: Reload user data to update UI
            print('🔄 Reloading user data to refresh UI...');
            await authController.loadUserData();
            print('✅ User data reloaded successfully');
            
            // ✅ TAMBAH: Force refresh HomeController juga
            try {
              final homeController = Get.find<HomeController>();
              print('🔄 Force reloading HomeController profile...');
              await homeController.forceReloadUserProfile();
              print('✅ HomeController profile reloaded successfully');
            } catch (e) {
              print('⚠️ HomeController not found (might not be initialized yet): $e');
            }
          } else {
            print('⚠️ WARNING: Some updates failed - points: $pointsUpdated, coins: $coinsUpdated');
          }
        } catch (e) {
          print('❌ ERROR updating rewards: $e');
          print('📍 Stack trace: ${StackTrace.current}');
        }
      } else if (isPassed && hasPassedBefore) {
        print('ℹ️ Quiz passed, but rewards already claimed on first pass');
      } else {
        print('❌ Quiz not passed, no rewards given');
      }

      // ✅ Use Get.off instead of Get.offNamed to keep MainPage stack
      Get.off(
        () => const QuizResultPage(),
        arguments: {
          'attempt': attempt,
          'quiz': quiz,
          'isFirstTimePass': shouldAwardRewards, // ✅ NEW: Track if this is first-time pass
        },
        routeName: AppRoutes.QUIZ_RESULT,
      );
    } catch (e) {
      print('❌ ERROR submitting quiz: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'Failed to submit quiz',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Retry quiz - ✅ Fixed to prevent controller disposal
  void retryQuiz(String quizId) {
    // Reset quiz state
    isQuizStarted.value = false;
    currentQuestionIndex.value = 0;
    userAnswers.clear();
    questions.clear();
    _quizTimer?.cancel();
    remainingTime.value = 0;

    // ✅ Navigate back to quiz play WITHOUT removing MainPage
    // This keeps QuizController alive
    Get.back(); // Close result page
    Get.toNamed(
      AppRoutes.QUIZ_SESSION,
      arguments: {'quizId': quizId},
    );
  }

  /// Filter quizzes by category
  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  /// Filter quizzes by difficulty
  void filterByDifficulty(String difficulty) {
    selectedDifficulty.value = difficulty;
  }

  /// Get filtered quizzes - ✅ ALREADY FILTERED HIDDEN
  List<QuizModel> get filteredQuizzes {
    var filtered = quizzes.toList();

    if (selectedCategory.value != 'All') {
      filtered = filtered
          .where((quiz) => quiz.category == selectedCategory.value)
          .toList();
    }

    if (selectedDifficulty.value != 'All') {
      filtered = filtered
          .where((quiz) => quiz.difficulty == selectedDifficulty.value)
          .toList();
    }

    return filtered;
  }

  /// Get quiz by ID
  QuizModel? getQuizById(String quizId) {
    try {
      return quizzes.firstWhere((quiz) => quiz.quizId == quizId);
    } catch (e) {
      return null;
    }
  }

  /// Check if all questions are answered
  bool get areAllQuestionsAnswered {
    return userAnswers.length == questions.length;
  }

  /// Get answered questions count
  int get answeredQuestionsCount {
    return userAnswers.length;
  }

  /// Get unanswered questions count
  int get unansweredQuestionsCount {
    return questions.length - userAnswers.length;
  }
}
