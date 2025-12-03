import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';

/// Leaderboard Page - Akan diimplementasi di TAHAP 7
class LeaderboardPage extends StatelessWidget {
const LeaderboardPage({super.key});
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.cream,
appBar: AppBar(
backgroundColor: AppColors.primary,
title: const Text('Leaderboard'),
elevation: 0,
),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.leaderboard_rounded,
size: 80,
color: AppColors.textSecondary.withOpacity(0.5),
),
const SizedBox(height: 16),
Text(
'Leaderboard Coming Soon',
style: Get.textTheme.titleLarge?.copyWith(
color: AppColors.textSecondary,
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 8),
Text(
'Will be implemented in TAHAP 7',
style: Get.textTheme.bodyMedium?.copyWith(
color: AppColors.textSecondary,
),
),
],
),
),
);
}
}
