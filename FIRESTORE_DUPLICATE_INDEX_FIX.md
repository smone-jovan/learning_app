# ⚠️ Firestore Duplicate Index Fix

## 🐛 Problem

Ada **2 index duplikat** untuk collection `quiz_attempts`:

| Collection | Fields Indexed | Index ID |
|------------|---------------|----------|
| quiz_attempts | quizId ↑, userId ↑, score ↓, _name_ ↓ | **CICAgJim14AK** |
| quiz_attempts | quizId ↑, userId ↑, createdAt ↓, _name_ ↓ | **CICAgJiUpoMK** |

**Issue:** Hanya 1 yang dibutuhkan untuk query sorting!

---

## ✅ Solution

### **Cara 1: Hapus Index yang Tidak Dipakai (Recommended)**

**Hapus index dengan `score` karena app tidak sort by score:**

1. Buka Firebase Console → Firestore Database
2. Klik tab **Indexes**
3. Cari index `quiz_attempts` dengan fields: `quizId, userId, score, _name_`
4. Klik **3 dots menu** (⋮) di kanan
5. Pilih **Delete index**
6. Confirm deletion
7. ✅ Selesai!

**Hasil:**
- Tetap ada 1 index: `quizId, userId, createdAt, _name_` ✅
- Index ini dipakai untuk query sorting by createdAt

---

### **Cara 2: Biarkan (If Not Sure)**

Kalau ragu index mana yang dipakai:

**Option:** Biarkan keduanya!
- Firebase akan otomatis pakai index yang sesuai
- Tidak ada impact ke performance
- Hanya makan storage sedikit lebih banyak

---

## 📊 Technical Details

### **Index yang Dipakai App:**

**Collection:** `quiz_attempts`

**Query di App:**
```dart
await _firestore
  .collection('quiz_attempts')
  .where('userId', isEqualTo: userId)
  .where('quizId', isEqualTo: quizId)
  .orderBy('createdAt', descending: true) // ✅ Sort by createdAt
  .get();
```

**Index yang Dibutuhkan:**
```
quizId (Ascending)
userID (Ascending)  
createdAt (Descending)
_name_ (Descending)
```

**Index ID:** `CICAgJiUpoMK` ✅

---

### **Index yang TIDAK Dipakai:**

**Fields:**
```
quizId (Ascending)
userID (Ascending)  
score (Descending)  ❌  // App tidak query by score
_name_ (Descending)
```

**Index ID:** `CICAgJim14AK` ❌

**Kenapa tidak dipakai:**
- App tidak pernah `.orderBy('score', descending: true)`
- App hanya sort by `createdAt` untuk show recent attempts

---

## 🛠️ Action Steps

### **Recommended Actions:**

**Step 1: Identify Which Index App Uses**
```bash
# Run app dan cek console
flutter run

# Navigate ke quiz attempts page
# Check console for any Firestore index errors
# If no errors = index CICAgJiUpoMK is working!
```

**Step 2: Delete Unused Index**
```
Firebase Console → Firestore → Indexes
→ Find: quiz_attempts with "score" field
→ Delete index CICAgJim14AK
✅ Done!
```

**Step 3: Verify App Still Works**
```bash
flutter run
# Test quiz attempts loading
# Should work perfectly with remaining index!
```

---

## ⚠️ Other Indexes (All Good!)

### **achievements**
```
Fields: rarity ↑, pointsReward ↑, _name_ ↑
Status: ✅ Good - No duplicates
Used by: Achievement sorting queries
```

### **questions**
```
Fields: quizId ↑, order ↑, _name_ ↑
Status: ✅ Good - No duplicates  
Used by: Question ordering in quiz
```

**Hanya quiz_attempts yang duplikat!**

---

## 📝 Summary

**What happened:**
- Index `CICAgJim14AK` (with score) mungkin dibuat by mistake atau saat testing
- Index `CICAgJiUpoMK` (with createdAt) yang sebenarnya dipakai

**What to do:**
1. ✅ Hapus index dengan `score` field
2. ✅ Keep index dengan `createdAt` field
3. ✅ Test app masih jalan

**Impact:**
- ✅ No breaking changes
- ✅ Cleaner index list
- ✅ Slightly less storage used

---

## ❓ FAQ

**Q: Aman hapus index?**  
A: ✅ Ya! Selama index lain dengan `createdAt` masih ada.

**Q: App akan error?**  
A: ❌ Tidak! App tidak pakai index yang dihapus.

**Q: Kalau ragu?**  
A: Biarkan aja! Index duplikat tidak bahaya, hanya makan storage sedikit.

**Q: Gimana kalau mau sort by score nanti?**  
A: Buat index baru dengan composite index builder di console kalau perlu.

---

## 📌 Quick Reference

**Delete Unused Index:**
```
Firebase Console → Firestore Database → Indexes tab
→ Find: quiz_attempts (quizId, userId, score, _name_)
→ Click 3-dot menu → Delete
✅ Done!
```

**Keep This Index:**
```
Collection: quiz_attempts
Fields: quizId ↑, userId ↑, createdAt ↓, _name_ ↓
Index ID: CICAgJiUpoMK
✅ This is the one app uses!
```

---

**Status after fix:**
- ✅ updateEmail error fixed
- ✅ Duplicate index documented
- ✅ App fully functional

**Next: Delete unused index from Firebase Console!**
