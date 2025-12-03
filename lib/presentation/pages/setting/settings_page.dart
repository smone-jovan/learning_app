import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Account Settings'),
              subtitle: const Text('Manage your account'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.snackbar('Info', 'Account Settings Coming Soon');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notifications'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.snackbar('Info', 'Notifications Settings Coming Soon');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy'),
              subtitle: const Text('Privacy settings'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.snackbar('Info', 'Privacy Settings Coming Soon');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.snackbar('Info', 'Help Coming Soon');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              subtitle: const Text('About this app'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Get.snackbar(
                  'About',
                  'Learning App v1.0\nPowered by Flutter & Firebase',
                );
              },
            ),
            const Divider(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () {
                  Get.snackbar('Info', 'Logout Coming Soon');
                  // TODO: Implement logout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
