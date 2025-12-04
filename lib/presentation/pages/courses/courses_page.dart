import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';
import 'package:learning_app/app/data/models/course_model.dart';
import '../../controllers/course_controller.dart';

class CoursesPage extends GetView<CourseController> {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Initialize controller if not exists
    Get.put(CourseController());
    
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Courses'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      body: Obx(() {
        // 🆕 FIX: Check loading state dengan condition untuk avoid double indicator
        if (controller.isLoading.value && !controller.isRefreshing.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 🆕 FIX: Empty state wrapped dengan RefreshIndicator agar bisa pull
        if (controller.courses.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refreshCourses, // 🆕 Method baru
            child: ListView( // 🆕 WRAP dengan ListView untuk enable scroll
              physics: const AlwaysScrollableScrollPhysics(), // 🆕 CRITICAL
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
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
                          'No Courses Available',
                          style: Get.textTheme.titleLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 🆕 FIX: Update onRefresh method
        return RefreshIndicator(
          onRefresh: controller.refreshCourses, // 🆕 Ganti dari loadCourses ke refreshCourses
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(), // 🆕 TAMBAH ini
            padding: const EdgeInsets.all(16),
            itemCount: controller.filteredCourses.length,
            itemBuilder: (context, index) {
              final course = controller.filteredCourses[index];
              return _CourseCard(course: course);
            },
          ),
        );
      }),
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Courses',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Category Filter
            Text(
              'Category',
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['All', 'Flutter', 'Dart', 'Firebase', 'UI/UX', 'Backend']
                  .map((category) => Obx(() => FilterChip(
                        label: Text(category),
                        selected: controller.selectedCategory.value == category,
                        onSelected: (selected) {
                          controller.filterByCategory(
                            selected ? category : 'All',
                          );
                        },
                      )))
                  .toList(),
            ),
            const SizedBox(height: 24),
            
            // Level Filter
            Text(
              'Level',
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['All', 'Beginner', 'Intermediate', 'Advanced']
                  .map((level) => Obx(() => FilterChip(
                        label: Text(level),
                        selected: controller.selectedLevel.value == level,
                        onSelected: (selected) {
                          controller.filterByLevel(
                            selected ? level : 'All',
                          );
                        },
                      )))
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to course detail when implemented
        Get.snackbar(
          'Course',
          'Course detail will be available soon',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Course Image
            if (course.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  course.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                ),
              )
            else
              _buildPlaceholderImage(),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      _Badge(
                        label: course.category,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _Badge(
                        label: course.level,
                        color: _getLevelColor(course.level),
                      ),
                      const Spacer(),
                      if (course.isPremium)
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.gold,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    course.title,
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    course.description,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Course Info
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.video_library_outlined,
                        label: '${course.lessonsCount} Lessons',
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.access_time_outlined,
                        label: '${course.duration} min',
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.gold,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.pointsReward}',
                            style: Get.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.school_rounded,
          size: 60,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Get.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Get.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
