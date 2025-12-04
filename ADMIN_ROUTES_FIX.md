# 🔧 Admin Routes 404 Fix

## 🐛 Problem

Ketika klik "Manage Quizzes" atau "Manage Questions" di Admin Tools, muncul error **404 Not Found**.

### **Screenshot:**
Admin Tools terlihat di Settings, tapi navigasi ke `/admin/quiz` atau `/admin/question` menghasilkan 404.

---

## 🔍 Root Cause

### **Issue:**
Admin routes **terdaftar di `app_routes.dart`** (constants) tapi **TIDAK terdaftar di `app_pages.dart`** (GetPages).

### **File Structure:**
```
lib/app/routes/
  ├── app_routes.dart    <- Route constants (✅ Admin constants ada)
  └── app_pages.dart     <- GetPages list (❌ Admin routes TIDAK ada)
```

**app_routes.dart** (Constants only):
```dart
class AppRoutes {
  static const ADMIN_QUIZ = '/admin/quiz';         // ✅ Defined
  static const ADMIN_QUESTION = '/admin/question';  // ✅ Defined
}
```

**app_pages.dart** (Actual routing):
```dart
class AppPages {
  static final pages = [
    // ... other routes
    // ❌ ADMIN ROUTES MISSING!
  ];
}
```

**GetMaterialApp** di `main.dart` menggunakan `AppPages.pages`, bukan `AppRoutes.routes`:
```dart
GetMaterialApp(
  getPages: AppPages.pages,  // ← Uses app_pages.dart
  // ...
)
```

Jadi meskipun constants ada, routing tidak berfungsi karena GetPages tidak terdaftar.

---

## ✅ Solution

### **File Updated:** `lib/app/routes/app_pages.dart`

**Added admin routes to GetPages list:**

```dart
import '../../presentation/pages/admin/admin_quiz_page.dart';
import '../../presentation/pages/admin/admin_question_page.dart';

class AppPages {
  static final pages = [
    // ... existing routes ...

    // ==========================================
    // ADMIN ROUTES - ✅ BARU
    // ==========================================
    GetPage(
      name: AppRoutes.ADMIN_QUIZ,
      page: () => const AdminQuizPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.ADMIN_QUESTION,
      page: () => const AdminQuestionPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController());
        }
      }),
    ),
  ];
}
```

**Commit:** `af4e5beb69da7a7465a47d00510edfa1f4d88e11`

---

## 📋 Verification Steps

### **Step 1: Pull Latest Code**

```bash
git pull origin main
```

### **Step 2: Hot Restart App**

```bash
# In VSCode/Android Studio: Shift + R (hot restart)
# Or stop and run again
flutter run
```

### **Step 3: Test Admin Routes**

1. ✅ Login sebagai admin (pastikan `isAdmin: true` di Firestore)
2. ✅ Navigate ke **Settings**
3. ✅ Scroll ke section **Admin Tools**
4. ✅ Klik **"Manage Quizzes"**
   - **Expected:** Form admin quiz muncul (tidak 404)
   - **URL:** `/admin/quiz`
5. ✅ Back, lalu klik **"Manage Questions"**
   - **Expected:** Form admin question muncul (tidak 404)
   - **URL:** `/admin/question`

---

## 🔗 Related Files

### **Admin Pages:**
- ✅ `lib/presentation/pages/admin/admin_quiz_page.dart` - Form create quiz
- ✅ `lib/presentation/pages/admin/admin_question_page.dart` - Form create question

### **Routing Files:**
- ✅ `lib/app/routes/app_routes.dart` - Route constants
- ✅ `lib/app/routes/app_pages.dart` - GetPages configuration (UPDATED)

### **Settings Page:**
- ✅ `lib/presentation/pages/setting/settings_page.dart` - Shows admin menu

### **User Model:**
- ✅ `lib/app/data/models/user_model.dart` - Has `isAdmin` field

---

## 🧩 Understanding GetX Routing

### **Route Registration Flow:**

```
1. Define constant in app_routes.dart:
   static const ADMIN_QUIZ = '/admin/quiz';

2. Register GetPage in app_pages.dart:
   GetPage(
     name: AppRoutes.ADMIN_QUIZ,
     page: () => const AdminQuizPage(),
   )

3. Use in GetMaterialApp (main.dart):
   GetMaterialApp(
     getPages: AppPages.pages,
   )

4. Navigate using constant:
   Get.toNamed(AppRoutes.ADMIN_QUIZ);
```

### **Common Mistakes:**

❌ **Mistake 1:** Define constant, forget GetPage
```dart
// app_routes.dart
static const ADMIN_QUIZ = '/admin/quiz';  // ✅ Defined

// app_pages.dart
// ❌ Forgot to add GetPage!
```
**Result:** 404 Not Found

❌ **Mistake 2:** Wrong import path
```dart
import '../../pages/admin/admin_quiz_page.dart';  // ❌ Wrong path
```
**Result:** Compilation error or 404

❌ **Mistake 3:** Wrong constant name
```dart
GetPage(
  name: '/admin/quiz',  // ❌ Hardcoded, not using constant
  page: () => AdminQuizPage(),
)
```
**Result:** Works, but not maintainable

✅ **Correct:**
```dart
GetPage(
  name: AppRoutes.ADMIN_QUIZ,  // ✅ Using constant
  page: () => const AdminQuizPage(),
)
```

---

## 🚨 Troubleshooting

### **Issue 1: Still 404 After Pull**

**Solution:**
```bash
# Stop app completely
# Clear build cache
flutter clean
flutter pub get
flutter run
```

### **Issue 2: "AdminQuizPage not found"**

**Check:**
1. File exists: `lib/presentation/pages/admin/admin_quiz_page.dart`
2. Import correct: `import '../../presentation/pages/admin/admin_quiz_page.dart';`
3. Class exported: `class AdminQuizPage extends StatefulWidget`

### **Issue 3: Admin Tools Tidak Muncul**

**Check:**
1. User `isAdmin` field = `true` di Firestore
2. User data loaded (check console logs)
3. AuthController initialized

**Verify di Firestore:**
```
Firestore Console
  → Collection: users
  → Document: <your-user-uid>
  → Field: isAdmin = true (boolean)
```

---

## 🎯 Complete Admin Flow

### **1. Set User as Admin:**
```
Firestore → users → [user-doc] → isAdmin: true
```

### **2. Login to App:**
```
AuthController loads user data including isAdmin field
```

### **3. Navigate to Settings:**
```
Settings page checks: user?.isAdmin == true
```

### **4. Admin Tools Section Appears:**
```
Shows:
- Manage Quizzes (navigates to /admin/quiz)
- Manage Questions (navigates to /admin/question)
```

### **5. Click Menu:**
```
Get.toNamed(AppRoutes.ADMIN_QUIZ)
  → Looks up GetPage in AppPages.pages
  → Finds match: name == AppRoutes.ADMIN_QUIZ
  → Renders: AdminQuizPage()
```

---

## ✅ Checklist

### **Before Fix:**
- [ ] Admin Tools muncul di Settings
- [ ] Klik "Manage Quizzes" → 404 Not Found
- [ ] Klik "Manage Questions" → 404 Not Found
- [ ] Console error: Route not found

### **After Fix:**
- [ ] Pull latest code
- [ ] Hot restart app
- [ ] Admin Tools masih muncul
- [ ] Klik "Manage Quizzes" → Form muncul ✅
- [ ] Klik "Manage Questions" → Form muncul ✅
- [ ] No 404 errors
- [ ] Can create quiz successfully
- [ ] Can create questions successfully

---

## 📚 Additional Resources

- [GetX Routing Documentation](https://pub.dev/packages/get#route-management)
- [Named Routes Best Practices](https://github.com/jonataslaw/getx/blob/master/documentation/en_US/route_management.md)

---

## 📦 Summary

| Aspect | Before | After |
|--------|--------|-------|
| **app_routes.dart** | ✅ Constants defined | ✅ No change |
| **app_pages.dart** | ❌ Admin GetPages missing | ✅ Admin GetPages added |
| **Navigation** | ❌ 404 Not Found | ✅ Works correctly |
| **Admin Panel** | ❌ Inaccessible | ✅ Fully functional |

---

**Status:** ✅ Fixed  
**Date:** December 4, 2025  
**Action Required:** Pull latest code & hot restart
