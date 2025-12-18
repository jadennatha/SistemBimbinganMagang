<p align="center">
  <img src="assets/images/logo.png" alt="Logo" width="120" height="120">
</p>

<h1 align="center">📚 Sistem Bimbingan Magang</h1>

<p align="center">
  <strong>Aplikasi Mobile untuk Manajemen Bimbingan Magang Mahasiswa</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.9.0-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-Cloud-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web%20|%20Windows%20|%20macOS%20|%20Linux-blueviolet?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/Version-1.0.0-green?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/License-Private-red?style=flat-square" alt="License">
</p>

---

## 🎯 Tentang Aplikasi

**Sistem Bimbingan Magang** adalah aplikasi mobile modern yang dirancang untuk mempermudah proses bimbingan magang antara mahasiswa, dosen pembimbing, dan mentor industri. Aplikasi ini menyediakan platform terintegrasi untuk pencatatan aktivitas magang, monitoring progress, dan komunikasi antara semua pihak terkait.

### ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 📝 **Logbook Digital** | Pencatatan aktivitas harian magang dengan sistem CRUD lengkap |
| 👥 **Multi-Role System** | Dukungan untuk mahasiswa, dosen pembimbing, dan mentor industri |
| 🔔 **Notifikasi Real-time** | Pemberitahuan otomatis untuk approval dan update status |
| ☁️ **Cloud Sync** | Data tersinkronisasi secara real-time dengan Firebase |
| ✅ **Approval Workflow** | Sistem approval bertingkat dari dosen dan mentor |
| 📱 **Cross-Platform** | Berjalan di Android, iOS, Web, Windows, macOS, dan Linux |

---

## 🏗️ Arsitektur Proyek

```
lib/
├── 📱 app/                    # Konfigurasi aplikasi utama
├── 🔧 core/                   # Layanan inti & utilities
│   └── services/              # Notification service, dll
├── 🎨 features/               # Fitur-fitur aplikasi
│   ├── auth/                  # 🔐 Autentikasi pengguna
│   ├── logbook/               # 📝 Manajemen logbook
│   ├── mahasiswa/             # 👨‍🎓 Dashboard mahasiswa
│   ├── notification/          # 🔔 Notifikasi
│   ├── onboarding/            # 🚀 Onboarding screen
│   ├── pembimbing/            # 👨‍🏫 Dashboard pembimbing
│   └── splash/                # ⚡ Splash screen
├── firebase_options.dart      # Konfigurasi Firebase
└── main.dart                  # Entry point aplikasi
```

---

## 🛠️ Tech Stack

<table>
  <tr>
    <td align="center" width="96">
      <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/flutter/flutter-original.svg" width="48" height="48" alt="Flutter" />
      <br><strong>Flutter</strong>
    </td>
    <td align="center" width="96">
      <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/firebase/firebase-plain.svg" width="48" height="48" alt="Firebase" />
      <br><strong>Firebase</strong>
    </td>
    <td align="center" width="96">
      <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/dart/dart-original.svg" width="48" height="48" alt="Dart" />
      <br><strong>Dart</strong>
    </td>
  </tr>
</table>

### 📦 Dependencies

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `firebase_core` | ^4.2.1 | Firebase core functionality |
| `cloud_firestore` | ^6.1.0 | Cloud Firestore database |
| `firebase_auth` | ^6.1.2 | Autentikasi pengguna |
| `provider` | ^6.1.2 | State management |
| `shared_preferences` | ^2.5.3 | Local storage |
| `flutter_local_notifications` | ^18.0.1 | Notifikasi lokal |

---

## 🚀 Instalasi & Setup

### 📋 Prasyarat

Pastikan Anda telah menginstall:

- ✅ [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.9.0 atau lebih baru)
- ✅ [Dart SDK](https://dart.dev/get-dart) (sudah termasuk dalam Flutter)
- ✅ [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com/)
- ✅ [Git](https://git-scm.com/)
- ✅ Akun [Firebase](https://console.firebase.google.com/) (untuk konfigurasi backend)

### 📥 Langkah Instalasi

#### 1️⃣ Clone Repository

```bash
git clone https://github.com/username/SistemBimbinganMagang.git
cd SistemBimbinganMagang
```

#### 2️⃣ Install Dependencies

```bash
flutter pub get
```

#### 3️⃣ Konfigurasi Firebase

> **Note:** Proyek ini sudah memiliki konfigurasi Firebase. Jika Anda ingin menggunakan project Firebase sendiri, ikuti langkah berikut:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login ke Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Konfigurasi Firebase untuk project
flutterfire configure
```

#### 4️⃣ Jalankan Aplikasi

```bash
# Untuk mode development
flutter run

# Untuk platform spesifik
flutter run -d android    # Android
flutter run -d ios        # iOS (hanya di macOS)
flutter run -d chrome     # Web
flutter run -d windows    # Windows
flutter run -d macos      # macOS
flutter run -d linux      # Linux
```

---

## 📱 Build Production

### Android (APK/App Bundle)

```bash
# Build APK
flutter build apk --release

# Build App Bundle untuk Play Store
flutter build appbundle --release
```

Output akan tersimpan di `build/app/outputs/`

### iOS

```bash
# Build untuk iOS (hanya di macOS)
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

Output akan tersimpan di `build/web/`

### Desktop

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## 👥 Panduan Pengguna

### 🎓 Untuk Mahasiswa

1. **Login** menggunakan akun yang telah terdaftar
2. Akses **Dashboard** untuk melihat ringkasan aktivitas magang
3. Gunakan **Logbook** untuk mencatat aktivitas harian:
   - Klik "Catat Hari Ini" untuk menambah entry baru
   - Isi judul, tanggal, dan detail aktivitas
   - Status approval akan muncul setelah dosen/mentor mereview
4. Pantau **Notifikasi** untuk update status logbook

### 👨‍🏫 Untuk Dosen Pembimbing

1. **Login** dengan akun dosen
2. Lihat daftar mahasiswa bimbingan di **Dashboard**
3. Review dan approve/reject logbook mahasiswa
4. Berikan komentar dan feedback

---

## 🔐 Struktur Data Firebase

### Collection: `users`
```json
{
  "uid": "string",
  "email": "string",
  "name": "string",
  "role": "mahasiswa | dosen | mentor",
  "dosenId": "string (untuk mahasiswa)",
  "mentorId": "string (untuk mahasiswa)"
}
```

### Collection: `logbooks`
```json
{
  "studentId": "string",
  "date": "timestamp",
  "activity": "string",
  "komentar": "string",
  "statusDosen": "pending | approved | rejected",
  "statusMentor": "pending | approved | rejected",
  "dosenId": "string",
  "mentorId": "string"
}
```

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Check code analysis
flutter analyze
```

---

## 📝 Catatan Pengembangan

### Perintah Berguna

```bash
# Clean project
flutter clean

# Upgrade dependencies
flutter pub upgrade

# Generate launcher icons (jika menggunakan flutter_launcher_icons)
flutter pub run flutter_launcher_icons

# Hot reload (saat development)
# Tekan 'r' di terminal atau gunakan tombol ⚡ di IDE
```

---

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan:

1. Fork repository
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

---

## 📄 Lisensi

Proyek ini bersifat **private** dan dikembangkan untuk keperluan akademik.

---

## 👨‍💻 Developer

<p align="center">
  <strong>Dikembangkan dengan ❤️ untuk Mata Kuliah Pemrograman Mobile</strong>
  <br>
  <em>Semester 5 - 2024/2025</em>
</p>

---

<p align="center">
  <img src="https://img.shields.io/badge/Made%20with-Flutter-02569B?style=for-the-badge&logo=flutter" alt="Made with Flutter">
</p>
