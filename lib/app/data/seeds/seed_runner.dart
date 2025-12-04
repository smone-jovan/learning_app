import 'package:flutter/foundation.dart';
import 'package:learning_app/app/data/seeds/quiz_seed.dart';

/// Utility untuk menjalankan seed data
/// Hanya jalan di development mode
class SeedRunner {
  static bool _hasRun = false;

  /// Run all seeds
  /// Panggil fungsi ini di main.dart setelah Firebase initialized
  static Future<void> runAll() async {
    // Hanya jalan sekali dan hanya di debug mode
    if (_hasRun || kReleaseMode) {
      print('Seed skipped: ${kReleaseMode ? "Release mode" : "Already run"}');
      return;
    }

    try {
      print('\n========================================');
      print('Starting seed data process...');
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

  /// Run seeds dengan delay (untuk menghindari race condition)
  static Future<void> runWithDelay({Duration delay = const Duration(seconds: 3)}) async {
    await Future.delayed(delay);
    await runAll();
  }

  /// Reset flag (untuk testing)
  static void reset() {
    _hasRun = false;
  }
}
