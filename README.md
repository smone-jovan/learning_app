# 🎓 Learning App - Gamified Education Platform

A modern gamified learning application built with Flutter and Firebase, featuring courses, quizzes, achievements, and leaderboards to make learning fun and engaging.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Firebase](https://img.shields.io/badge/Firebase-Latest-orange)
![GetX](https://img.shields.io/badge/GetX-State%20Management-purple)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

### 🔐 Authentication
- Email/Password login and registration
- Password reset via email
- Secure Firebase Authentication
- Auto-login for returning users

### 📚 Learning Experience
- **Courses**: Browse and enroll in various courses
- **Lessons**: Interactive lesson viewer
- **Quizzes**: Test your knowledge with timed quizzes
- **Progress Tracking**: Monitor your learning journey

### 🎮 Gamification System
- **Points & Coins**: Earn rewards for completing activities
- **Levels**: Progress through levels as you learn
- **Achievements**: Unlock badges and milestones
- **Leaderboard**: Compete with other learners
- **Streaks**: Maintain daily learning streaks
- **Daily Challenges**: Complete daily tasks for bonus rewards

### ⚙️ User Experience
- **Settings Page**: Customize your preferences
- **Dark Mode**: Toggle between light and dark themes
- **Profile Management**: View your stats and progress
- **Responsive Design**: Works on mobile, tablet, and web

---

## 🏗️ Architecture

```
lib/
├── app/
│   ├── data/
│   │   ├── models/          # Data models (User, Course, Quiz, etc.)
│   │   └── services/        # Firebase & local storage services
│   ├── routes/
│   │   ├── app_pages.dart   # Route definitions
│   │   └── app_routes.dart  # Route constants
│   └── middleware/          # Auth middleware
├── core/
│   ├── constants/           # App constants (Firebase collections, etc.)
│   └── theme/              # App theme configuration
├── presentation/
│   ├── auth/               # Authentication pages
│   ├── main/               # Main page with navigation
│   ├── pages/              # Feature pages (Courses, Quizzes, etc.)
│   ├── controllers/        # GetX controllers
│   └── bindings/           # Dependency injection bindings
└── main.dart               # App entry point
```

**Architecture Pattern**: Clean Architecture + MVVM  
**State Management**: GetX  
**Backend**: Firebase (Auth + Firestore)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Firebase account
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/learning_app.git
   cd learning_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   a. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Enable Authentication (Email/Password)
   
   c. Create a Firestore Database
   
   d. Download and add Firebase configuration files:
   - **Android**: `google-services.json` → `android/app/`
   - **iOS**: `GoogleService-Info.plist` → `ios/Runner/`
   - **Web**: Copy Firebase config to `web/index.html`

4. **Configure Firestore Security Rules**
   
   Go to Firebase Console → Firestore Database → Rules, and paste:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       function isAuthenticated() {
         return request.auth != null;
       }
       
       function isOwner(userId) {
         return request.auth.uid == userId;
       }
       
       match /users/{userId} {
         allow read: if isAuthenticated();
         allow create, update: if isAuthenticated() && isOwner(userId);
       }
       
       match /courses/{courseId} {
         allow read: if isAuthenticated();
       }
       
       match /achievements/{achievementId} {
         allow read: if isAuthenticated();
       }
       
       match /user_achievements/{userAchievementId} {
         allow read, create, update: if isAuthenticated() && 
           resource.data.userId == request.auth.uid;
       }
       
       match /leaderboard/{userId} {
         allow read: if isAuthenticated();
       }
     }
   }
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔥 Firebase Setup Guide

### Firestore Collections Structure

```
users/
├── {userId}/
│   ├── email, displayName, photoURL
│   ├── points, coins, level
│   ├── currentStreak, longestStreak
│   └── enrolledCourses[], completedQuizzes[]

courses/
├── {courseId}/
│   ├── title, description, instructor
│   ├── category, difficulty, duration
│   └── thumbnailURL, enrolledCount

achievements/
├── {achievementId}/
│   ├── title, description, category
│   ├── requirement, pointsReward, coinsReward
│   └── iconURL, rarity

user_achievements/
├── {userAchievementId}/
│   ├── userId, achievementId
│   ├── unlockedAt, isClaimed, claimedAt

leaderboard/
├── {userId}/
│   ├── displayName, photoURL
│   ├── totalPoints, level, rank
│   └── lastUpdated

daily_challenges/
├── {YYYY-MM-DD}/
│   ├── quizId, title, description
│   ├── pointsReward, coinsReward
│   └── expiresAt
```

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.x |
| **Language** | Dart 3.x |
| **State Management** | GetX |
| **Backend** | Firebase |
| **Authentication** | Firebase Auth |
| **Database** | Cloud Firestore |
| **Storage** | Shared Preferences |
| **UI Components** | Material Design 3 |

---

## 📦 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  get: ^4.6.6
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # UI
  google_fonts: ^6.1.0
  
  # Utilities
  intl: ^0.18.1
```
---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'feat: add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@SMONE](https://github.com/smone-jovan)
- Email: ntar aja

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- GetX community for state management solution
- Material Design 3 for UI components
- All contributors and testers

---

## 📞 Support

If you like this project, please give it a ⭐ on GitHub!

For issues and feature requests, please use the [Issues](https://github.com/smone-jovan/learning_app/issues) page.

---

Made with ❤️ and Flutter
