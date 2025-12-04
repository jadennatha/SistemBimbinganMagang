/// Status logbook yang digunakan dosen saat memeriksa.
enum LogbookStatus {
  waiting, // menunggu dicek
  revision, // perlu revisi
  approved, // sudah disetujui
}

/// Model satu entri logbook untuk tampilan validasi dosen.
class LogbookValidationItem {
  final String id;
  final String studentName;
  final String title;
  final String description;
  final String dateLabel;
  final LogbookStatus status;

  const LogbookValidationItem({
    required this.id,
    required this.studentName,
    required this.title,
    required this.description,
    required this.dateLabel,
    required this.status,
  });

  // Getter bantu untuk UI
  bool get isWaiting => status == LogbookStatus.waiting;
  bool get isRevision => status == LogbookStatus.revision;
  bool get isApproved => status == LogbookStatus.approved;

  String get statusLabel {
    switch (status) {
      case LogbookStatus.waiting:
        return 'Menunggu cek';
      case LogbookStatus.revision:
        return 'Perlu revisi';
      case LogbookStatus.approved:
        return 'Disetujui';
    }
  }
}

/// Ringkasan jumlah logbook per status, misalnya untuk kartu di bagian atas.
class LogbookValidationSummary {
  final int waitingCount;
  final int revisionCount;
  final int approvedCount;

  const LogbookValidationSummary({
    required this.waitingCount,
    required this.revisionCount,
    required this.approvedCount,
  });

  int get total => waitingCount + revisionCount + approvedCount;
}

/// Data contoh untuk tampilan UI (belum terhubung backend).
const List<LogbookValidationItem> demoLogbookValidationItems = [
  LogbookValidationItem(
    id: '1',
    studentName: 'Alya Putri',
    title: 'Laporan harian',
    description: 'Update pekerjaan modul aplikasi dan pengecekan hasil.',
    dateLabel: 'Hari ini • 09.30',
    status: LogbookStatus.waiting,
  ),
  LogbookValidationItem(
    id: '2',
    studentName: 'Budi Santoso',
    title: 'Observasi lapangan',
    description: 'Kunjungan ke perusahaan mitra, mencatat alur kerja tim.',
    dateLabel: 'Kemarin • 14.10',
    status: LogbookStatus.revision,
  ),
  LogbookValidationItem(
    id: '3',
    studentName: 'Citra Lestari',
    title: 'Diskusi dengan pembimbing',
    description: 'Review progres laporan magang dan rencana perbaikan.',
    dateLabel: '2 hari lalu • 10.00',
    status: LogbookStatus.approved,
  ),
];

/// Ringkasan contoh untuk kartu di atas list.
const LogbookValidationSummary demoLogbookSummary = LogbookValidationSummary(
  waitingCount: 2,
  revisionCount: 1,
  approvedCount: 1,
);
