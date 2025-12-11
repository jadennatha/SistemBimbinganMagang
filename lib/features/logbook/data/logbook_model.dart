import 'package:cloud_firestore/cloud_firestore.dart';

class LogbookModel {
  final String? id;
  final String studentId;
  final DateTime date;
  final String activity;
  final String komentar;
  final String statusDosen;
  final String dosenId;
  final String mentorId;
  final String judulKegiatan;
  final DateTime createdAt;

  LogbookModel({
    this.id,
    required this.studentId,
    required this.date,
    required this.activity,
    required this.judulKegiatan,
    this.komentar = '',
    this.statusDosen = 'pending',
    required this.dosenId,
    required this.mentorId,
    required this.createdAt,
  });

  factory LogbookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LogbookModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      activity: data['activity'] ?? '',
      judulKegiatan: data['judulKegiatan'] ?? '',
      komentar: data['komentar'] ?? '',
      statusDosen: data['statusDosen'] ?? 'pending',
      dosenId: data['dosenId'] ?? '',
      mentorId: data['mentorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'activity': activity,
      'judulKegiatan': judulKegiatan,
      'komentar': komentar,
      'statusDosen': statusDosen,
      'dosenId': dosenId,
      'mentorId': mentorId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  LogbookModel copyWith({
    String? id,
    String? studentId,
    DateTime? date,
    String? activity,
    String? judulKegiatan,
    String? komentar,
    String? statusDosen,
    String? dosenId,
    String? mentorId,
  }) {
    return LogbookModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      activity: activity ?? this.activity,
      judulKegiatan: judulKegiatan ?? this.judulKegiatan,
      komentar: komentar ?? this.komentar,
      statusDosen: statusDosen ?? this.statusDosen,
      dosenId: dosenId ?? this.dosenId,
      mentorId: mentorId ?? this.mentorId,
      createdAt: createdAt,
    );
  }
}
