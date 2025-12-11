import 'package:cloud_firestore/cloud_firestore.dart';
import '../../logbook/data/logbook_model.dart';
import '../../logbook/data/logbook_service.dart';
import 'logbook_validation_models.dart';
import 'dashboard_stats.dart';

/// Service untuk mengelola validasi logbook oleh dosen/mentor
class LogbookValidationService {
  final LogbookService _logbookService;
  final FirebaseFirestore _firestore;

  LogbookValidationService({
    LogbookService? logbookService,
    FirebaseFirestore? firestore,
  }) : _logbookService = logbookService ?? LogbookService(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Convert LogbookModel to LogbookValidationItem
  Future<LogbookValidationItem> _convertToValidationItem(
    LogbookModel logbook,
    bool isMentor,
  ) async {
    // Get student name from users collection
    String studentName = 'Mahasiswa';
    try {
      final studentDoc = await _firestore
          .collection('users')
          .doc(logbook.studentId)
          .get();
      if (studentDoc.exists) {
        studentName = studentDoc.data()?['nama'] ?? 'Mahasiswa';
      }
    } catch (e) {
      // Fallback to default name if error
    }

    // Get status based on role
    // Mentor hanya monitoring, jadi lihat status dosen
    // Dosen melakukan validasi, jadi lihat status dosen
    final status = statusFromString(logbook.statusDosen);

    return LogbookValidationItem(
      id: logbook.id ?? '',
      studentName: studentName,
      title: logbook.judulKegiatan,
      description: logbook.activity,
      dateLabel: formatDateLabel(logbook.date),
      status: status,
    );
  }

  /// Get logbooks for supervisor (dosen or mentor) as validation items
  Stream<List<LogbookValidationItem>> getValidationItems(
    String supervisorId,
    bool isMentor,
  ) {
    return _logbookService
        .getLogbooksBySupervisorId(supervisorId, isMentor)
        .asyncMap((logbooks) async {
          final items = <LogbookValidationItem>[];
          for (final logbook in logbooks) {
            final item = await _convertToValidationItem(logbook, isMentor);
            items.add(item);
          }
          return items;
        });
  }

  /// Get validation summary (counts by status)
  Stream<LogbookValidationSummary> getValidationSummary(
    String supervisorId,
    bool isMentor,
  ) {
    return _logbookService
        .getLogbooksBySupervisorId(supervisorId, isMentor)
        .map((logbooks) {
          int waitingCount = 0;
          int revisionCount = 0;
          int approvedCount = 0;

          for (final logbook in logbooks) {
            final status = logbook.statusDosen;
            switch (status.toLowerCase()) {
              case 'approved':
                approvedCount++;
                break;
              case 'rejected':
                revisionCount++;
                break;
              case 'pending':
              default:
                waitingCount++;
                break;
            }
          }

          return LogbookValidationSummary(
            waitingCount: waitingCount,
            revisionCount: revisionCount,
            approvedCount: approvedCount,
          );
        });
  }

  /// Update logbook status
  Future<void> updateStatus(
    String logbookId,
    String status,
    String komentar,
    bool isMentor,
  ) async {
    if (isMentor) {
      await _logbookService.updateMentorStatus(logbookId, status, komentar);
    } else {
      await _logbookService.updateDosenStatus(logbookId, status, komentar);
    }
  }

  /// Get logbook detail by ID
  Future<LogbookModel?> getLogbookDetail(String logbookId) async {
    return await _logbookService.getLogbookById(logbookId);
  }

  /// Get dashboard statistics
  Stream<DashboardStats> getDashboardStats(String supervisorId, bool isMentor) {
    return _logbookService
        .getLogbooksBySupervisorId(supervisorId, isMentor)
        .map((logbooks) {
          int approvedCount = 0;
          int revisionCount = 0;
          int pendingCount = 0;
          final Set<String> uniqueStudents = {};

          for (final logbook in logbooks) {
            // Count unique students
            uniqueStudents.add(logbook.studentId);

            // Count by status
            final status = logbook.statusDosen;
            switch (status.toLowerCase()) {
              case 'approved':
                approvedCount++;
                break;
              case 'rejected':
                revisionCount++;
                break;
              case 'pending':
              default:
                pendingCount++;
                break;
            }
          }

          return DashboardStats(
            totalLogbooks: logbooks.length,
            approvedCount: approvedCount,
            revisionCount: revisionCount,
            pendingCount: pendingCount,
            studentCount: uniqueStudents.length,
          );
        });
  }

  /// Get recent logbooks for dashboard
  Stream<List<LogbookValidationItem>> getRecentActivities(
    String supervisorId,
    bool isMentor, {
    int limit = 5,
  }) {
    return _logbookService
        .getRecentLogbooksBySupervisorId(supervisorId, isMentor, limit: limit)
        .asyncMap((logbooks) async {
          final items = <LogbookValidationItem>[];
          for (final logbook in logbooks) {
            final item = await _convertToValidationItem(logbook, isMentor);
            items.add(item);
          }
          return items;
        });
  }
}
