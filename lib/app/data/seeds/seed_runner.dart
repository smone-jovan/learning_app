import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_app/app/data/seeds/quiz_seed.dart';

/// Utility untuk menjalankan seed data
/// Hanya jalan di development mode dan setelah user login
class SeedRunner {
  static bool _hasRun = false;

  /// Run all seeds
  /// Panggil fungsi ini di main.dart setelah Firebase initialized DAN user logged in
  static Future<void> runAll() async {
    // Hanya jalan sekali dan hanya di debug mode
    if (_hasRun || kReleaseMode) {
      if (kDebugMode) {
        print('Seed skipped: ${kReleaseMode ? "Release mode" : "Already run"}');
      }
      return;
    }

    // ✅ CRITICAL: Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (kDebugMode) {
        print('⚠️ Seed skipped: User not logged in yet');
        print('Tip: Seed data akan otomatis berjalan setelah login pertama kali');
      }
      return;
    }

    try {
      print('\n========================================');
      print('Starting seed data process...');
      print('User: ${user.email}');
      print('========================================\n');

      // Seed quiz data
      await QuizSeed.seedAll();

      print('\n========================================');
      print('Seed data completed successfully!');
      print('========================================\n');

      _hasRun = true;
    } catch (e) {
      print('\n========================================');
      print('Error running seeds: $e');
      print('========================================\n');
    }
  }

  /// Run seeds dengan delay (untuk menghindari race condition dan tunggu login)
  static Future<void> runWithDelay({Duration delay = const Duration(seconds: 2)}) async {
    await Future.delayed(delay);
    await runAll();
  }

  /// Run seeds ONLY jika user sudah login
  static Future<void> runIfAuthenticated() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await runAll();
    } else {
      if (kDebugMode) {
        print('⚠️ Seed tidak dijalankan: User belum login');
      }
    }
  }

  /// Reset flag (untuk testing)
  static void reset() {
    _hasRun = false;
  }
}
