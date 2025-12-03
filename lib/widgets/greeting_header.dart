import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';

class GreetingHeader extends StatelessWidget {
  final String userName;
  final String rank;

  const GreetingHeader({
    super.key,
    required this.userName,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // Rank Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getRankColor(rank).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getRankColor(rank)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: _getRankColor(rank),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                rank,
                style: TextStyle(
                  color: _getRankColor(rank),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRankColor(String rank) {
    switch (rank.toLowerCase()) {
      case 'platinum':
        return AppColors.platinum;
      case 'gold':
        return AppColors.gold;
      case 'silver':
        return AppColors.silver;
      case 'bronze':
      default:
        return AppColors.bronze;
    }
  }
}
