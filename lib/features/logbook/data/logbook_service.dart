import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logbook_model.dart';

class LogbookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constructor
  LogbookService();

  // Create logbook entry
  Future<String> createLogbook(LogbookModel logbook) async {
    try {
      final docRef = await _firestore
          .collection('logbooks')
          .add(logbook.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal membuat logbook: $e');
    }
  }

  // Read all logbooks for current student
  Stream<List<LogbookModel>> getStudentLogbooks(String studentId) {
    return _firestore
        .collection('logbooks')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LogbookModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<LogbookModel>> getStudentLogbooksVerified(String studentId) {
    return _firestore
        .collection('logbooks')
        .where('studentId', isEqualTo: studentId)
        .where('statusDosen', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LogbookModel.fromFirestore(doc))
              .toList();
        });
  }

  // Read single logbook
  Future<LogbookModel?> getLogbookById(String logbookId) async {
    try {
      final doc = await _firestore.collection('logbooks').doc(logbookId).get();
      if (doc.exists) {
        return LogbookModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil logbook: $e');
    }
  }

  // Update logbook entry
  Future<void> updateLogbook(String logbookId, LogbookModel logbook) async {
    try {
      await _firestore
          .collection('logbooks')
          .doc(logbookId)
          .update(logbook.toFirestore());
    } catch (e) {
      throw Exception('Gagal mengupdate logbook: $e');
    }
  }

  // Delete logbook entry
  Future<void> deleteLogbook(String logbookId) async {
    try {
      await _firestore.collection('logbooks').doc(logbookId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus logbook: $e');
    }
  }

  // Get logbook entries by date range
  Stream<List<LogbookModel>> getLogbooksByDateRange(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('logbooks')
        .where('studentId', isEqualTo: studentId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LogbookModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get current user's ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Get logbooks for dosen (filter by dosenId)
  Stream<List<LogbookModel>> getLogbooksByDosenId(String dosenId) {
    return _firestore
        .collection('logbooks')
        .where('dosenId', isEqualTo: dosenId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LogbookModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get logbooks for mentor (filter by mentorId)
  Stream<List<LogbookModel>> getLogbooksByMentorId(String mentorId) {
    return _firestore
        .collection('logbooks')
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LogbookModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get logbooks by supervisor (dosen or mentor)
  Stream<List<LogbookModel>> getLogbooksBySupervisorId(
    String supervisorId,
    bool isMentor,
  ) {
    if (isMentor) {
      return getLogbooksByMentorId(supervisorId);
    } else {
      return getLogbooksByDosenId(supervisorId);
    }
  }

  // Get logbooks by status for dosen
  Stream<List<LogbookModel>> getLogbooksByDosenIdAndStatus(
    String dosenId,
    String status,
  ) {
    return _firestore
        .collection('logbooks')
        .where('dosenId', isEqualTo: dosenId)
        .where('statusDosen', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LogbookModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get logbooks by status for mentor
  Stream<List<LogbookModel>> getLogbooksByMentorIdAndStatus(
    String mentorId,
    String status,
  ) {
    return _firestore
        .collection('logbooks')
        .where('mentorId', isEqualTo: mentorId)
        .where('statusMentor', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LogbookModel.fromFirestore(doc))
              .toList();
        });
  }

  // Update status dosen
  Future<void> updateDosenStatus(
    String logbookId,
    String status,
    String komentar,
  ) async {
    try {
      await _firestore.collection('logbooks').doc(logbookId).update({
        'statusDosen': status,
        'komentar': komentar,
      });
    } catch (e) {
      throw Exception('Gagal mengupdate status: $e');
    }
  }

  // Update status mentor
  Future<void> updateMentorStatus(
    String logbookId,
    String status,
    String komentar,
  ) async {
    try {
      await _firestore.collection('logbooks').doc(logbookId).update({
        'statusMentor': status,
        'komentar': komentar,
      });
    } catch (e) {
      throw Exception('Gagal mengupdate status: $e');
    }
  }

  // Get recent logbooks for supervisor (limited)
  Stream<List<LogbookModel>> getRecentLogbooksBySupervisorId(
    String supervisorId,
    bool isMentor, {
    int limit = 5,
  }) {
    final field = isMentor ? 'mentorId' : 'dosenId';
    return _firestore
        .collection('logbooks')
        .where(field, isEqualTo: supervisorId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LogbookModel.fromFirestore(doc))
              .toList();
        });
  }
}
