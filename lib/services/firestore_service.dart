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
    return _db
        .collection(_userCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data() as Map<String, dynamic>;
            return data['nama'] ?? '-';
          } else {
            return '-';
          }
        });
  }
}