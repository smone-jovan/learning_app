/// App configuration constants
class AppConfig {
  // Environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';

  // API Settings (if needed later)
  static const String apiBaseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxLoadMoreAttempts = 3;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);

  // Quiz Settings
  static const int quizTimeWarningThreshold = 60; // seconds
  static const int maxQuizAttempts = 3;

  // Gamification
  static const int streakBonusCoins = 5;
  static const int dailyChallengeReward = 50;

  // Leaderboard
  static const int leaderboardPageSize = 50;
  static const Duration leaderboardRefreshInterval = Duration(minutes: 5);
}
