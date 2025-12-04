import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';
import 'package:learning_app/app/routes/app_routes.dart';

class QuickAccessMenu extends StatelessWidget {
  const QuickAccessMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickAccessItem(
                icon: Icons.quiz_rounded,
                label: 'Quiz',
                color: AppColors.primary,
                onTap: () => Get.toNamed(AppRoutes.QUIZZES),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAccessItem(
                icon: Icons.school_rounded,
                label: 'Courses',
                color: AppColors.orange,
                onTap: () => Get.toNamed(AppRoutes.COURSES),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAccessItem(
                icon: Icons.emoji_events_rounded,
                label: 'Achievements',
                color: AppColors.gold,
                onTap: () => Get.toNamed(AppRoutes.ACHIEVEMENTS),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAccessItem(
                icon: Icons.leaderboard_rounded,
                label: 'Leaderboard',
                color: AppColors.success,
                onTap: () => Get.toNamed(AppRoutes.LEADERBOARD),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Get.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
