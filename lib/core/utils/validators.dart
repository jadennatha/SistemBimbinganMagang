class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
    final ok = RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$').hasMatch(v);
    if (!ok) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    if (v.length < 6) return 'Minimal 6 karakter';
    return null;
  }
}
