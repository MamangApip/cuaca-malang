# Cuaca Malang

## Deskripsi Aplikasi

Cuaca Malang adalah aplikasi mobile berbasis Flutter yang menampilkan informasi prakiraan cuaca wilayah Malang dengan memanfaatkan API dari Badan Meteorologi, Klimatologi, dan Geofisika (BMKG). Aplikasi ini dirancang untuk membantu pengguna memperoleh informasi cuaca melalui antarmuka yang sederhana dan informatif.

## Fitur Utama

- Menampilkan informasi prakiraan cuaca dan suhu.
- Menampilkan prakiraan cuaca dalam interval waktu tertentu.
- Menampilkan informasi kelembapan, kecepatan angin, arah angin beserta derajatnya, tutupan awan, dan jarak pandang.
- Menyesuaikan tampilan latar belakang berdasarkan waktu pada perangkat.
- Memperbarui informasi cuaca melalui fitur penyegaran.
- Menampilkan informasi lokasi melalui halaman peta.
- Menampilkan indikator pemuatan data dan penanganan kesalahan ketika pengambilan data mengalami kendala.
- Tampilan Latar Belakang Dinamis

## Teknologi dan Package

- **Flutter** — framework untuk pengembangan aplikasi mobile.
- **Dart** — bahasa pemrograman yang digunakan.
- **BMKG Weather API** — sumber data prakiraan cuaca.
- **http** — package untuk melakukan permintaan HTTP ke API.
- **flutter_map** — package untuk menampilkan peta.
- **latlong2** — package untuk mendukung pengolahan koordinat geografis.

## Persyaratan

Sebelum menjalankan aplikasi, pastikan perangkat pengembangan telah memiliki:

- Flutter SDK.
- Dart SDK yang sesuai dengan Flutter SDK.
- Android Studio atau Android SDK untuk menjalankan aplikasi Android.
- Visual Studio Code atau editor kode lainnya.
- Koneksi internet untuk mengambil data prakiraan cuaca dari API BMKG.

## Cara Menjalankan Aplikasi

1. Clone repository ini atau unduh source code dari GitHub.
2. Buka folder project di Visual Studio Code.
3. Buka terminal pada folder utama project.
4. Jalankan perintah berikut untuk mengunduh package yang dibutuhkan:

   ```bash
   flutter pub get
   ```

5. Pastikan perangkat Android atau emulator sudah terhubung.
6. Periksa perangkat yang tersedia dengan perintah:

   ```bash
   flutter devices
   ```

7. Jalankan aplikasi menggunakan perintah:

   ```bash
   flutter run
   ```

## Sumber Data

Data prakiraan cuaca diperoleh melalui API BMKG:

https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=35.73.05.1011

Informasi cuaca yang ditampilkan bergantung pada ketersediaan dan respons API BMKG.