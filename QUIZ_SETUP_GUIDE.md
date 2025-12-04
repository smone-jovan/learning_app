# 📚 Panduan Setup Quiz

Panduan lengkap untuk menggunakan fitur quiz dalam aplikasi Learning App.

## 🚀 Cara Menggunakan Fitur Quiz

### 1️⃣ Seed Data Quiz Awal

Untuk mengisi database dengan data quiz sample, tambahkan kode berikut di `main.dart` atau jalankan sekali saat development:

```dart
import 'package:learning_app/app/data/seeds/quiz_seed.dart';

// Panggil fungsi ini sekali untuk seed data
await QuizSeed.seedAll();
```

Ini akan membuat:
- ✅ 5 Quiz sample (Flutter Basics, Dart Fundamentals, dll)
- ✅ 10 Pertanyaan untuk quiz "Flutter Basics"

### 2️⃣ Navigasi ke Halaman Quiz

Dari halaman manapun, gunakan GetX untuk navigasi:

```dart
import 'package:learning_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

// Navigasi ke daftar quiz
Get.toNamed(AppRoutes.QUIZZES);

// Navigasi ke detail quiz tertentu
Get.toNamed(
  AppRoutes.QUIZ_DETAIL,
  arguments: {'quizId': 'flutter_basics_001'},
);

// Mulai quiz
Get.toNamed(
  AppRoutes.QUIZ_SESSION,
  arguments: {'quizId': 'flutter_basics_001'},
);
```

### 3️⃣ Menambah Quiz Baru (Admin)

Gunakan Admin Panel untuk menambah quiz:

```dart
// Navigasi ke Admin Quiz Page
Get.toNamed(AppRoutes.ADMIN_QUIZ);
```

**Form Admin Quiz:**
- Title: Judul quiz
- Description: Deskripsi quiz
- Category: Kategori (Flutter, Dart, Firebase, dll)
- Difficulty: Easy, Medium, Hard
- Time Limit: Waktu dalam detik (0 = unlimited)
- Passing Score: Nilai minimum untuk lulus (0-100%)
- Points Reward: Poin yang didapat jika lulus
- Coins Reward: Koin yang didapat jika lulus
- Total Questions: Jumlah soal
- Premium: Toggle untuk quiz premium

### 4️⃣ Menambah Soal Quiz (Admin)

Setelah membuat quiz, tambahkan soal-soalnya:

```dart
// Navigasi ke Admin Question Page
Get.toNamed(AppRoutes.ADMIN_QUESTION);
```

**Form Admin Question:**
- Select Quiz: Pilih quiz yang sudah dibuat
- Question Type: multiple_choice, true_false, atau short_answer
- Question Text: Teks pertanyaan
- Option A, B, C, D: Pilihan jawaban
- Correct Answer: Jawaban yang benar (A/B/C/D)
- Explanation: Penjelasan jawaban (opsional)
- Question Order: Urutan soal

## 📋 Struktur Data Firestore

### Collection: `quizzes`

```json
{
  "quizId": "flutter_basics_001",
  "title": "Flutter Basics",
  "description": "Test your knowledge...",
  "category": "Flutter",
  "difficulty": "Easy",
  "timeLimit": 600,
  "passingScore": 70,
  "pointsReward": 100,
  "coinsReward": 10,
  "totalQuestions": 10,
  "isPremium": false,
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "totalAttempts": 0
}
```

### Collection: `questions`

```json
{
  "questionId": "uuid",
  "quizId": "flutter_basics_001",
  "questionType": "multiple_choice",
  "questionText": "What is Flutter?",
  "options": [
    "A mobile development framework",
    "A programming language",
    "A database system",
    "An operating system"
  ],
  "correctAnswer": "A",
  "explanation": "Flutter is a UI toolkit...",
  "order": 1,
  "createdAt": "timestamp"
}
```

### Collection: `quiz_attempts`

```json
{
  "attemptId": "uuid",
  "userId": "user_uid",
  "quizId": "flutter_basics_001",
  "userAnswers": {
    "question_id_1": "A",
    "question_id_2": "C"
  },
  "correctAnswers": 8,
  "wrongAnswers": 2,
  "totalQuestions": 10,
  "score": 80,
  "percentage": 80.0,
  "pointsEarned": 100,
  "coinsEarned": 10,
  "isPassed": true,
  "timeSpent": 450,
  "createdAt": "timestamp"
}
```

## 🔧 Integrasi dengan Homepage

Tambahkan tombol quiz di HomePage:

```dart
// Di HomePage atau Dashboard
ElevatedButton(
  onPressed: () {
    Get.toNamed(AppRoutes.QUIZZES);
  },
  child: const Text('Take a Quiz'),
)
```

Atau buat widget Card khusus:

```dart
Card(
  child: ListTile(
    leading: const Icon(Icons.quiz),
    title: const Text('Quizzes'),
    subtitle: const Text('Test your knowledge'),
    trailing: const Icon(Icons.arrow_forward),
    onTap: () {
      Get.toNamed(AppRoutes.QUIZZES);
    },
  ),
)
```

## 🎯 Flow Pengguna

1. **Lihat Daftar Quiz** (`QuizListPage`)
   - Filter berdasarkan category dan difficulty
   - Lihat reward points dan coins
   - Lihat status premium

2. **Lihat Detail Quiz** (`QuizDetailPage`)
   - Lihat informasi lengkap quiz
   - Lihat best score sebelumnya
   - Lihat history attempts
   - Tombol "Start Quiz"

3. **Mulai Quiz** (`QuizPlayPage`)
   - Timer countdown (jika ada time limit)
   - Navigasi antar soal
   - Progress indicator
   - Tombol submit quiz

4. **Lihat Hasil** (`QuizResultPage`)
   - Score dan percentage
   - Jumlah benar/salah
   - Points dan coins yang didapat
   - Badge jika lulus
   - Tombol retry atau back to quiz list

## 🔐 Security Rules Firestore

Tambahkan rules berikut di Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Quizzes: semua user bisa read, hanya admin yang bisa write
    match /quizzes/{quizId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Questions: semua user bisa read, hanya admin yang bisa write
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Quiz Attempts: user hanya bisa read/write data mereka sendiri
    match /quiz_attempts/{attemptId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if false; // Attempts tidak bisa diupdate/delete
    }
  }
}
```

## 📱 Contoh Implementasi di Main Menu

Tambahkan di `lib/presentation/home/home_page.dart`:

```dart
import 'package:learning_app/app/routes/app_routes.dart';

// Di body HomePage
GridView.count(
  crossAxisCount: 2,
  children: [
    _MenuCard(
      icon: Icons.school,
      title: 'Courses',
      onTap: () => Get.toNamed(AppRoutes.COURSES),
    ),
    _MenuCard(
      icon: Icons.quiz,
      title: 'Quizzes',
      color: Colors.orange,
      onTap: () => Get.toNamed(AppRoutes.QUIZZES),
    ),
    _MenuCard(
      icon: Icons.leaderboard,
      title: 'Leaderboard',
      onTap: () => Get.toNamed(AppRoutes.LEADERBOARD),
    ),
    _MenuCard(
      icon: Icons.emoji_events,
      title: 'Achievements',
      onTap: () => Get.toNamed(AppRoutes.ACHIEVEMENTS),
    ),
  ],
)
```

## 🐛 Troubleshooting

### Quiz tidak muncul?
1. Pastikan sudah menjalankan `QuizSeed.seedAll()`
2. Cek Firestore console apakah data sudah ada
3. Cek error di console Flutter

### Error saat submit quiz?
1. Pastikan user sudah login
2. Cek Firestore rules
3. Pastikan semua field required terisi

### Timer tidak jalan?
1. Cek field `timeLimit` di quiz
2. Pastikan `_startTimer()` dipanggil
3. Cek lifecycle `onClose()` di controller

## 📞 Support

Jika ada masalah atau pertanyaan, silakan buat issue di repository ini.

---

**Happy Coding! 🎉**
