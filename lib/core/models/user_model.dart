class UserModel {
  final String uid;
  final String email;
  final String role;
  final String nama;

  // Data Mahasiswa
  final String? nim;
  final String? prodi;
  final String? kelas;
  final String? dosenId;
  final String? mentorId;
  final String? perusahaan; // untuk Mentor juga
  final String? posisi; // untuk Mentor juga
  final DateTime? tglMulai; // untuk Mahasiswa magang
  final DateTime? tglSelesai; // untuk Mahasiswa magang

  // Data Dosen
  final String? nip;
  final String? fakultas;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.nama,
    this.nim,
    this.prodi,
    this.kelas,
    this.dosenId,
    this.mentorId,
    this.perusahaan,
    this.posisi,
    this.fakultas,
    this.nip,
    this.tglMulai,
    this.tglSelesai,
  });

  // FUNGSI 1: Mengubah Data dari Firestore (Map) ke Object Dart
  // Dipakai saat mengambil data (Get / Read)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      role: (data['role'] ?? 'mahasiswa').toString().toLowerCase(),
      nama: data['nama'] ?? '',
      
      // Ambil data sesuai field yang ada di Firestore
      nim: data['nim'],
      prodi: data['prodi'],
      kelas: data['kelas'],
      dosenId: data['dosenId'],
      mentorId: data['mentorId'],
      perusahaan: data['perusahaan'],
      posisi: data['posisi'],
      nip: data['nip'],
      fakultas: data['fakultas'],
      tglMulai: parseDate(data['tglMulai']),
      tglSelesai: parseDate(data['tglSelesai'])
    );
  }

  // FUNGSI 2: Mengubah Object Dart ke Map
  // Dipakai saat menyimpan data (Set / Update)
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'uid': uid,
      'email': email,
      'role': role,
      'nama': nama,
    };

    // Logika agar yang disimpan ke database hanya field yang relevan
    if (role == 'mahasiswa') {
      data['nim'] = nim;
      data['prodi'] = prodi;
      data['kelas'] = kelas;
      data['dosenId'] = dosenId;
      data['mentorId'] = mentorId;
      data['perusahaan'] = perusahaan;
      data['posisi'] = posisi;
      data['tglMulai'] = tglMulai;
      data['tglSelesai'] = tglSelesai;
    } else if (role == 'dosen') {
      data['nip'] = nip;
      data['fakultas'] = fakultas;
    } else if (role == 'mentor') {
      data['perusahaan'] = perusahaan;
      data['posisi'] = posisi;
    }

    return data;
  }
}