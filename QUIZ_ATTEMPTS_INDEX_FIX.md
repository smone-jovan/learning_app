# 🔧 Quiz Attempts Index Fix

## 🐛 Problem

### **Error Messages:**

```
Error getting collection: [cloud_firestore/failed-precondition] 
The query requires an index. You can create it here:
```

**Two indexes needed:**

1. **Index 1:** `quiz_attempts` - quizId + userId + createdAt
2. **Index 2:** `quiz_attempts` - quizId + userId + score

### **When It Happens:**
- Click "Start Quiz" button on quiz detail page
- App tries to load previous attempts
- Firestore query fails without index
- Quiz won't start

---

## ✅ Solution: Create Firestore Indexes

### **Option A: Automatic (Click Links)**

**Click these links while logged into Firebase Console:**

#### **Index 1: createdAt ordering**
[Create Index 1](https://console.firebase.google.com/v1/r/project/learning-app-flutter-13319/firestore/indexes?create_composite=CmBwcm9qZWN0cy9sZWFybmluZy1hcHAtZmx1dHRlci0xMzMxOS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcXVpel9hdHRlbXB0cy9pbmRleGVzL18QARoKCgZxdWl6SWQQARoKCgZ1c2VySWQQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC)

**Fields:**
- Collection: `quiz_attempts`
- quizId: Ascending
- userId: Ascending  
- createdAt: Descending

---

#### **Index 2: score ordering**
[Create Index 2](https://console.firebase.google.com/v1/r/project/learning-app-flutter-13319/firestore/indexes?create_composite=CmBwcm9qZWN0cy9sZWFybmluZy1hcHAtZmx1dHRlci0xMzMxOS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcXVpel9hdHRlbXB0cy9pbmRleGVzL18QARoKCgZxdWl6SWQQARoKCgZ1c2VySWQQARoJCgVzY29yZRACGgwKCF9fbmFtZV9fEAI)

**Fields:**
- Collection: `quiz_attempts`
- quizId: Ascending
- userId: Ascending
- score: Descending

---

### **Option B: Manual Creation**

**If links don't work, create manually:**

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select project: **learning-app-flutter-13319**
3. Navigate to **Firestore Database** → **Indexes** tab
4. Click **Create Index**

#### **Index 1:**
```
Collection ID: quiz_attempts
Fields to index:
  - quizId: Ascending
  - userId: Ascending
  - createdAt: Descending
Query scope: Collection
```

#### **Index 2:**
```
Collection ID: quiz_attempts
Fields to index:
  - quizId: Ascending
  - userId: Ascending
  - score: Descending
Query scope: Collection
```

5. Click **Create Index** for each
6. Wait 2-5 minutes for indexes to build
7. Status will change from "Building" to "Enabled"

---

## 📋 Why These Indexes Are Needed

### **Query 1: Get Recent Attempts**

**Code:** `quiz_controller.dart` or `firebase_service.dart`
```dart
FirebaseFirestore.instance
  .collection('quiz_attempts')
  .where('quizId', isEqualTo: quizId)
  .where('userId', isEqualTo: userId)
  .orderBy('createdAt', descending: true)  // ← Needs index!
  .limit(10)
  .get();
```

**Index needed:** quizId + userId + createdAt

---

### **Query 2: Get Best Score**

**Code:**
```dart
FirebaseFirestore.instance
  .collection('quiz_attempts')
  .where('quizId', isEqualTo: quizId)
  .where('userId', isEqualTo: userId)
  .orderBy('score', descending: true)  // ← Needs index!
  .limit(1)
  .get();
```

**Index needed:** quizId + userId + score

---

## ⏱️ Index Build Time

**Expected:** 2-5 minutes

**Status Check:**
1. Firebase Console → Firestore → Indexes
2. Look for status:
   - 🟡 **Building** - Wait...
   - 🟢 **Enabled** - Ready!

**While Building:**
- Queries will fail
- "Start Quiz" won't work
- App will show error

**After Enabled:**
- ✅ Queries work
- ✅ Quiz starts successfully
- ✅ Previous attempts load
- ✅ Best score shows

---

## 🔍 Verification Steps

### **Step 1: Check Index Status**

1. Firebase Console → Firestore Database → Indexes
2. Find indexes for `quiz_attempts`
3. Both should show **"Enabled"**

---

### **Step 2: Test Quiz Start**

1. ✅ Navigate to quiz detail page
2. ✅ Click "Start Quiz" button
3. ✅ Should load without error
4. ✅ Quiz play page opens
5. ✅ Questions load correctly

---

### **Step 3: Check Console**

**No more errors:**
```
✅ No "failed-precondition" errors
✅ No "query requires an index" messages
✅ Quiz data loads successfully
```

---

## 📊 Complete Index Summary

### **All Required Indexes:**

| Collection | Fields | Purpose |
|------------|--------|----------|
| `achievements` | userId (ASC) + unlockedAt (DESC) | User achievements list |
| `quiz_attempts` | quizId (ASC) + userId (ASC) + createdAt (DESC) | Recent attempts |
| `quiz_attempts` | quizId (ASC) + userId (ASC) + score (DESC) | Best score |

### **Status:**
- ✅ `achievements` index - Created previously
- ⏳ `quiz_attempts` indexes - Create now (2 indexes)

---

## 🚨 Troubleshooting

### **Issue 1: Link Doesn't Work**

**Error:** "You don't have permission" or 404

**Solution:**
1. Make sure you're logged into correct Google account
2. Account must have Firebase Admin/Owner role
3. Try manual creation (Option B above)

---

### **Issue 2: Index Build Takes Too Long**

**Expected:** 2-5 minutes

**If > 10 minutes:**
1. Refresh Firebase Console page
2. Check for error messages
3. Delete and recreate index
4. Contact Firebase Support if persists

---

### **Issue 3: Still Getting Error After Index Enabled**

**Solution:**
```bash
# Clear app cache and restart
flutter clean
flutter pub get
flutter run
```

---

## 📝 Related Files

### **Queries Using These Indexes:**

**File:** `lib/app/data/services/firebase_service.dart`
```dart
// Get user quiz attempts (needs Index 1)
Future<List<QueryDocumentSnapshot>> getUserQuizAttempts(
  String quizId, 
  String userId
) async {
  return await FirebaseFirestore.instance
    .collection('quiz_attempts')
    .where('quizId', isEqualTo: quizId)
    .where('userId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .get()
    .then((snapshot) => snapshot.docs);
}

// Get best quiz attempt (needs Index 2)
Future<QueryDocumentSnapshot?> getBestQuizAttempt(
  String quizId,
  String userId
) async {
  final result = await FirebaseFirestore.instance
    .collection('quiz_attempts')
    .where('quizId', isEqualTo: quizId)
    .where('userId', isEqualTo: userId)
    .orderBy('score', descending: true)
    .limit(1)
    .get();
  
  return result.docs.isNotEmpty ? result.docs.first : null;
}
```

---

## ✅ Checklist

### **Before Fix:**
- [ ] Click "Start Quiz" → Error
- [ ] Console shows "query requires an index"
- [ ] Previous attempts don't load
- [ ] Best score not shown

### **After Fix:**
- [ ] Click index creation links (or create manually)
- [ ] Wait for "Enabled" status (2-5 min)
- [ ] Restart app
- [ ] Click "Start Quiz" → Works! ✅
- [ ] Previous attempts load ✅
- [ ] Best score shows (if exists) ✅
- [ ] No console errors ✅

---

## 🎯 Summary

**Problem:** Firestore queries for quiz attempts need composite indexes

**Solution:** Create 2 indexes:
1. quizId + userId + createdAt (for recent attempts)
2. quizId + userId + score (for best score)

**Action:**
1. Click creation links (or create manually)
2. Wait 2-5 minutes
3. Test quiz start

**Status:** ⏳ **Waiting for index build**  
**ETA:** 2-5 minutes from creation  
**Next:** Fix QuizPlayPage setState error

---

**Create indexes now, then proceed to fix QuizPlayPage!** 🚀
