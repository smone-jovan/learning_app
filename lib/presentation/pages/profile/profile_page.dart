import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';

/// Profile Page - Akan diimplementasi di TAHAP 8
class ProfilePage extends StatelessWidget {
const ProfilePage({super.key});
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.cream,
appBar: AppBar(
backgroundColor: AppColors.primary,
title: const Text('Profile'),
elevation: 0,
),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.person_rounded,
size: 80,
color: AppColors.textSecondary.withOpacity(0.5),
),
const SizedBox(height: 16),
Text(
'Profile Coming Soon',
style: Get.textTheme.titleLarge?.copyWith(
color: AppColors.textSecondary,
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 8),
Text(
'Will be implemented in TAHAP 8',
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