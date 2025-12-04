import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';
import 'package:learning_app/app/data/models/quiz_attempt_model.dart';
import 'package:learning_app/app/data/models/quiz_model.dart';
import 'package:learning_app/app/routes/app_routes.dart';
import '../../controllers/quiz_controller.dart';

class QuizResultPage extends GetView<QuizController> {
  const QuizResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get data from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final attempt = args?['attempt'] as QuizAttemptModel?;
    final quiz = args?['quiz'] as QuizModel?;
    final isFirstTimePass = args?['isFirstTimePass'] as bool? ?? false; // ✅ NEW

    if (attempt == null || quiz == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Results')),
        body: const Center(child: Text('Result not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Quiz Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Go back to quiz detail
            Get.until((route) => route.settings.name == AppRoutes.QUIZ_DETAIL);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Result Header - ✅ UPDATED with isFirstTimePass
            _buildResultHeader(attempt, isFirstTimePass),
            const SizedBox(height: 24),

            // Score Card
            _buildScoreCard(attempt),
            const SizedBox(height: 24),

            // Performance Stats
            _buildPerformanceStats(attempt),
            const SizedBox(height: 24),

            // Rewards Earned - ✅ UPDATED with isFirstTimePass
            _buildRewardsCard(attempt, isFirstTimePass),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(attempt, quiz),
          ],
        ),
      ),
    );
  }

  // ✅ UPDATED: Show different message for first-time pass
  Widget _buildResultHeader(QuizAttemptModel attempt, bool isFirstTimePass) {
    // Determine message based on pass status and first-time
    String title;
    String message;
    
    if (attempt.isPassed) {
      if (isFirstTimePass) {
        title = '🎉 Congratulations!';
        message = 'First time pass! You earned rewards!';
      } else {
        title = '✅ Passed Again!';
        message = 'Great job! (Rewards already claimed on first pass)';
      }
    } else {
      title = '💪 Keep Practicing!';
      message = 'You can retry to improve your score';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: attempt.isPassed
            ? const LinearGradient(
                colors: [AppColors.success, Color(0xFF22C55E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [AppColors.error, Color(0xFFF87171)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            attempt.isPassed
                ? (isFirstTimePass ? Icons.emoji_events_rounded : Icons.verified_rounded)
                : Icons.replay_rounded,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Get.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(QuizAttemptModel attempt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Score',
            style: Get.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: attempt.percentage / 100,
                  strokeWidth: 12,
                  backgroundColor: AppColors.textSecondary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    attempt.isPassed ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${attempt.score}%',
                    style: Get.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: attempt.isPassed
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  Text(
                    attempt.isPassed ? 'Passed' : 'Failed',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats(QuizAttemptModel attempt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analysis',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatRow(
            Icons.check_circle,
            'Correct Answers',
            '${attempt.correctAnswers}',
            AppColors.success,
          ),
          const Divider(height: 24),
          _buildStatRow(
            Icons.cancel,
            'Wrong Answers',
            '${attempt.wrongAnswers}',
            AppColors.error,
          ),
          const Divider(height: 24),
          _buildStatRow(
            Icons.timer_outlined,
            'Time Spent',
            '${attempt.timeSpent ~/ 60}m ${attempt.timeSpent % 60}s',
            AppColors.primary,
          ),
          const Divider(height: 24),
          _buildStatRow(
            Icons.help_outline,
            'Accuracy',
            '${((attempt.correctAnswers / attempt.totalQuestions) * 100).toStringAsFixed(1)}%',
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Get.textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ✅ UPDATED: Show reward status clearly
  Widget _buildRewardsCard(QuizAttemptModel attempt, bool isFirstTimePass) {
    // Determine if rewards were actually awarded (non-zero)
    final bool hasRewards = attempt.pointsEarned > 0 || attempt.coinsEarned > 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasRewards 
            ? AppColors.gold.withOpacity(0.1)
            : AppColors.textSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasRewards
              ? AppColors.gold.withOpacity(0.3)
              : AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                hasRewards ? Icons.card_giftcard_rounded : Icons.info_outline,
                color: hasRewards ? AppColors.gold : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                hasRewards ? 'Rewards Earned' : 'Rewards Status',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasRewards ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Show different UI based on reward status
          if (hasRewards)
            // Show earned rewards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRewardItem(
                  Icons.star_rounded,
                  '${attempt.pointsEarned}',
                  'Points',
                  AppColors.gold,
                ),
                _buildRewardItem(
                  Icons.monetization_on_rounded,
                  '${attempt.coinsEarned}',
                  'Coins',
                  AppColors.orange,
                ),
              ],
            )
          else
            // Show message for no rewards
            Text(
              attempt.isPassed 
                  ? 'Rewards already claimed on first pass ✅'
                  : 'Pass the quiz to earn rewards!',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(QuizAttemptModel attempt, QuizModel quiz) {
    return Column(
      children: [
        // Review Answers Button (Optional - can be implemented later)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Answer review will be available soon',
              );
            },
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Review Answers'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Retry Quiz Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Retry quiz
              controller.retryQuiz(quiz.quizId);
            },
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Retry Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Back to Quiz List
        TextButton(
          onPressed: () {
            Get.until((route) => route.settings.name == AppRoutes.QUIZ_DETAIL);
          },
          child: const Text('Back to Quiz Details'),
        ),
      ],
    );
  }
}
