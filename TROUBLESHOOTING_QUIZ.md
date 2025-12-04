# 🔧 Troubleshooting Guide: Quiz 404 Error

## 🐛 Problem: 404 - Page Not Found saat membuka `/quizzes`

### 🔍 Penyebab Umum:

1. **Route tidak terdaftar**
2. **Controller tidak di-bind**
3. **Data quiz belum di-seed**
4. **Firestore rules tidak mengizinkan read**

---

## ✅ Solusi Step-by-Step

### **Step 1: Cek Route Sudah Terdaftar**

Buka `lib/app/routes/app_routes.dart` dan pastikan ada:

```dart
static const QUIZZES = '/quizzes';

GetPage(
  name: QUIZZES,
  page: () => QuizListPage(),
  binding: HomeBinding(), // atau QuizBinding()
),
```

**Jika belum ada, pull dari GitHub:**
```bash
git pull origin main
```

---

### **Step 2: Pastikan Controller Di-Bind**

Cek file `lib/presentation/home/home_binding.dart` atau `lib/presentation/pages/quiz/quiz_binding.dart`:

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan QuizController di-register
    Get.lazyPut<QuizController>(() => QuizController());
  }
}
```

**Jika tidak ada, buat file `quiz_binding.dart`:**

```dart
import 'package:get/get.dart';
import '../../controllers/quiz_controller.dart';

class QuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizController>(() => QuizController());
  }
}
```

Lalu update route:
```dart
GetPage(
  name: QUIZZES,
  page: () => QuizListPage(),
  binding: QuizBinding(), // ✅ Gunakan QuizBinding
),
```

---

### **Step 3: Seed Data Quiz**

Tambahkan di `lib/main.dart` setelah Firebase init:

```dart
import 'package:learning_app/app/data/seeds/seed_runner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ✅ Seed data quiz (hanya jalan sekali di debug mode)
  await SeedRunner.runWithDelay();
  
  runApp(const MyApp());
}
```

**Atau jalankan manual di Flutter DevTools Console:**
```dart
import 'package:learning_app/app/data/seeds/quiz_seed.dart';
await QuizSeed.seedAll();
```

---

### **Step 4: Update Firestore Rules**

**Copy rules baru ke Firebase Console:**

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. Ke **Firestore Database** → **Rules**
4. Copy paste rules dari file `firestore.rules` di repository
5. Klik **Publish**

**Atau deploy via CLI:**
```bash
firebase deploy --only firestore:rules
```

**Rules baru yang penting:**
```javascript
match /quizzes/{quizId} {
  allow read: if isAuthenticated(); // ✅ Semua user bisa baca
  allow write: if isAdmin(); // ✅ Hanya admin bisa write
}

match /questions/{questionId} {
  allow read: if isAuthenticated();
  allow write: if isAdmin();
}
```

---

### **Step 5: Set User Sebagai Admin**

Untuk mengakses admin panel, set field `isAdmin` di Firestore:

1. Buka Firebase Console → Firestore
2. Cari collection `users`
3. Pilih document user Anda (based on UID)
4. Tambahkan field:
   - **Field name:** `isAdmin`
   - **Type:** `boolean`
   - **Value:** `true`
5. Save

**Atau via kode (1x run di DevTools):**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update({'isAdmin': true});
  print('User set as admin');
}
```

---

### **Step 6: Clear Cache & Restart**

```bash
# Stop app
flutter clean
flutter pub get
flutter run
```

---

## 📋 Checklist Debugging

### **Cek di Console Flutter:**

- [ ] Ada error "Route not found"?
  - → Route belum terdaftar di `app_routes.dart`

- [ ] Ada error "Controller not found"?
  - → Binding belum di-setup

- [ ] Ada error "Permission denied"?
  - → Firestore rules belum diupdate

- [ ] Halaman quiz kosong?
  - → Data belum di-seed

### **Cek di Firestore Console:**

- [ ] Collection `quizzes` ada?
  - → Jika tidak, jalankan seed

- [ ] Collection `questions` ada?
  - → Jika tidak, jalankan seed

- [ ] Field `isAdmin` di user document?
  - → Set manual di console

---

## 🚨 Error Umum & Solusi

### **Error: "No Firebase App has been created"**

**Solusi:**
```dart
// Pastikan Firebase initialized SEBELUM runApp
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### **Error: "Could not find QuizController"**

**Solusi:**
```dart
// Tambahkan di binding
Get.lazyPut<QuizController>(() => QuizController());

// Atau di page langsung
final controller = Get.put(QuizController());
```

### **Error: "Missing or insufficient permissions"**

**Solusi:**
1. Update Firestore rules
2. Pastikan user sudah login
3. Cek authentication di controller

### **Halaman Quiz Kosong (Tidak Error)**

**Solusi:**
1. Jalankan seed data
2. Cek di Firestore Console apakah data ada
3. Cek `quizzes.length` di controller

---

## 📝 Log Debugging

**Tambahkan print di controller untuk debug:**

```dart
// Di quiz_controller.dart
Future<void> loadQuizzes() async {
  try {
    print('Loading quizzes...'); // ✅ Debug
    isLoading.value = true;
    
    final allQuizzes = await _quizProvider.getAllQuizzes();
    print('Loaded ${allQuizzes.length} quizzes'); // ✅ Debug
    
    quizzes.value = allQuizzes;
  } catch (e) {
    print('Error loading quizzes: $e'); // ✅ Debug
  } finally {
    isLoading.value = false;
  }
}
```

---

## ✅ Verifikasi Setelah Fix

### **Test Flow:**

1. ✅ App buka tanpa error
2. ✅ Login berhasil
3. ✅ Navigasi ke Settings berhasil
4. ✅ (Jika admin) Menu "Admin Tools" muncul
5. ✅ Klik "Manage Quizzes" → Form muncul
6. ✅ Klik "Manage Questions" → Form muncul
7. ✅ Navigasi ke Quiz List berhasil (tidak 404)
8. ✅ Quiz list tampil (jika sudah ada data)
9. ✅ Klik quiz → Detail muncul
10. ✅ Start quiz → Questions muncul

---

## 📞 Support

Jika masih ada masalah setelah mengikuti guide ini:

1. Check console untuk error messages
2. Verify Firestore rules di console
3. Check data di Firestore console
4. Create issue di GitHub dengan:
   - Screenshot error
   - Console log
   - Firestore data screenshot

---

**Last Updated:** December 4, 2025
