# 🔧 setState During Build Error - Fixed

## 🐛 Problem

### **Error Message:**
```
Error loading quiz detail: setState() or markNeedsBuild() called during build.
This Obx widget cannot be marked as needing to build because the framework 
is already in the process of building widgets.
```

### **When it Happens:**
- Click quiz card dari quiz list
- Navigate to quiz detail page
- App crashes immediately
- Quiz detail page tidak muncul

### **Screenshot of Error:**
```
The widget on which setState() or markNeedsBuild() was called was:
  Obx

The widget which was currently being built when the offending call was made was:
  QuizDetailPage

[GETX] GOING TO ROUTE /quiz-detail
```

---

## 🔍 Root Cause

### **The Problem Code:**

**File:** `lib/presentation/pages/quiz/quiz_detail_page.dart`

```dart
@override
Widget build(BuildContext context) {
  final args = Get.arguments as Map<String, dynamic>?;
  final quizId = args?['quizId'] as String?;

  // ❌ PROBLEM: Calling controller method directly in build()
  controller.loadQuizDetail(quizId);  // ❌ CAUSES setState DURING BUILD!

  return Scaffold(
    body: Obx(() {
      // ...
    }),
  );
}
```

### **Why This is Wrong:**

```
Execution Flow:
1. Flutter calls build()
2. build() calls controller.loadQuizDetail()
3. loadQuizDetail() updates observable (isLoading.value = true)
4. Observable update triggers Obx rebuild
5. ❌ ERROR: Trying to rebuild WHILE ALREADY BUILDING!
```

**Flutter Rule:** ⚠️ **You CANNOT call setState() or update observables during build() method.**

---

## ✅ Solution

### **Fix: Use `addPostFrameCallback()`**

**Updated Code:**

```dart
@override
Widget build(BuildContext context) {
  final args = Get.arguments as Map<String, dynamic>?;
  final quizId = args?['quizId'] as String?;

  if (quizId == null) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Details')),
      body: const Center(child: Text('Quiz not found')),
    );
  }

  // ✅ FIX: Schedule after build completes
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.loadQuizDetail(quizId);
  });

  return Scaffold(
    backgroundColor: AppColors.cream,
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final quiz = controller.selectedQuiz.value;
      if (quiz == null) {
        return const Center(child: Text('Quiz not found'));
      }

      // ... rest of UI
    }),
  );
}
```

### **How It Works:**

```
Corrected Execution Flow:
1. Flutter calls build()
2. build() schedules loadQuizDetail() to run AFTER build completes
3. build() returns widget tree
4. ✅ Build completes
5. ✅ loadQuizDetail() executes (safe to update state now)
6. ✅ Observable updates trigger rebuild (allowed now)
7. ✅ UI updates with quiz data
```

**Key Concept:** `addPostFrameCallback()` schedules callback to run **AFTER** current frame finishes building.

---

## 📋 Alternative Solutions

### **Option 1: Use StatefulWidget with initState() (More Complex)**

```dart
class QuizDetailPage extends StatefulWidget {
  const QuizDetailPage({super.key});

  @override
  State<QuizDetailPage> createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  final controller = Get.find<QuizController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final quizId = args?['quizId'] as String?;
    if (quizId != null) {
      controller.loadQuizDetail(quizId);  // ✅ Safe in initState
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // ...
      }),
    );
  }
}
```

**Pros:**
- Traditional Flutter approach
- initState() is designed for initialization

**Cons:**
- Loses GetView benefits
- More boilerplate code
- Need to manually Get.find<> controller

---

### **Option 2: Load in Controller onInit() (Not Ideal Here)**

```dart
// quiz_controller.dart
class QuizController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // ❌ Problem: How to get quizId here?
    // quizId is passed via arguments to page, not controller
  }
}
```

**Why Not Used:**
- Controller doesn't have access to route arguments
- Would need to pass quizId differently
- More complex architecture change

---

### **Option 3: Ever() Listener (Overkill)**

```dart
@override
Widget build(BuildContext context) {
  final args = Get.arguments as Map<String, dynamic>?;
  final quizId = args?['quizId'] as String?;

  ever(controller.selectedQuizId, (quizId) {
    if (quizId != null) {
      controller.loadQuizDetail(quizId);
    }
  });

  // ...
}
```

**Why Not Used:**
- Overkill for simple page load
- Creates unnecessary reactivity
- `addPostFrameCallback()` is simpler and clearer

---

## 🐞 Common Patterns That Cause This Error

### **Pattern 1: Controller Method in build() ❌**

```dart
@override
Widget build(BuildContext context) {
  controller.loadData();  // ❌ BAD!
  return Scaffold(...);
}
```

**Fix:**
```dart
@override
Widget build(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.loadData();  // ✅ GOOD!
  });
  return Scaffold(...);
}
```

---

### **Pattern 2: Observable Update in build() ❌**

```dart
@override
Widget build(BuildContext context) {
  someObservable.value = newValue;  // ❌ BAD!
  return Scaffold(...);
}
```

**Fix:**
```dart
@override
Widget build(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    someObservable.value = newValue;  // ✅ GOOD!
  });
  return Scaffold(...);
}
```

---

### **Pattern 3: Get.snackbar in build() ❌**

```dart
@override
Widget build(BuildContext context) {
  if (hasError) {
    Get.snackbar('Error', 'Something went wrong');  // ❌ BAD!
  }
  return Scaffold(...);
}
```

**Fix:**
```dart
@override
Widget build(BuildContext context) {
  if (hasError) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar('Error', 'Something went wrong');  // ✅ GOOD!
    });
  }
  return Scaffold(...);
}
```

---

## 🚨 Debugging Tips

### **How to Identify the Issue:**

1. **Look for error message:**
   ```
   setState() or markNeedsBuild() called during build
   ```

2. **Check stack trace:**
   ```
   The widget which was currently being built when the offending call was made was:
     QuizDetailPage  ← This is where to look!
   ```

3. **Find the culprit in build():**
   - Controller method calls
   - Observable updates
   - Navigation calls
   - Snackbar/dialog calls

4. **Wrap with addPostFrameCallback():**
   ```dart
   WidgetsBinding.instance.addPostFrameCallback((_) {
     // Move problematic code here
   });
   ```

---

## ✅ Testing Steps

### **Step 1: Pull Code**

```bash
git pull origin main
```

**File Updated:**
- ✅ `lib/presentation/pages/quiz/quiz_detail_page.dart`

---

### **Step 2: Hot Restart**

```bash
# Full restart or hot restart
flutter run
# or press R
```

---

### **Step 3: Test Quiz Detail Navigation**

1. ✅ Login to app
2. ✅ Navigate to Home → Quizzes
3. ✅ Click any quiz card
   - **Before:** App crashes with setState error
   - **After:** Quiz detail page loads smoothly ✅
4. ✅ Verify data loads:
   - Title, description
   - Category, difficulty badges
   - Quiz stats
   - Best score (if available)
   - Recent attempts
5. ✅ Click "Start Quiz" button
   - Should navigate to quiz play page

---

## 📚 Related Issues

### **Similar Errors in Other Files:**

If you see same error in other pages, check:

1. **CourseDetailPage**
2. **LessonViewerPage**
3. **ProfilePage**
4. **Any page that loads data on open**

**Solution is always the same:** Use `addPostFrameCallback()` for data loading in build().

---

## 📦 Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Data Loading** | ❌ In build() directly | ✅ Via addPostFrameCallback() |
| **Quiz Detail** | ❌ Crashes | ✅ Loads smoothly |
| **Error** | ❌ setState during build | ✅ No error |
| **User Experience** | ❌ Broken | ✅ Works perfectly |

---

**Status:** ✅ Fixed  
**Commit:** `fc030febd06a80245c70705b37325d8f53ee4556`  
**Date:** December 4, 2025  
**Action Required:** Pull code + Hot restart

---

## 💡 Key Takeaways

1. ⚠️ **NEVER call methods that update state directly in build()**
2. ✅ **ALWAYS use addPostFrameCallback() for initialization in GetView**
3. 🛠️ **Alternative: Use StatefulWidget + initState() if you prefer**
4. 📝 **Pattern applies to all pages, not just quiz detail**

**Flutter Golden Rule:** build() method should be **pure** - it should only return widgets, not cause side effects.
