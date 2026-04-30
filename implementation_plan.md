# Implementation Plan: Aplikasi Rekomendasi Tempat Makan ("FoodieFinder")

Aplikasi mobile berbasis Flutter yang menyediakan rekomendasi tempat makan berdasarkan lokasi, preferensi, dan interaksi cerdas. Rancangan ini disusun untuk memenuhi seluruh kriteria Projek Akhir mata kuliah TPM.

## Color Palette
  **Primary**: Color(0xFFFFB84D)        // Yellow/Orange
  **Secondary**: Color(0xFFFFFFFF)      // White
  **Background**: Color(0xFFF5F5F5)     // Light Gray
  **TextPrimary**: Color(0xFF1A1A1A)    // Dark
  **TextSecondary**: Color(0xFF757575)  // Gray
  **Accent**: Color(0xFFFF6B6B)         // Red

## Keputusan Desain (Berdasarkan Feedback)
- **LLM**: Menggunakan **Google Gemini API** untuk fitur chatbot/asisten kuliner.
- **Backend & Data**: Menggunakan **Express.js** yang akan membaca data restoran dari file lokal `export.geojson` (berasal dari OpenStreetMap), menggantikan ide scraper TripAdvisor.
- **Database Auth**: Menggunakan backend custom Express.js dengan **SQLite** lokal untuk mendemonstrasikan proses enkripsi password (*SHA-256*) dan manajemen *session/token* (JWT).
- **Sensor Accelerometer**: Fitur *Shake* tidak akan langsung memberikan rekomendasi restoran, melainkan diarahkan ke fitur **Minigames (Roulette/Gacha)** untuk memberikan rekomendasi dengan elemen hiburan.

## Proposed Architecture & Tech Stack

- **Frontend Mobile**: Flutter (Multiplatform Android & iOS).
- **Backend / API**: Node.js dengan Express.js.
- **Local Storage / Database Mobile**: Hive untuk *caching* data.
- **Database Backend**: SQLite (via `sqlite3` npm) untuk menyimpan data user terenkripsi.
- **LLM/AI**: Google Gemini API (gemini-1.5-flash).
- **State Management**: Provider / Riverpod.

---

## Pemenuhan Kriteria Projek & Rencana Fitur

### 1. Konsep Projek Akhir & Mobile Programming
Aplikasi bernama **FoodieFinder**, aplikasi pencari dan pemberi rekomendasi restoran yang dikembangkan dengan **Flutter**, memastikan dukungan performa baik di Android maupun iOS dengan antarmuka dinamis dan responsif.

### 2. Login Enkripsi & Session (Non-Firebase)
- **Enkripsi**: Password pengguna akan dienkripsi menggunakan *SHA-256* dan disimpan di database backend SQLite.
- **Session**: Setelah login, backend menghasilkan *JWT token* yang dikirim ke aplikasi. Aplikasi menyimpannya secara aman menggunakan `flutter_secure_storage`. Selama token masih valid, user tidak perlu login ulang.

### 3. Login Biometric
- Menggunakan package `local_auth` di Flutter.
- Pada halaman login, terdapat opsi **"Login with Fingerprint"**. Setelah user berhasil login normal untuk pertama kali, sistem akan mengizinkan otentikasi biometrik untuk masuk di sesi berikutnya dengan menggunakan token yang tersimpan.

### 4. Database / Penyimpanan Mobile
- Menggunakan **Hive** untuk menyimpan preferensi aplikasi (*dark mode*, konfigurasi) dan token *session* secara cepat. (Data relasional user ditangani oleh SQLite di backend).

### 5. Web Service / API & LBS (Location Based Service)
- **Web Service API**: Aplikasi mengambil daftar restoran dari Endpoint Express.js yang membaca data `export.geojson`.
- **LBS**: Menggunakan package `geolocator` untuk mendeteksi kordinat GPS perangkat dan `google_maps_flutter` untuk menampilkan peta restoran terdekat.

### 6. Menu Bottom Navigation
Navigasi bawah (*BottomNavigationBar*) akan memiliki 3 menu utama:
1. **Home**: Terdapat *nama aplikasi* di AppBar kiri atas, *button notifikasi* yang menuju halaman notifikasi untuk menampilkan seluruh notifikasi, menampilkan *daftar rekomendasi restoran* berdasarkan data `export.geojson`. Dan apabila user menekan salah satu restoran akan menuju ke halaman detail restoran.
2. **Search**: Halaman untuk mencari restoran berdasarkan filter (*harga*, *jenis restoran*, *jarak*, atau apapun yang sesuai dengan data di `export.geojson`) menggunakan *chips*.
3. **Profil**: Halaman profil yang menampilkan *foto pengguna*, card **Kesan & Saran TPM** (nanti aku yang mengisi sendiri teksnya), serta sub-menu pengaturan. Dan terdapat **Logout** di kanan atas AppBar: Tombol untuk menghapus *session* aktif dan mengembalikan pengguna ke halaman Login.

### 7. Menu Konversi Mata Uang & Konversi Waktu
- **Konversi Waktu**: Saat user melihat detail restoran, akan ditampilkan jam operasional dalam beberapa zona waktu (WIB, WIT, WITA, dan **London**).
- **Konversi Mata Uang**: Pada daftar menu makanan atau estimasi harga restoran, user dapat mengkonversi harga IDR ke **USD, EUR, JPY**.

### 8. Sensor (Accelerometer & Gyroscope)
- **Accelerometer (*Shake to Minigame*)**: Saat bingung, user cukup *menggoyangkan* ponsel (shake). Sensor accelerometer akan mendeteksi gerakan ini dan secara otomatis memunculkan **Minigame Roulette/Gacha** untuk diundi.
- **Gyroscope (*Parallax Effect*)**: Pada halaman detail restoran, foto restoran dapat *digoyangkan* menggunakan gyroscope untuk menyesuaikan arah rotasi berdasarkan orientasi HP.

### 9. Fitur AI/ML dan LLM
- Menggunakan **Google Gemini API** (LLM) untuk fitur **"Asisten Kuliner"**.

### 10. Fitur Mini Games Sederhana
- **"Food Roulette / Gacha"**: Roda keberuntungan berisi kategori makanan atau restoran terdekat. Dipicu secara *Shake* accelerometer.

### 11. Pencarian, Pemilihan, & Notifikasi
- **Pencarian**: Fitur *Search bar*.
- **Notifikasi**: Menggunakan `flutter_local_notifications` untuk *"Meal Time Reminder"*.

---

## Verification Plan

### Langkah Pengujian (Testing)
1. **Testing Otentikasi**: Register API -> Enkripsi SHA-256 jalan -> Login API (dapat JWT) -> Login Flutter via Biometric.
2. **Testing API Restoran**: Membaca data GeoJSON dari Express API via Postman/Flutter.
3. **Testing Hardware / Sensor**: 
   - Tes LBS GPS: Peta tampil di koordinat saat ini.
   - Tes Accelerometer: Goyangkan HP memicu transisi ke halaman Roulette.
4. **Testing AI & Fitur Tambahan**: Tes Gemini Chat, konversi mata uang, konversi zona waktu, dan notifikasi lokal.
