// File: lib/presentation/pages/settings/settings_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ==========================================
          // PROFILE SECTION
          // ==========================================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                final user = authController.userModel.value;
                final firebaseUser = authController.currentUser;
                
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        user?.displayName?.substring(0, 1).toUpperCase() ?? 
                        firebaseUser?.email?.substring(0, 1).toUpperCase() ?? 
                        'U',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? firebaseUser?.displayName ?? 'User',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      firebaseUser?.email ?? 'No email',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          context,
                          'Level',
                          '${user?.level ?? 1}',
                          Icons.stars_rounded,
                        ),
                        _buildStatItem(
                          context,
                          'Points',
                          '${user?.points ?? 0}',
                          Icons.emoji_events_rounded,
                        ),
                        _buildStatItem(
                          context,
                          'Coins',
                          '${user?.coins ?? 0}',
                          Icons.monetization_on_rounded,
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // ==========================================
          // ADMIN MENU - ✅ BARU
          // ==========================================
          Obx(() {
            final user = authController.userModel.value;
            final isAdmin = user?.isAdmin ?? false;
            
            if (!isAdmin) return const SizedBox.shrink();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ADMIN',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Admin Tools',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.quiz_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Manage Quizzes'),
                        subtitle: const Text('Create and edit quizzes'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Get.toNamed(AppRoutes.ADMIN_QUIZ);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.question_answer_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Manage Questions'),
                        subtitle: const Text('Create and edit questions'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Get.toNamed(AppRoutes.ADMIN_QUESTION);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),
          
          // ==========================================
          // ACCOUNT SETTINGS
          // ==========================================
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Edit profile feature will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Change password feature will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // ==========================================
          // APP SETTINGS
          // ==========================================
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      Get.snackbar(
                        'Coming Soon',
                        'Notification settings will be available soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: Get.isDarkMode,
                    onChanged: (value) {
                      Get.changeThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: const Text('Language'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Language settings will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // ==========================================
          // ABOUT & HELP
          // ==========================================
          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.snackbar(
                      'Help',
                      'Contact support at support@learningapp.com',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('About App'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Learning App',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.school_rounded, size: 48),
                      children: [
                        const Text(
                          'A gamified learning platform with courses, quizzes, and achievements.',
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.snackbar(
                      'Privacy',
                      'Privacy policy will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // ==========================================
          // LOGOUT BUTTON
          // ==========================================
          Obx(() => ElevatedButton.icon(
            onPressed: authController.isLoading.value 
                ? null 
                : () => _showLogoutDialog(context, authController),
            icon: authController.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
            label: Text(
              authController.isLoading.value ? 'Logging out...' : 'Logout',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 48),
            ),
          )),
          
          const SizedBox(height: 16),
          
          // Version info
          Center(
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?\nYou will need to login again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
