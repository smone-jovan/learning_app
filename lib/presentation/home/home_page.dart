import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';
import 'package:learning_app/presentation/controllers/home_controller.dart';
import 'package:learning_app/app/routes/app_routes.dart';

/// Home Page - Advanced gamified dashboard
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      // ❌ HAPUS AppBar - sudah ada di MainPage
      body: Obx(
        () => controller.isLoading.value
            ? _buildLoadingState()
            : RefreshIndicator(
                onRefresh: () => controller.refreshDashboard(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreetingSection(),
                      const SizedBox(height: 24),
                      _buildStatsCards(),
                      const SizedBox(height: 24),
                      _buildStreakCard(),
                      const SizedBox(height: 24),
                      _buildDailyChallengeCard(),
                      const SizedBox(height: 24),
                      _buildLevelProgressCard(),
                      const SizedBox(height: 24),
                      _buildQuickAccessMenu(),
                      const SizedBox(height: 24),
                      // Contoh Card
                      Card(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.quiz, color: Colors.orange),
                          title: const Text('Quizzes'),
                          subtitle: const Text('Test your knowledge'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () {
                            Get.toNamed(AppRoutes.QUIZZES);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildOngoingCourses(),
                      const SizedBox(height: 24),
                      _buildNextAchievementCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// ========== LOADING STATE ==========
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your dashboard...',
            style: Get.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// ========== GREETING SECTION WITH EMOJI ==========
  Widget _buildGreetingSection() {
    return Obx(() {
      final user = controller.userModel.value;
      final greeting = controller.getGreetingEmoji();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ V2 Feature: Dynamic greeting with emoji
          Row(
            children: [
              Text(
                greeting,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTimeBasedGreeting(),
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.displayName ?? 'Learner',
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ✅ Streak message as subtext
          Text(
            controller.getStreakMessage(),
            style: Get.textTheme.bodySmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    });
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  /// ========== STATS CARDS (Points, Coins, Level) ==========
  Widget _buildStatsCards() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.star_rounded,
              label: 'Points',
              value: controller.userModel.value?.points.toString() ?? '0',
              color: Colors.amber,
              trend: '+50',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.monetization_on_rounded,
              label: 'Coins',
              value: controller.userModel.value?.coins.toString() ?? '0',
              color: Colors.orange,
              trend: '+10',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.auto_awesome_rounded,
              label: 'Level',
              value: controller.userModel.value?.level.toString() ?? '1',
              color: Colors.deepPurple,
              trend: '',
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          // ✅ Trend indicator
          if (trend.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                trend,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ========== STREAK CARD (Enhanced) ==========
  Widget _buildStreakCard() {
    return Obx(() {
      final streak = controller.userModel.value?.currentStreak ?? 0;
      final longestStreak = controller.userModel.value?.longestStreak ?? 0;
      final isActive = controller.hasActiveStreak();

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.9 + (value * 0.1),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isActive
                  ? [Colors.orange.shade400, Colors.deepOrange.shade600]
                  : [Colors.grey.shade400, Colors.grey.shade600],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ✅ Animated fire icon
              Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streak Day Streak!',
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Longest: $longestStreak days',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ✅ Progress bar for current streak
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (streak / longestStreak.clamp(1, double.infinity)),
                        minHeight: 4,
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// ========== DAILY CHALLENGE CARD (Enhanced) ==========
  Widget _buildDailyChallengeCard() {
    return Obx(() {
      final dailyQuiz = controller.dailyChallenge.value;
      final isCompleted = dailyQuiz?.isPremium ?? false;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCompleted
                ? [Colors.green.shade400, Colors.green.shade600]
                : [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isCompleted ? 'Challenge Completed!' : 'Daily Challenge',
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // ✅ Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCompleted ? '+100 XP' : 'In Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dailyQuiz?.title ?? 'Complete today\'s challenge',
              style: Get.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            if (dailyQuiz?.description != null) ...[
              const SizedBox(height: 8),
              Text(
                dailyQuiz!.description,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCompleted
                    ? null
                    : () {
                        if (dailyQuiz != null) {
                          controller.startQuiz(dailyQuiz.quizId);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.white30,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Start Challenge',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// ========== LEVEL PROGRESS CARD (NEW) ==========
  Widget _buildLevelProgressCard() {
    return Obx(() {
      final user = controller.userModel.value;
      final currentLevel = user?.level ?? 'Beginner';
      final nextLevelPoints = _getNextLevelPoints(user?.points ?? 0);
      final progress = ((user?.points ?? 0) % 500) / 500;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level Progress',
                  style: Get.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.getLevelColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentLevel.toString(),
                    style: TextStyle(
                      color: controller.getLevelColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.textSecondary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(
                  controller.getLevelColor(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(user?.points ?? 0) % 500} / 500 XP',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$nextLevelPoints XP to next level',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  int _getNextLevelPoints(int currentPoints) {
    final nextLevel = (currentPoints / 500).ceil() * 500;
    return (nextLevel - (currentPoints % 500)).toInt();
  }

  /// ========== QUICK ACCESS MENU ==========
  Widget _buildQuickAccessMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.quiz_outlined,
                label: 'Quizzes',
                color: Colors.blue,
                onTap: controller.navigateToQuizList,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.school_outlined,
                label: 'Courses',
                color: Colors.teal,
                onTap: () => Get.toNamed('/courses'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.emoji_events_outlined,
                label: 'Achievements',
                color: Colors.purple,
                onTap: controller.navigateToAchievements,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.leaderboard_outlined,
                label: 'Leaderboard',
                color: Colors.orange,
                onTap: controller.navigateToLeaderboard,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ========== ONGOING COURSES ==========
  Widget _buildOngoingCourses() {
    return Obx(() {
      final courses = controller.recommendedCourses;
      
      if (courses.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue Learning',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final course = courses[index];
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${index + 1}/${courses.length}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 0.5,
                              minHeight: 6,
                              backgroundColor: AppColors.textSecondary
                                  .withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '50%',
                          style: Get.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    });
  }

  /// ========== NEXT ACHIEVEMENT CARD (NEW) ==========
  Widget _buildNextAchievementCard() {
    return Obx(() {
      final nextHint = controller.getNextAchievementHint();
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.pink.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Achievement',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextHint,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
            ),
          ],
        ),
      );
    });
  }
}
