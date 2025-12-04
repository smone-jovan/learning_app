/// Route constants untuk navigasi
/// File ini HANYA berisi constants, tidak ada GetPages
/// GetPages ada di app_pages.dart
class AppRoutes {
  // ==========================================
  // AUTH ROUTES
  // ==========================================
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const EMAIL_VERIFICATION = '/email-verification';

  // ==========================================
  // MAIN ROUTES
  // ==========================================
  static const MAIN = '/main';
  static const HOME = '/home';

  // ==========================================
  // COURSE ROUTES
  // ==========================================
  static const COURSES = '/courses';
  static const COURSE_DETAIL = '/course-detail';
  static const LESSON_VIEWER = '/lesson-viewer';

  // ==========================================
  // QUIZ ROUTES
  // ==========================================
  static const QUIZZES = '/quizzes';
  static const QUIZ_DETAIL = '/quiz-detail';
  static const QUIZ_SESSION = '/quiz-session';
  static const QUIZ_PLAY = '/quiz-play';  // ✅ Alternative name
  static const QUIZ_RESULT = '/quiz-result';

  // ==========================================
  // GAMIFICATION ROUTES
  // ==========================================
  static const LEADERBOARD = '/leaderboard';
  static const ACHIEVEMENTS = '/achievements';

  // ==========================================
  // USER ROUTES
  // ==========================================
  static const PROFILE = '/profile';
  static const SETTINGS = '/settings';

  // ==========================================
  // ADMIN ROUTES
  // ==========================================
  static const ADMIN_QUIZ = '/admin/quiz';
  static const ADMIN_QUESTION = '/admin/question';

  // ==========================================
  // UTILITY ROUTES
  // ==========================================
  static const NOT_FOUND = '/notfound';
}
