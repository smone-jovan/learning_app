import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';
import 'package:learning_app/core/utils/date_formatter.dart';
import 'package:learning_app/app/routes/app_routes.dart';
import '../../controllers/quiz_controller.dart';
import 'package:learning_app/core/extensions/date_extension.dart';

class QuizDetailPage extends GetView<QuizController> {
  const QuizDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get quiz ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final quizId = args?['quizId'] as String?;

    if (quizId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Details')),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    // Load quiz details
    controller.loadQuizDetail(quizId);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final quiz = controller.selectedQuiz.value;
        if (quiz == null) {
          return const Center(child: Text('Quiz not found'));
        }

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  quiz.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.quiz_rounded,
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges Row
                    Row(
                      children: [
                        _Badge(
                          label: quiz.category,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        _Badge(
                          label: quiz.difficulty,
                          color: _getDifficultyColor(quiz.difficulty),
                        ),
                        if (quiz.isPremium) ...[
                          const SizedBox(width: 8),
                          _Badge(
                            label: 'Premium',
                            color: AppColors.gold,
                            icon: Icons.workspace_premium_rounded,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'About This Quiz',
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quiz.description,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quiz Info
                    _InfoSection(
                      children: [
                        _InfoItem(
                          icon: Icons.quiz_outlined,
                          label: 'Questions',
                          value: '${quiz.totalQuestions}',
                        ),
                        _InfoItem(
                          icon: Icons.timer_outlined,
                          label: 'Time Limit',
                          value: quiz.timeLimit > 0
                              ? '${quiz.timeLimit ~/ 60} min'
                              : 'Unlimited',
                        ),
                        _InfoItem(
                          icon: Icons.check_circle_outline,
                          label: 'Passing Score',
                          value: '${quiz.passingScore}%',
                        ),
                        _InfoItem(
                          icon: Icons.star_outline,
                          label: 'Points',
                          value: '+${quiz.pointsReward}',
                          valueColor: AppColors.gold,
                        ),
                        _InfoItem(
                          icon: Icons.monetization_on_outlined,
                          label: 'Coins',
                          value: '+${quiz.coinsReward}',
                          valueColor: AppColors.orange,
                        ),
                        _InfoItem(
                          icon: Icons.people_outline,
                          label: 'Attempts',
                          value: '${quiz.totalAttempts}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Best Score (if available)
                    Obx(() {
                      final bestAttempt = controller.bestQuizAttempt.value;
                      if (bestAttempt != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Best Score',
                              style: Get.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: bestAttempt.isPassed
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: bestAttempt.isPassed
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    bestAttempt.isPassed
                                        ? Icons.emoji_events_rounded
                                        : Icons.trending_up_rounded,
                                    color: bestAttempt.isPassed
                                        ? AppColors.success
                                        : AppColors.warning,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${bestAttempt.score}%',
                                          style: Get.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: bestAttempt.isPassed
                                                ? AppColors.success
                                                : AppColors.warning,
                                          ),
                                        ),
                                        Text(
                                          '${bestAttempt.correctAnswers}/${bestAttempt.totalQuestions} correct',
                                          style:
                                              Get.textTheme.bodySmall?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            color: AppColors.gold,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '+${bestAttempt.pointsEarned}',
                                            style: Get.textTheme.bodySmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormatter.format(
                                          bestAttempt.createdAt,
                                          pattern: 'dd MMM yyyy',
                                        ),
                                        style:
                                            Get.textTheme.labelSmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // Recent Attempts
                    Obx(() {
                      final attempts = controller.quizAttempts;
                      if (attempts.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Attempts',
                              style: Get.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...attempts.take(5).map((attempt) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      attempt.isPassed
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: attempt.isPassed
                                          ? AppColors.success
                                          : AppColors.error,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${attempt.score}% - ${attempt.correctAnswers}/${attempt.totalQuestions}',
                                            style: Get.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            attempt.createdAt.timeAgo,
                                            style: Get.textTheme.labelSmall
                                                ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: AppColors.gold,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+${attempt.pointsEarned}',
                                          style: Get.textTheme.bodySmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // Bottom spacing for button
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // Start Quiz Button
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to quiz play
                  Get.toNamed(
                    AppRoutes.QUIZ_SESSION,
                    arguments: {'quizId': quizId},
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

// Helper Widgets
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Badge({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Get.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final List<Widget> children;

  const _InfoSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: children
            .expand((child) => [child, const Divider(height: 24)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
