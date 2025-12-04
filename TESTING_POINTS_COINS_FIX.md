# 🧪 Testing Guide: Points & Coins Update Fix

## 🔴 Masalah yang Diperbaiki

**Sebelumnya:**
- Points dan Coins **TIDAK update** setelah quiz selesai
- Indikator `+50` dan `+10` **tidak hilang** dari UI
- Stream listener **tidak menerima** update real-time dari Firestore

**Solusi:**
1. ✅ Perbaiki `_subscribeToUserProfile()` di `HomeController`
2. ✅ Tambah `forceReloadUserProfile()` untuk force refresh
3. ✅ Tambah auto-hide untuk indikator rewards (3 detik)
4. ✅ Panggil force reload setelah quiz selesai di `QuizController`

---

## 🛠️ File yang Diubah

### 1. `lib/presentation/controllers/home_controller.dart`
**Perubahan:**
- ✅ Tambah `recentPointsGained` dan `recentCoinsGained` observables
- ✅ Perbaiki `_subscribeToUserProfile()` dengan logging detail
- ✅ Tambah auto-hide animation (3 detik) untuk indikator `+points/+coins`
- ✅ Tambah `forceReloadUserProfile()` method untuk force refresh
- ✅ Tambah force reload di `refreshDashboard()`

### 2. `lib/presentation/controllers/quiz_controller.dart`
**Perubahan:**
- ✅ Import `HomeController`
- ✅ Panggil `homeController.forceReloadUserProfile()` setelah rewards update
- ✅ Tambah error handling jika HomeController belum initialized

---

## 🧠 Cara Kerja Update Real-time

```
Quiz Selesai
    ↓
[QuizController.submitQuiz()]
    ↓
Update Points & Coins ke Firestore
    ↓
Panggil authController.loadUserData()
    ↓
Panggil homeController.forceReloadUserProfile()
    ↓
[HomeController Stream Listener]
    ↓
Deteksi perubahan points/coins
    ↓
Update UI + Tampilkan +points/+coins
    ↓
Auto-hide setelah 3 detik
```

---

## 🧪 Testing Checklist

### 🟢 Test 1: First Time Pass Quiz (Dapat Rewards)

**Langkah:**
1. Hot restart aplikasi: `flutter run` atau tekan `R` di terminal
2. Login dengan user baru / user yang belum pernah pass quiz tertentu
3. Catat points & coins awal di home screen
4. Buka quiz yang belum pernah di-pass
5. Jawab quiz sampai **score ≥ passing score** (misal 70%)
6. Submit quiz
7. Kembali ke home screen

**Expected Result:**
- ✅ Points **bertambah** sesuai reward quiz (misal +100)
- ✅ Coins **bertambah** sesuai reward quiz (misal +100)
- ✅ Indikator `+100` muncul di points card
- ✅ Indikator `+100` muncul di coins card
- ✅ Kedua indikator **hilang otomatis** setelah 3 detik
- ✅ Level/Streak juga terupdate (jika ada logic)

**Log yang Harus Muncul:**
```
🎯 Updating user stats with rewards...
✅ updatePoints result: true
✅ updateCoins result: true
🎉 REWARDS SUCCESSFULLY UPDATED!
🔄 Force reloading HomeController profile...
✅ HomeController profile reloaded successfully
📥 Received profile update: [new_points], [new_coins]
✅ Points gained: 100
✅ Coins gained: 100
```

---

### 🟡 Test 2: Retry Quiz (Sudah Pernah Pass = Tidak Dapat Rewards)

**Langkah:**
1. Gunakan user yang **sudah pernah pass** quiz tertentu
2. Catat points & coins awal
3. Retry quiz yang sama
4. Pass lagi dengan score baik
5. Submit quiz
6. Kembali ke home screen

**Expected Result:**
- ✅ Points **TIDAK bertambah** (tetap)
- ✅ Coins **TIDAK bertambah** (tetap)
- ✅ **Tidak ada** indikator `+points/+coins`
- ✅ UI tetap stabil (tidak error)

**Log yang Harus Muncul:**
```
📊 hasPassedBefore: true
🎁 shouldAwardRewards: false (isPassed: true, hasPassedBefore: true)
💰 Calculated rewards: 0 points, 0 coins
ℹ️ Quiz passed, but rewards already claimed on first pass
```

---

### 🔴 Test 3: Failed Quiz (Tidak Pass = Tidak Dapat Rewards)

**Langkah:**
1. Buka quiz baru
2. Catat points & coins awal
3. Jawab quiz dengan **score < passing score** (misal 50%)
4. Submit quiz
5. Kembali ke home screen

**Expected Result:**
- ✅ Points **TIDAK bertambah**
- ✅ Coins **TIDAK bertambah**
- ✅ **Tidak ada** indikator `+points/+coins`
- ✅ UI tetap stabil

**Log yang Harus Muncul:**
```
🎁 shouldAwardRewards: false (isPassed: false, hasPassedBefore: false)
💰 Calculated rewards: 0 points, 0 coins
❌ Quiz not passed, no rewards given
```

---

### 🔵 Test 4: Pull to Refresh di Home Screen

**Langkah:**
1. Di home screen, swipe down untuk refresh
2. Lihat loading indicator
3. Tunggu sampai selesai

**Expected Result:**
- ✅ Loading indicator muncul
- ✅ Points & Coins **reload dari Firestore**
- ✅ Data tetap akurat (sinkron dengan database)
- ✅ Snackbar "Dashboard updated" muncul

**Log yang Harus Muncul:**
```
🔄 Force reloading user profile...
✅ Profile force-reloaded: [points] points, [coins] coins
```

---

### 🟣 Test 5: Stream Listener Real-time

**Langkah:**
1. Buka 2 device/emulator dengan user yang sama
2. Device A: Di home screen
3. Device B: Selesaikan quiz dan dapatkan rewards
4. Lihat Device A **tanpa refresh**

**Expected Result:**
- ✅ Device A **otomatis update** points & coins (real-time)
- ✅ Indikator `+points/+coins` muncul di Device A
- ✅ Auto-hide setelah 3 detik

**Log yang Harus Muncul di Device A:**
```
📥 Received profile update: [new_points], [new_coins]
✅ Points gained: [delta]
✅ Coins gained: [delta]
🔄 UserModel updated: [points] points, [coins] coins
```

---

## 🐛 Debugging Tips

### Jika Points/Coins Tidak Update:

1. **Check Console Logs:**
   - Apakah ada log `✅ updatePoints result: true`?
   - Apakah ada log `✅ REWARDS SUCCESSFULLY UPDATED!`?
   - Apakah ada log `📥 Received profile update`?

2. **Check Firestore Database:**
   - Buka Firebase Console → Firestore
   - Cari collection `users` → User ID kamu
   - Lihat field `points` dan `coins` — apakah terupdate?

3. **Check Stream Listener:**
   - Apakah ada log `📡 Setting up real-time listener for user: [uid]`?
   - Jika tidak, stream listener belum initialized

4. **Force Restart:**
   - Stop aplikasi sepenuhnya
   - Run `flutter clean`
   - Run `flutter pub get`
   - Run `flutter run` lagi

### Jika Indikator +points/+coins Tidak Hilang:

1. **Check Auto-hide Logic:**
   - Apakah ada log setelah 3 detik?
   - Coba tambah log di `Future.delayed`:
   ```dart
   Future.delayed(Duration(seconds: 3), () {
     print('⏰ Auto-hiding points indicator');
     recentPointsGained.value = 0;
   });
   ```

2. **Check UI Implementation:**
   - Pastikan UI menggunakan `Obx()` untuk reactive update
   - Pastikan conditional render berdasarkan `recentPointsGained.value > 0`

---

## 📝 Expected Log Output (Full Flow)

### Saat Quiz Selesai (First Time Pass):

```
🔍 Checking if user has passed quiz before...
📊 hasPassedBefore: false
🎁 shouldAwardRewards: true (isPassed: true, hasPassedBefore: false)
💰 Calculated rewards: 100 points, 100 coins
💾 Saving quiz attempt to Firestore...
✅ Quiz attempt saved successfully
🎯 Updating user stats with rewards...
📍 User ID: SRCDVJXkLUNK91ZVBzH1KZ6Dbys2
⭐ Points to add: 100
🪙 Coins to add: 100
⏳ Calling updatePoints...
✅ updatePoints result: true
⏳ Calling updateCoins...
✅ updateCoins result: true
🎉 REWARDS SUCCESSFULLY UPDATED!
✅ Total rewards earned: 100 points, 100 coins
🔄 Reloading user data to refresh UI...
✅ User data reloaded successfully
🔄 Force reloading HomeController profile...
✅ HomeController profile reloaded successfully
```

### Saat Home Screen Menerima Update:

```
📥 Received profile update: 200, 300
✅ Points gained: 100
✅ Coins gained: 100
🔄 UserModel updated: 200 points, 300 coins
```

### Setelah 3 Detik:

```
(Indikator +100 otomatis hilang)
```

---

## ✅ Success Criteria

**Testing dianggap berhasil jika:**

1. ✅ **Points & Coins bertambah** setelah first-time pass quiz
2. ✅ **Indikator +points/+coins muncul** di UI
3. ✅ **Indikator hilang otomatis** setelah 3 detik
4. ✅ **Tidak dapat rewards** saat retry quiz yang sudah pernah pass
5. ✅ **Tidak dapat rewards** saat failed quiz
6. ✅ **Pull to refresh berfungsi** di home screen
7. ✅ **Real-time update** bekerja antar device
8. ✅ **Tidak ada error** di console
9. ✅ **UI tetap stabil** di semua scenario
10. ✅ **Data sinkron** dengan Firestore

---

## 🚀 Next Steps After Testing

Setelah semua test **PASS**:

1. ✅ Commit changes: `git add .` → `git commit -m "Fix points/coins real-time update"`
2. ✅ Push to repository: `git push origin main`
3. ✅ Update changelog/release notes
4. ✅ Deploy ke production (jika applicable)

Jika ada test yang **FAIL**:

1. ❌ Cek log error di console
2. ❌ Debug dengan breakpoints di Android Studio/VS Code
3. ❌ Review kode yang diubah
4. ❌ Ulangi testing setelah fix

---

## 📞 Support

Jika menemui masalah:
- Cek log output di console
- Review file changes di GitHub commit
- Pastikan Firestore rules allow read/write
- Verifikasi Firebase connection

**Happy Testing! 🎉**
