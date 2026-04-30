# 🌿 Pertumbuhan
### Jurnal Tanaman Pribadi Berbasis Lokasi

> Dokumentasikan perjalanan tumbuh tanaman kamu — lengkap dengan foto, lokasi, dan catatan harian.

---

## 📱 Tentang Aplikasi

**Pertumbuhan** adalah aplikasi mobile jurnal tanaman pribadi yang memungkinkan pengguna untuk mendokumentasikan setiap tahap pertumbuhan tanaman mereka. Setiap tanaman dapat dicatat beserta foto, koordinat lokasi tanam, deskripsi, dan log perkembangan harian.

Aplikasi ini dibuat sebagai tugas mata kuliah **Pemrograman Aplikasi Bergerak 2** dengan menerapkan berbagai teknologi mobile dan cloud modern.

---

## ✨ Fitur Utama

- 📷 **Foto Tanaman** — Ambil atau pilih foto langsung dari kamera/galeri menggunakan Image Picker
- 📍 **Lokasi Otomatis** — Deteksi koordinat lokasi tanam secara real-time menggunakan Geolocator
- 🗺️ **Buka di Maps** — Lihat lokasi tanaman di Google Maps via URL Launcher
- 📝 **Jurnal Pertumbuhan** — Tambah catatan log harian perkembangan tanaman
- ☁️ **Sinkronisasi Cloud** — Data tersimpan dan tersinkron via Firebase Firestore
- 🖼️ **Penyimpanan Foto** — Foto tanaman diupload ke Firebase Storage
- 💾 **Cache Lokal** — Data tersimpan lokal menggunakan SQLite untuk akses offline

---

## 🛠️ Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| **Flutter** | Framework utama pengembangan aplikasi |
| **Firebase Firestore** | Database cloud untuk menyimpan data tanaman & log |
| **Firebase Storage** | Penyimpanan foto tanaman di cloud |
| **Geolocator** | Deteksi koordinat GPS lokasi tanam |
| **Image Picker** | Mengambil foto dari kamera atau galeri |
| **URL Launcher** | Membuka lokasi di Google Maps |
| **SQLite (sqflite)** | Database lokal / cache offline |
| **Provider / Riverpod** | State management |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0

  # Location
  geolocator: ^13.0.0
  geocoding: ^3.0.0

  # Media
  image_picker: ^1.1.2

  # URL
  url_launcher: ^6.3.0

  # Local Database
  sqflite: ^2.3.3+1
  path: ^1.9.0

  # UI
  cached_network_image: ^3.4.1
  intl: ^0.19.0
```

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code
- Akun Firebase

### Langkah Instalasi

**1. Clone repository**
```bash
git clone https://github.com/username/pertumbuhan.git
cd pertumbuhan
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Setup Firebase**
- Buat project baru di [Firebase Console](https://console.firebase.google.com)
- Aktifkan **Firestore Database** dan **Firebase Storage**
- Download `google-services.json` → letakkan di `android/app/`
- Download `GoogleService-Info.plist` → letakkan di `ios/Runner/`
- Jalankan:
```bash
flutterfire configure
```

**4. Jalankan aplikasi**
```bash
flutter run
```

---

## 👨‍💻 Developer

| Nama | NIM | Kelas |
|------|-----|-------|
| Achmad Faiz Yudha Ramadhan | 2428240113 | SI6C |

---

## 📚 Mata Kuliah

> **Pemrograman Aplikasi Bergerak 2**  
> Program Studi Sistem Informasi 
> Universitas Multi Data Palembang  
> Tahun Ajaran 2025/2026

---

## 📄 Lisensi

Project ini dibuat untuk keperluan tugas akademik.  
© 202 Pertumbuhan App — All Rights Reserved.

---

<div align="center">
  <i>🌱 "Setiap tanaman punya c6erita. Pertumbuhan membantu kamu mengingatnya."</i>
</div>