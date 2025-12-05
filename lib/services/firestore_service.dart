import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // <-- Pastikan import ini sesuai lokasi file modelmu

class FirestoreService {
  // Instance database
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Nama Collection di Firestore
  final String _userCollection = 'users';

  // 1. Fungsi Simpan User (Dipakai saat Register)
  Future<void> saveUser(UserModel user) async {
    try {
      await _db.collection(_userCollection).doc(user.uid).set(user.toMap());
    } catch (e) {
      print("Error saving user: $e");
      rethrow;
    }
  }

  // 2. Fungsi Ambil Data User Realtime (Dipakai di Profile Page)
  Stream<UserModel> getUserStream(String uid) {
    return _db
        .collection(_userCollection)
        .doc(uid)
        .snapshots() // Stream: update otomatis kalau data berubah
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            // Convert data JSON dari Firestore ke Object UserModel
            return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
          } else {
            // Kalau dokumen ga ada, lempar error atau return default
            throw Exception("Data user tidak ditemukan di database!");
          }
        });
  }

  // 3. Fungsi Ambil Nama User/Dosen berdasarkan UID
  Future<String> getUserNameByUID(String uid) async {
    try {
      final docSnapshot = await _db.collection(_userCollection).doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['nama'] ?? '-';
      } else {
        return '-';
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return '-';
    }
  }

  // 4. Fungsi Ambil Nama Dosen secara Realtime (Stream)
  Stream<String> getUserNameStream(String uid) {
    return _db.collection(_userCollection).doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data['nama'] ?? '-';
      } else {
        return '-';
      }
    });
  }

  Stream<String> getUserTotalInternday(String uid) {
    return _db.collection(_userCollection).doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final tglMulai = userData['tglMulai'];
        final tglSelesai = userData['tglSelesai'];

        if (tglMulai == null || tglSelesai == null) {
          return '-';
        }

        DateTime startDate;
        DateTime endDate;

        // Parse tanggal dari Firestore (bisa Timestamp, String, atau DateTime)
        if (tglMulai is Timestamp) {
          startDate = tglMulai.toDate();
        } else if (tglMulai is String) {
          startDate = DateTime.parse(tglMulai);
        } else if (tglMulai is DateTime) {
          startDate = tglMulai;
        } else {
          return '-';
        }

        if (tglSelesai is Timestamp) {
          endDate = tglSelesai.toDate();
        } else if (tglSelesai is String) {
          endDate = DateTime.parse(tglSelesai);
        } else if (tglSelesai is DateTime) {
          endDate = tglSelesai;
        } else {
          return '-';
        }

        // Hitung total hari (tidak termasuk jam, hanya hari)
        final startDateOnly = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
        final totalDays = endDateOnly.difference(startDateOnly).inDays + 1;

        return totalDays.toString();
      } else {
        return '-';
      }
    });
  }

  // 5. Fungsi Hitung Progress Magang (real-time)
  // Menghitung banyak logbook dibagi total hari magang
  Stream<double> getInternshipProgressStream(
    String studentId,
    String logbookCollection,
  ) {
    return _db
        .collection(_userCollection)
        .doc(studentId)
        .snapshots()
        .asyncExpand((userSnapshot) async* {
          if (!userSnapshot.exists || userSnapshot.data() == null) {
            yield 0.0;
            return;
          }

          final userData = userSnapshot.data() as Map<String, dynamic>;
          final tglMulai = userData['tglMulai'];
          final tglSelesai = userData['tglSelesai'];

          if (tglMulai == null || tglSelesai == null) {
            yield 0.0;
            return;
          }

          DateTime startDate;
          DateTime endDate;

          // Parse tanggal dari Firestore (bisa Timestamp, String, atau DateTime)
          if (tglMulai is Timestamp) {
            startDate = tglMulai.toDate();
          } else if (tglMulai is String) {
            startDate = DateTime.parse(tglMulai);
          } else if (tglMulai is DateTime) {
            startDate = tglMulai;
          } else {
            yield 0.0;
            return;
          }

          if (tglSelesai is Timestamp) {
            endDate = tglSelesai.toDate();
          } else if (tglSelesai is String) {
            endDate = DateTime.parse(tglSelesai);
          } else if (tglSelesai is DateTime) {
            endDate = tglSelesai;
          } else {
            yield 0.0;
            return;
          }

          // Hitung total hari (tidak termasuk jam, hanya hari)
          final startDateOnly = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          final endDateOnly = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
          );
          final totalDays = endDateOnly.difference(startDateOnly).inDays + 1;

          if (totalDays <= 0) {
            yield 0.0;
            return;
          }

          // Stream logbook count
          yield* _db
              .collection(logbookCollection)
              .where('studentId', isEqualTo: studentId)
              .where('statusDosen', isEqualTo: 'approved')
              .snapshots()
              .map((snapshot) {
                final logbookCount = snapshot.docs.length;
                final progress = (logbookCount / totalDays).clamp(0.0, 1.0);
                return progress;
              });
        });
  }
}
