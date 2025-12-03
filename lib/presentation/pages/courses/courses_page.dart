
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';

/// Courses Page - Akan diimplementasi di TAHAP 4
class CoursesPage extends StatelessWidget {
const CoursesPage({super.key});
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.cream,
appBar: AppBar(
backgroundColor: AppColors.primary,
title: const Text('Courses'),
elevation: 0,
),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.school_rounded,
size: 80,
color: AppColors.textSecondary.withOpacity(0.5),
),
const SizedBox(height: 16),
Text(
'Courses Coming Soon',
style: Get.textTheme.titleLarge?.copyWith(
color: AppColors.textSecondary,
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 8),
Text(
'Will be implemented in TAHAP 4',
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