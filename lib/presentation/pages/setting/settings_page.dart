// File: lib/presentation/pages/settings/settings_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../../app/routes/app_routes.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final settingsController = Get.find<SettingsController>();

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
          // ADMIN MENU
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
                  subtitle: const Text('Update your name and email'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.to(() => const EditProfilePage());
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account password'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.to(() => const ChangePasswordPage());
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Reset Password via Email'),
                  subtitle: const Text('Send password reset link'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _showResetPasswordDialog(context, authController);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // ==========================================
          // APP SETTINGS - UPDATED
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
                // ✅ NOTIFICATIONS - WORKING NOW
                Obx(() => SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: Text(
                    settingsController.notificationsEnabled.value
                        ? 'Enabled'
                        : 'Disabled',
                  ),
                  value: settingsController.notificationsEnabled.value,
                  onChanged: (value) {
                    settingsController.setNotificationEnabled(value);
                  },
                )),
                const Divider(height: 1),
                
                // ✅ THEME MODE - WORKING NOW
                Obx(() => SwitchListTile(
                  secondary: Icon(
                    settingsController.themeMode.value == ThemeMode.dark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  title: const Text('Follow System Theme'),
                  subtitle: Text(
                    settingsController.followSystemTheme.value
                        ? 'Using system preference'
                        : 'Manual override active',
                  ),
                  value: settingsController.followSystemTheme.value,
                  onChanged: (value) {
                    settingsController.setFollowSystem(value);
                  },
                )),
                
                // ✅ MANUAL DARK MODE TOGGLE (only show if not following system)
                Obx(() {
                  if (settingsController.followSystemTheme.value) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.dark_mode_rounded),
                        title: const Text('Dark Mode'),
                        subtitle: Text(
                          settingsController.themeMode.value == ThemeMode.dark
                              ? 'Dark theme active'
                              : 'Light theme active',
                        ),
                        value: settingsController.themeMode.value == ThemeMode.dark,
                        onChanged: (value) {
                          settingsController.toggleDarkMode(value);
                        },
                      ),
                    ],
                  );
                }),
                
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: const Text('Language'),
                  subtitle: const Text('English (Default)'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Multi-language support will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // ==========================================
          // ABOUT & HELP - UPDATED
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
                // ✅ HELP & SUPPORT - WORKING NOW
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text('Help & Support'),
                  subtitle: const Text('Report issues on GitHub'),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () => _openGitHubIssues(),
                ),
                const Divider(height: 1),
                
                // ✅ VIEW REPOSITORY
                ListTile(
                  leading: const Icon(Icons.code_rounded),
                  title: const Text('View Repository'),
                  subtitle: const Text('Open source on GitHub'),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () => _openGitHubRepo(),
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
                        const SizedBox(height: 16),
                        const Text('Made with ❤️ using Flutter & Firebase'),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.code),
                          label: const Text('View on GitHub'),
                          onPressed: () => _openGitHubRepo(),
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

  // ✅ HELPER METHODS FOR GITHUB
  Future<void> _openGitHubRepo() async {
    final url = Uri.parse('https://github.com/smone-jovan/learning_app');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open GitHub repository',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _openGitHubIssues() async {
    final url = Uri.parse('https://github.com/smone-jovan/learning_app/issues');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open GitHub issues',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showResetPasswordDialog(BuildContext context, AuthController authController) {
    final emailController = TextEditingController(
      text: authController.currentUser?.email ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A password reset link will be sent to your email.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              emailController.dispose();
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              emailController.dispose();
              Get.back();
              authController.resetPassword(email);
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
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
