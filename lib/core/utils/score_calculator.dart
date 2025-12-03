/// Score calculation utilities
class ScoreCalculator {
  // Calculate quiz score percentage
  static double calculatePercentage(int correct, int total) {
    if (total == 0) return 0.0;
    return (correct / total) * 100;
  }

  // Calculate points earned based on performance
  static int calculatePoints({
    required int correctAnswers,
    required int totalQuestions,
    required int basePoints,
    int? timeBonus,
  }) {
    final percentage = calculatePercentage(correctAnswers, totalQuestions);
    
    // Base points proportional to score
    final earnedPoints = (basePoints * (percentage / 100)).round();
    
    // Add time bonus if applicable
    final totalPoints = earnedPoints + (timeBonus ?? 0);
    
    return totalPoints;
  }

  // Calculate coins earned
  static int calculateCoins({
    required int correctAnswers,
    required int totalQuestions,
    required int baseCoins,
  }) {
    final percentage = calculatePercentage(correctAnswers, totalQuestions);
    
    // Coins proportional to score
    return (baseCoins * (percentage / 100)).round();
  }

  // Check if passed
  static bool isPassed(int score, int passingScore) {
    return score >= passingScore;
  }

  // Calculate time bonus points
  static int calculateTimeBonus({
    required int timeLimit,
    required int timeSpent,
  }) {
    if (timeLimit == 0) return 0; // No time limit
    
    final timeRemaining = timeLimit - timeSpent;
    if (timeRemaining <= 0) return 0;
    
    // Bonus: 1 point per 10 seconds remaining
    return (timeRemaining / 10).floor();
  }
}
