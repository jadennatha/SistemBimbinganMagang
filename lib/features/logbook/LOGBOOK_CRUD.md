# Fitur Logbook - CRUD Documentation

## Deskripsi
Fitur Logbook adalah sistem manajemen catatan kegiatan magang yang terintegrasi dengan Firebase Firestore. Pengguna dapat membuat, membaca, mengupdate, dan menghapus catatan harian kegiatan mereka.

## Struktur Folder

```
lib/features/logbook/
├── models/
│   └── logbook_model.dart       # Model data Logbook
├── services/
│   └── logbook_service.dart     # Service untuk CRUD Firestore
├── widgets/
│   └── logbook_form_dialog.dart # Widget form input logbook
├── logbook_content.dart         # Main content dengan list logbook
├── logbook_screen.dart          # Screen wrapper
```

## Komponen Utama

### 1. LogbookModel (`models/logbook_model.dart`)
Model data dengan field:
- `id`: ID document Firestore (nullable)
- `studentId`: ID siswa/mahasiswa
- `date`: Tanggal aktivitas
- `activity`: Deskripsi aktivitas (required)
- `komentar`: Komentar tambahan (optional)
- `statusDosen`: Status persetujuan dosen (default: 'pending')
- `statusMentor`: Status persetujuan mentor (default: 'pending')
- `doseId`: ID dosen pembimbing
- `mentorId`: ID mentor industri

### 2. LogbookService (`services/logbook_service.dart`)
Service untuk operasi Firestore dengan method:
- `createLogbook(LogbookModel)`: Membuat logbook baru
- `getStudentLogbooks(studentId)`: Mendapatkan semua logbook siswa (Stream)
- `getLogbookById(logbookId)`: Mendapatkan logbook spesifik
- `updateLogbook(logbookId, LogbookModel)`: Update logbook
- `deleteLogbook(logbookId)`: Hapus logbook
- `getLogbooksByDateRange(studentId, startDate, endDate)`: Filter berdasarkan rentang tanggal
- `getCurrentUserId()`: Mendapatkan ID user yang sedang login

### 3. LogbookFormDialog (`widgets/logbook_form_dialog.dart`)
Dialog form untuk input/edit logbook dengan fitur:
- Date picker untuk memilih tanggal aktivitas
- Text field untuk aktivitas (required)
- Text field untuk komentar (optional)
- Validasi input
- Support untuk create dan update

### 4. LogbookContent (`logbook_content.dart`)
Widget utama dengan fitur:
- List semua logbook pengguna
- Tombol "Catat Hari Ini" untuk membuat logbook baru
- Edit logbook
- Hapus logbook dengan konfirmasi
- Real-time update menggunakan StreamBuilder
- Status display untuk approval dosen dan mentor

## Firestore Structure

Collection: `logbooks`
```json
{
  "studentId": "string",
  "date": "timestamp",
  "activity": "string",
  "komentar": "string",
  "statusDosen": "string (pending|approved|rejected)",
  "statusMentor": "string (pending|approved|rejected)",
  "doseId": "string",
  "mentorId": "string"
}
```

## Cara Penggunaan

### 1. Membuat Logbook Baru
Tekan tombol "Catat Hari Ini" → Isi tanggal dan aktivitas → Klik "Simpan"

### 2. Mengedit Logbook
Klik icon edit pada card logbook → Ubah data → Klik "Simpan"

### 3. Menghapus Logbook
Klik icon delete pada card logbook → Konfirmasi → Logbook dihapus

### 4. Melihat Status Approval
Status dosen dan mentor ditampilkan sebagai chip di bawah setiap logbook:
- **Pending** (abu-abu): Menunggu review
- **Approved** (hijau): Sudah disetujui
- **Rejected** (merah): Ditolak

## Fitur Tambahan

### Real-time Updates
Menggunakan `StreamBuilder` dari Firestore untuk pembaruan real-time tanpa perlu refresh manual.

### Error Handling
Semua operasi dilengkapi dengan error handling dan menampilkan SnackBar untuk feedback pengguna.

### User Data Integration
Sistem otomatis mengambil `doseId` dan `mentorId` dari koleksi `users` di Firestore berdasarkan ID user yang login.

## Catatan Penting

1. **Koleksi Users**: Pastikan koleksi `users` di Firestore memiliki field `doseId` dan `mentorId`. Jika tidak ada, sistem akan menggunakan value default.

2. **Authentication**: Fitur ini memerlukan user yang sudah terautentikasi. Tanpa login, akan menampilkan error.

3. **Date Range**: Date picker hanya memungkinkan pemilihan tanggal hingga hari ini (tidak bisa memilih tanggal masa depan).

4. **Validation**: Aktivitas adalah field yang wajib diisi, komentar bersifat opsional.

## Integration dengan App

File `logbook_screen.dart` sudah diupdate untuk menggunakan `LogbookContent`. Pastikan rute navigasi sudah dikonfigurasi dengan baik di `routes.dart`.
