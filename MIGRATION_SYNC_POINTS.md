# 🔄 Migration Guide: Sync Points Field

## 🔴 Problem

**Database kamu saat ini:**
```
users/[userId] {
  points: 0           ❌ Tidak pernah di-update (masih 0)
  totalPoints: 400    ✅ Sudah ter-update
  coins: 300          ✅ Sudah ter-update
}
```

**UI home screen membaca:** `points` (bukan `totalPoints`)

**Hasil:** Points tidak muncul di home screen meskipun `totalPoints` sudah benar.

---

## ✅ Solution

### **1. Update `user_repository.dart`** (✅ DONE)

Sekarang `updatePoints()` akan update **KEDUA field**:
```dart
'points': FieldValue.increment(points),        // ✅ Untuk UI
'totalPoints': FieldValue.increment(points),   // ✅ Untuk history
```

### **2. Sync Existing Data**

Karena user kamu sudah punya `totalPoints: 400` tapi `points: 0`, kita perlu **sync sekali**.

---

## 🔧 Option A: Manual Fix via Firebase Console (RECOMMENDED)

### **Langkah:**

1. **Buka Firebase Console:**
   - https://console.firebase.google.com
   - Pilih project: `learning-app-flutter-13319`
   - Firestore Database

2. **Find User Document:**
   - Collection: `users`
   - Document ID: `SRCDVJXkLUNK91ZVBzH1KZ6Dbys2` (atau user kamu)

3. **Edit Field `points`:**
   - Klik field `points`
   - Ubah dari `0` menjadi `400` (sama dengan `totalPoints`)
   - Save

4. **Restart App:**
   ```bash
   # Hot restart di Flutter
   flutter run
   # atau tekan 'R' di terminal
   ```

5. **Verify:**
   - Cek home screen
   - Points seharusnya muncul: `400`
   - Indikator `+50` / `+10` akan hilang

---

## 🔧 Option B: Programmatic Migration (Advanced)

### **Create Migration Script:**

```dart
// lib/app/data/migrations/sync_points_migration.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SyncPointsMigration {
  static Future<void> syncUserPoints(String userId) async {
    try {
      print('🔄 Starting points sync for user: $userId');
      
      // Get current user doc
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (!doc.exists) {
        print('❌ User not found');
        return;
      }
      
      final data = doc.data() ?? {};
      final totalPoints = data['totalPoints'] ?? 0;
      final currentPoints = data['points'] ?? 0;
      
      print('📊 Current state:');
      print('  - points: $currentPoints');
      print('  - totalPoints: $totalPoints');
      
      // Sync points to match totalPoints
      if (currentPoints != totalPoints) {
        print('🔧 Syncing points...');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'points': totalPoints,
          'updatedAt': Timestamp.now(),
        });
        
        print('✅ Points synced: $currentPoints → $totalPoints');
      } else {
        print('✅ Points already in sync');
      }
    } catch (e) {
      print('❌ Error syncing points: $e');
    }
  }
  
  /// Sync all users (Admin only)
  static Future<void> syncAllUsers() async {
    try {
      print('🔄 Starting bulk sync for all users...');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      print('📊 Found ${snapshot.docs.length} users');
      
      int synced = 0;
      for (var doc in snapshot.docs) {
        await syncUserPoints(doc.id);
        synced++;
      }
      
      print('✅ Bulk sync completed: $synced users processed');
    } catch (e) {
      print('❌ Error in bulk sync: $e');
    }
  }
}
```

### **Use Migration in App:**

```dart
// Di AuthController atau HomeController, tambahkan ini ONE TIME saja

import 'package:learning_app/app/data/migrations/sync_points_migration.dart';

// Setelah login, sync points sekali
@override
void onReady() {
  super.onReady();
  
  // ONE TIME MIGRATION - Hapus setelah selesai!
  final uid = getCurrentUserUID();
  if (uid != null) {
    SyncPointsMigration.syncUserPoints(uid);
  }
}
```

### **Run Migration:**

```bash
# 1. Buat file migration
mkdir -p lib/app/data/migrations
# Copy script di atas ke file

# 2. Tambahkan ke AuthController/HomeController

# 3. Hot restart
flutter run

# 4. Check log
# Harus ada:
# 🔄 Starting points sync...
# ✅ Points synced: 0 → 400

# 5. HAPUS migration code setelah selesai
# (jangan biarkan running terus)
```

---

## 🧠 Understanding the Fix

### **Before Fix:**
```
Quiz Selesai
    ↓
updatePoints(100)
    ↓
Firestore Update: {
  'totalPoints': FieldValue.increment(100)  ✅ Update
}
    ↓
Database: {
  points: 0,          ❌ Tetap 0 (TIDAK di-update)
  totalPoints: 400    ✅ Bertambah
}
    ↓
UI reads 'points' → Tampil: 0  ❌ SALAH!
```

### **After Fix:**
```
Quiz Selesai
    ↓
updatePoints(100)
    ↓
Firestore Update: {
  'points': FieldValue.increment(100),        ✅ Update untuk UI
  'totalPoints': FieldValue.increment(100),   ✅ Update untuk history
}
    ↓
Database: {
  points: 100,        ✅ Bertambah!
  totalPoints: 500    ✅ Bertambah!
}
    ↓
UI reads 'points' → Tampil: 100  ✅ BENAR!
```

---

## 🧪 Testing After Migration

### **Test 1: Verify Sync**

```bash
# 1. Check Firebase Console
# users/[userId]
# points: 400  ✅ (harus sama dengan totalPoints)

# 2. Check Home Screen
# Points card: 400  ✅
# Indikator +50/+10: HILANG  ✅
```

### **Test 2: New Quiz Completion**

```bash
# 1. Selesaikan quiz baru (first time pass)
# 2. Check log:
🔧 UserRepository.updatePoints: Updating 100 points
🔧 UserRepository.updatePoints result: true

# 3. Check Database:
points: 500        ✅ Bertambah dari 400 → 500
totalPoints: 500   ✅ Bertambah dari 400 → 500

# 4. Check Home Screen:
Points: 500  ✅
+100 indicator muncul  ✅
Hilang setelah 3 detik  ✅
```

---

## ✅ Success Criteria

**Migration berhasil jika:**

1. ✅ `points` di Firestore **sama dengan** `totalPoints`
2. ✅ Points **muncul** di home screen UI
3. ✅ Indikator `+50` / `+10` **hilang**
4. ✅ Quiz baru **update points dengan benar**
5. ✅ Tidak ada error di console

---

## 🐛 Troubleshooting

### **Q: Points masih 0 di home screen setelah sync?**

**A:** 
1. Force close app (jangan cuma hot reload)
2. Flutter run ulang
3. Check Firebase Console - apakah `points` sudah 400?
4. Check log - apakah stream listener receive update?

### **Q: Indikator +50/+10 masih muncul?**

**A:**
Ini karena `recentPointsGained` masih bernilai 50 dari session sebelumnya.

**Fix:**
1. Force close app
2. Run ulang
3. Atau tunggu 3 detik (auto-hide)

### **Q: totalPoints dan points beda nilai?**

**A:**
Ulangi migration sync:
```dart
SyncPointsMigration.syncUserPoints(userId);
```

---

## 📝 Recommended Approach

**Untuk kasus kamu (hanya 1-2 user):**

👉 **Gunakan Option A (Manual via Firebase Console)**

**Kenapa?**
- ✅ Lebih cepat (1 menit)
- ✅ Lebih aman (tidak perlu coding)
- ✅ Tidak perlu migration script
- ✅ Langsung keliatan hasilnya

**Steps:**
1. Firebase Console → Firestore
2. `users/SRCDVJXkLUNK91ZVBzH1KZ6Dbys2`
3. Edit `points`: `0` → `400`
4. Save
5. Restart app
6. Done! 🎉

---

## 🚀 Moving Forward

**Setelah migration:**

1. ✅ Pull latest code:
   ```bash
   git pull origin main
   flutter clean
   flutter pub get
   flutter run
   ```

2. ✅ Test quiz baru:
   - Points akan update di KEDUA field
   - UI akan update real-time
   - Indikator akan hilang otomatis

3. ✅ Semua user baru:
   - Otomatis sinkron (karena code sudah fix)
   - Tidak perlu migration manual

---

**Happy Migration! 🎉**
