import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_repository.dart';

/// Status autentikasi user
enum AuthStatus {
  /// Belum diketahui (loading awal)
  unknown,

  /// User sudah login
  authenticated,

  /// User belum login
  unauthenticated,
}

/// Role user dalam aplikasi
enum UserRole {
  /// Belum diketahui
  unknown,

  /// Mahasiswa
  mahasiswa,

  /// Dosen pembimbing
  dosen,

  /// Mentor (shares UI with dosen)
  mentor,
}

/// Provider untuk mengelola state autentikasi secara global.
///
/// Gunakan `context.read<AuthProvider>()` untuk akses method.
/// Gunakan `context.watch<AuthProvider>()` untuk listen perubahan.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  final FirebaseFirestore _firestore;

  AuthProvider({AuthRepository? repo, FirebaseFirestore? firestore})
    : _repo = repo ?? AuthRepository(),
      _firestore = firestore ?? FirebaseFirestore.instance {
    // Listen perubahan auth state dari Firebase
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;
  bool _isLoading = false;
  UserRole _userRole = UserRole.unknown;

  // ─────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────

  /// Status autentikasi saat ini
  AuthStatus get status => _status;

  /// User yang sedang login (null jika belum login)
  User? get user => _user;

  /// Error message terakhir (null jika tidak ada error)
  String? get error => _error;

  /// Apakah sedang proses login/logout
  bool get isLoading => _isLoading;

  /// Shortcut untuk cek apakah user sudah login
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Role user saat ini
  UserRole get userRole => _userRole;

  /// Shortcut untuk cek apakah user adalah dosen
  bool get isDosen => _userRole == UserRole.dosen;

  /// Shortcut untuk cek apakah user adalah mentor
  bool get isMentor => _userRole == UserRole.mentor;

  /// Shortcut untuk cek apakah user adalah dosen atau mentor
  bool get isDosenOrMentor => isDosen || isMentor;

  // ─────────────────────────────────────────────────────────────────
  // Private Methods
  // ─────────────────────────────────────────────────────────────────

  void _onAuthStateChanged(User? user) {
    _user = user;
    _status = user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    // Reset role when user changes
    if (user == null) {
      _userRole = UserRole.unknown;
    }
    notifyListeners();
  }

  String _friendlyError(String m) {
    if (m.contains('invalid-email')) return 'Email tidak valid.';
    if (m.contains('user-not-found')) return 'Akun tidak ditemukan.';
    if (m.contains('wrong-password')) return 'Password salah.';
    if (m.contains('invalid-credential')) return 'Email atau password salah.';
    if (m.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    }
    return 'Periksa data kamu lagi ya..';
  }

  // ─────────────────────────────────────────────────────────────────
  // Public Methods
  // ─────────────────────────────────────────────────────────────────

  /// Fetch role user dari Firestore.
  /// Panggil ini setelah login berhasil atau saat splash screen.
  Future<UserRole> fetchUserRole() async {
    if (_user == null) {
      _userRole = UserRole.unknown;
      return _userRole;
    }
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final roleStr = data?['role'] as String? ?? '';
        if (roleStr == 'dosen') {
          _userRole = UserRole.dosen;
        } else if (roleStr == 'mentor') {
          _userRole = UserRole.mentor;
        } else if (roleStr == 'mahasiswa') {
          _userRole = UserRole.mahasiswa;
        } else {
          // Fallback based on presence of 'kelas'
          if (data?['kelas'] != null) {
            _userRole = UserRole.mahasiswa;
          } else {
            _userRole = UserRole.dosen;
          }
        }
      } else {
        _userRole = UserRole.mahasiswa; // Default
      }
      notifyListeners();
      return _userRole;
    } catch (e) {
      _userRole = UserRole.mahasiswa;
      notifyListeners();
      return _userRole;
    }
  }

  /// Login dengan email dan password.
  /// Returns `true` jika berhasil, `false` jika gagal.
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.signIn(email: email, password: password);
      await fetchUserRole();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _friendlyError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _repo.signOut();
    _userRole = UserRole.unknown;
    _isLoading = false;
    notifyListeners();
  }

  /// Hapus error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
