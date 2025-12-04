import 'package:cloud_firestore/cloud_firestore.dart';

class LogbookModel {
  final String? id;
  final String studentId;
  final DateTime date;
  final String activity;
  final String komentar;
  final String statusDosen;
  final String statusMentor;
  final String dosenId;
  final String mentorId;
  final String judulKegiatan;

  LogbookModel({
    this.id,
    required this.studentId,
    required this.date,
    required this.activity,
    required this.judulKegiatan,
    this.komentar = '',
    this.statusDosen = 'pending',
    this.statusMentor = 'pending',
    required this.dosenId,
    required this.mentorId,
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
      statusMentor: data['statusMentor'] ?? 'pending',
      dosenId: data['dosenId'] ?? '',
      mentorId: data['mentorId'] ?? '',
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
      'statusMentor': statusMentor,
      'dosenId': dosenId,
      'mentorId': mentorId,
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
    String? statusMentor,
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
      statusMentor: statusMentor ?? this.statusMentor,
      dosenId: dosenId ?? this.dosenId,
      mentorId: mentorId ?? this.mentorId,
    );
  }
}
