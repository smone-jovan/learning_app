# 📚 Learning App - Dokumentasi Lengkap

## 🎯 Ringkasan Aplikasi

**Learning App** adalah aplikasi mobile pembelajaran gamified berbasis Flutter dengan fitur:
- 🎓 Quiz interaktif dengan timer dan scoring
- 📖 Course management
- 🏆 Gamification (points, coins, level, streak, achievements)
- 📊 Leaderboard
- 👤 User profiles
- 🔐 Firebase Authentication & Firestore

---

## 🚀 Quick Start

### **Prerequisites:**
```bash
- Flutter SDK (latest stable)
- Firebase project setup
- Android Studio / VS Code
```

### **Installation:**
```bash
git clone https://github.com/smone-jovan/learning_app.git
cd learning_app
flutter pub get
flutter run
```

### **Firebase Setup:**
1. Create Firebase project
2. Add Android/iOS apps
3. Download `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
4. Enable Authentication (Email/Password)
5. Enable Firestore Database
6. Deploy Firestore rules from `firestore.rules`

---

## 📁 Struktur Folder

```
lib/
├── app/
│   ├── data/
│   │   ├── models/          # Data models
│   │   ├── repositories/    # Data access layer
│   │   ├── providers/       # Firebase providers + SeedProvider
│   │   └── services/        # Services (Firestore, LocalStorage)
│   └── routes/              # App routing
├── presentation/
│   ├── controllers/         # GetX controllers
│   ├── pages/              # UI pages
│   └── widgets/            # Reusable widgets
├── core/
│   └── constant/           # Constants (colors, collections)
└── main.dart               # App entry point
```

---

## ✨ Fitur Utama

### **1. Authentication** 🔐
- Login/Register dengan email & password
- Forgot password
- Auto-login (persistent session)
- Logout

### **2. Quiz System** 📝
- **Quiz List:** Browse available quizzes dengan filter (category, difficulty)
- **Quiz Session:** Answer questions dengan timer countdown
- **Quiz Result:** Lihat score, passing status, rewards
- **Rewards:** Points & coins untuk first-time pass only
- **Quiz Attempts:** Track quiz history per user

### **3. Gamification** 🎮
- **Points:** Earned from quiz completion
- **Coins:** Earned from quiz completion
- **Level:** Auto-calculated based on total points
  - Level 1: 0-99 pts
  - Level 2: 100-299 pts
  - Level 3: 300-599 pts
  - Level 4: 600-999 pts
  - Level 5: 1000-1499 pts
  - ... (up to Level 10)
- **Streak:** Daily login tracking
- **Achievements:** Unlockable badges

### **4. Courses** 📚
- Course listing dengan filter
- Course details
- Course enrollment
- Progress tracking

### **5. Leaderboard** 🏆
- Top users by points
- Real-time ranking

### **6. Profile** 👤
- View/edit profile
- Achievement badges
- Stats (points, coins, level, streak)

### **7. Pull-to-Refresh** 🔄
- Quiz page: Swipe down to reload quizzes
- Course page: Swipe down to reload courses

---

## 🗄️ Firestore Collections

### **users**
```json
{
  "userId": "string",
  "displayName": "string",
  "email": "string",
  "points": 0,              // Current points (for UI display)
  "totalPoints": 0,         // Total accumulated points
  "coins": 0,
  "level": 1,
  "currentStreak": 0,
  "longestStreak": 0,
  "achievements": [],       // Array of achievement IDs
  "enrolledCourses": [],    // Array of course IDs
  "completedQuizzes": [],   // Array of quiz IDs
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### **quizzes**
```json
{
  "quizId": "string",
  "title": "string",
  "description": "string",
  "category": "string",
  "difficulty": "Beginner|Intermediate|Advanced",
  "passingScore": 70,
  "timeLimit": 300,         // in seconds
  "pointsReward": 100,
  "coinsReward": 50,
  "totalQuestions": 5,
  "isHidden": false,        // Admin can hide quiz
  "isPremium": false,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

**Sub-collection: `quizzes/{quizId}/questions`**
```json
{
  "questionId": "string",
  "quizId": "string",
  "question": "string",
  "options": ["A", "B", "C", "D"],
  "correctAnswer": "string",
  "order": 1,
  "createdAt": Timestamp
}
```

### **quiz_attempts**
```json
{
  "attemptId": "string",
  "userId": "string",
  "quizId": "string",
  "userAnswers": {"questionId": "answer"},
  "correctAnswers": 4,
  "wrongAnswers": 1,
  "totalQuestions": 5,
  "score": 80,
  "percentage": 80.0,
  "pointsEarned": 100,
  "coinsEarned": 50,
  "isPassed": true,
  "timeSpent": 180,
  "createdAt": Timestamp
}
```

### **courses**
```json
{
  "courseId": "string",
  "title": "string",
  "description": "string",
  "category": "string",
  "level": "Beginner|Intermediate|Advanced",
  "duration": 40,           // in hours
  "price": 0,
  "instructor": "string",
  "imageUrl": "string",
  "rating": 4.8,
  "studentsEnrolled": 1234,
  "pointsReward": 200,
  "lessonsCount": 10,
  "isPremium": false,
  "modules": [
    {
      "title": "Module 1",
      "duration": 120,
      "isCompleted": false
    }
  ],
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### **achievements**
```json
{
  "achievementId": "string",
  "title": "string",
  "description": "string",
  "category": "Quiz|Course|Points|Streak",
  "requirement": 10,
  "rarity": 1,              // 1=Common, 2=Rare, 3=Epic
  "pointsReward": 50,
  "iconName": "string",
  "createdAt": Timestamp
}
```

### **user_achievements**
```json
{
  "userAchievementId": "string",
  "userId": "string",
  "achievementId": "string",
  "unlockedAt": Timestamp,
  "isClaimed": false,
  "claimedAt": Timestamp
}
```

---

## 🔧 Recent Fixes (Latest)

### **1. Level Auto-Update** 🎮
**Problem:** Level tetap 1 meskipun points sudah 500+

**Solution:**
- Tambah `calculateLevel()` method di `QuizController`
- Auto-update level setelah dapat rewards
- Level up notification: "🎆 Level Up! You are now Level X"

**Files Changed:**
- `lib/presentation/controllers/quiz_controller.dart`

**Commit:** [`8a62a76`](https://github.com/smone-jovan/learning_app/commit/8a62a76d18081394095f016b87f8a75be203b906)

---

### **2. Quiz Seed Data** 📝
**Problem:** Quiz page kosong, database tidak ada quiz

**Solution:**
- Buat `SeedProvider` dengan sample data:
  - 3 quizzes (HTML Basics, CSS Fundamentals, JavaScript Intro)
  - 2 courses (Web Development, Flutter App Development)
  - 5 achievements
- Auto-seed saat login pertama kali
- Smart check: tidak duplicate seed

**Files Changed:**
- `lib/app/data/providers/seed_provider.dart` (NEW)
- `lib/presentation/controllers/splash_controller.dart`

**Commits:**
- [`7847018`](https://github.com/smone-jovan/learning_app/commit/7847018cf74cefd8704c5559c57c17a71b3729b8) - Create SeedProvider
- [`2646a24`](https://github.com/smone-jovan/learning_app/commit/2646a24d98999fba453010e93221a16d9642d1c8) - Auto-seed on app start

---

### **3. Pull-to-Refresh** 🔄
**Problem:** Cannot refresh quiz/courses manually

**Solution:**
- Add `refreshQuizzes()` method di `QuizController`
- Add `refreshCourses()` method di `CourseController`
- Implement `RefreshIndicator` di quiz & courses pages
- Tambah `AlwaysScrollableScrollPhysics` untuk smooth scroll
- Empty state jadi scrollable

**Files Changed:**
- `lib/presentation/controllers/quiz_controller.dart`
- `lib/presentation/controllers/course_controller.dart`
- `lib/presentation/pages/quiz/quiz_list_page.dart`
- `lib/presentation/pages/courses/courses_page.dart`

**Commits:**
- [`5f91b88`](https://github.com/smone-jovan/learning_app/commit/5f91b8893751b54895f5572231d8362c47bc778d) - Quiz page refresh
- [`9b93e43`](https://github.com/smone-jovan/learning_app/commit/9b93e43ab55a6bda87080d8792016e19e1d75b7b) - CourseController refresh method
- [`8bbfa9c`](https://github.com/smone-jovan/learning_app/commit/8bbfa9c29cff93ac33baff16df3ff36a688dc98c) - Courses page refresh

---

### **4. Points & Coins Update** 💰
**Problem:** Points/coins tidak update di UI setelah quiz selesai

**Solution:**
- Fix `updatePoints()` untuk update KEDUA field (`points` dan `totalPoints`)
- Perbaiki stream listener di `HomeController`
- Tambah auto-hide animation untuk indikator rewards (3 detik)
- Force reload profile setelah quiz rewards

**Files Changed:**
- `lib/app/data/repositories/user_repository.dart`
- `lib/presentation/controllers/home_controller.dart`
- `lib/presentation/controllers/quiz_controller.dart`

**Commits:**
- [`0070e6c`](https://github.com/smone-jovan/learning_app/commit/0070e6c348bf63187c4b72e49a121c208fe45376) - Fix updatePoints to update both fields
- [`5d84e4d`](https://github.com/smone-jovan/learning_app/commit/5d84e4dd31c1379060f068286e45b86bc4ccf9b8) - Fix HomeController stream
- [`c43e555`](https://github.com/smone-jovan/learning_app/commit/c43e55588fc70bf5978048dcdbc7c09c37179d18) - Fix QuizController force reload

---

## 📋 Manual Setup Required

### **1. Sync Points Field di Firebase** (One-time)

**Untuk user yang sudah ada sebelum fix:**

```bash
# Firebase Console → Firestore → users/[userId]
# Update field:
points: [same value as totalPoints]
level: [calculated based on points]

# Example:
points: 500 (was 0)
totalPoints: 500
level: 3 (was 1)
```

**Level calculation:**
- 0-99 points = Level 1
- 100-299 points = Level 2
- 300-599 points = Level 3
- 600-999 points = Level 4
- 1000-1499 points = Level 5

---

## 🧪 Testing Checklist

### **Authentication:**
- [ ] Register new user
- [ ] Login dengan user existing
- [ ] Logout
- [ ] Forgot password

### **Quiz:**
- [ ] Browse quiz list (3 quizzes harus muncul)
- [ ] Open quiz detail
- [ ] Start quiz session
- [ ] Answer questions dengan timer
- [ ] Submit quiz
- [ ] View quiz result
- [ ] First-time pass → dapat rewards (points, coins, level up)
- [ ] Retry quiz → tidak dapat rewards lagi
- [ ] Pull-to-refresh di quiz page

### **Gamification:**
- [ ] Points update setelah quiz
- [ ] Coins update setelah quiz
- [ ] Level auto-update (notification muncul)
- [ ] Indikator +points/+coins muncul lalu hilang (3s)
- [ ] Streak tracking
- [ ] Achievements unlock

### **Courses:**
- [ ] Browse course list (2 courses harus muncul)
- [ ] Open course detail
- [ ] Pull-to-refresh di course page

### **Leaderboard:**
- [ ] View leaderboard ranking

### **Profile:**
- [ ] View own profile
- [ ] View achievements

---

## 🐛 Troubleshooting

### **Quiz page kosong:**
```bash
# Check console log untuk seed messages
# Jika tidak ada quiz:
1. Logout
2. Login lagi (trigger seed)
3. Check Firebase Console → quizzes collection
```

### **Points tidak update:**
```bash
# Check console log:
✅ updatePoints result: true
✅ REWARDS SUCCESSFULLY UPDATED!

# Check Firebase Console:
points: [should match totalPoints]

# If still not working:
1. Manual fix di Firebase (one-time)
2. Hot restart app
```

### **Level masih 1:**
```bash
# Manual fix di Firebase Console:
users/[userId]/level = [calculated level]

# Example:
points: 500 → level: 3
```

### **Pull-to-refresh tidak work:**
```bash
# Verify:
1. RefreshIndicator wraps ListView
2. AlwaysScrollableScrollPhysics() present
3. onRefresh method signature correct (Future<void>)
```

---

## 🚀 Deployment

### **Android:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### **iOS:**
```bash
flutter build ios --release
# Open in Xcode for App Store submission
```

---

## 📚 Dependencies

**Main packages:**
```yaml
get: ^4.6.6                    # State management & routing
firebase_core: ^latest         # Firebase core
firebase_auth: ^latest         # Authentication
cloud_firestore: ^latest       # Database
get_storage: ^latest           # Local storage
uuid: ^latest                  # UUID generation
intl: ^latest                  # Internationalization
```

---

## 👥 Contributors

- **smone-jovan** - Main developer

---

## 📄 License

MIT License - See `LICENSE` file

---

## 📞 Support

**Issues/Bugs:** Open issue di GitHub

**Questions:** Check dokumentasi atau tanya di issues

---

**Last Updated:** December 5, 2025

**App Version:** 1.0.0
