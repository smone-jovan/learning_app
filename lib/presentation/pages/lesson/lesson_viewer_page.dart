import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:learning_app/app/data/services/firebase_service.dart';

class LessonViewerPage extends StatefulWidget {
  const LessonViewerPage({super.key});

  @override
  State<LessonViewerPage> createState() => _LessonViewerPageState();
}

class _LessonViewerPageState extends State<LessonViewerPage> {
  final FirebaseService _fs = FirebaseService();
  bool _loading = false;
  String? _error;
  int _coursesCount = 0;

  @override
  void initState() {
    super.initState();
    _checkFirestoreAccess();
  }

  Future<void> _checkFirestoreAccess() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final docs = await _fs.getCourses();
      setState(() {
        _coursesCount = docs.length;
        _error = null;
      });
    } on FirebaseException catch (e) {
      // Handle Firestore permission errors specifically
      final msg = e.message ?? e.toString();
      setState(() {
        _error = msg;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showRulesHint() {
    Get.dialog(
      AlertDialog(
        title: const Text('Firestore Rules Hint'),
        content: SingleChildScrollView(
          child: SelectableText(
            '''If you see "permission-denied", update your Firestore rules. Example to allow authenticated read:
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
Use the Firebase console → Firestore → Rules, or sign-in the user before reading.''',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Viewer'),
        actions: [
          IconButton(
            tooltip: 'Retry Firestore access',
            icon: const Icon(Icons.refresh),
            onPressed: _checkFirestoreAccess,
          ),
          IconButton(
            tooltip: 'Rules hint',
            icon: const Icon(Icons.rule),
            onPressed: _showRulesHint,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _loading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Checking Firestore access...'),
                  ],
                )
              : _error != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          'Error accessing Firestore:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _checkFirestoreAccess,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _showRulesHint,
                          child: const Text('Show rules hint'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                        const SizedBox(height: 12),
                        Text(
                          'Firestore accessible',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Found $_coursesCount course(s)'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _checkFirestoreAccess,
                          child: const Text('Recheck'),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
