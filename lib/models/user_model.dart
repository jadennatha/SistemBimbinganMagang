class UserModel {
  final String uid;
  final String email;
  final String role;
  final String nama;

  // Data Mahasiswa
  final String? nim;
  final String? prodi;
  final String? kelas;
  final String? dosenID;
  final String? mentorID;
  final String? perusahaan; // untuk Mentor juga
  final String? posisi; // untuk Mentor juga

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
    this.dosenID,
    this.mentorID,
    this.perusahaan,
    this.posisi,
    this.fakultas,
    this.nip,
  });

  // FUNGSI 1: Mengubah Data dari Firestore (Map) ke Object Dart
  // Dipakai saat mengambil data (Get / Read)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      role: (data['role'] ?? 'mahasiswa').toString().toLowerCase(),
      nama: data['nama'] ?? '',
      
      // Ambil data sesuai field yang ada di Firestore
      nim: data['nim'],
      prodi: data['prodi'],
      kelas: data['kelas'],
      dosenID: data['dosenId'],
      mentorID: data['mentorId'],
      perusahaan: data['perusahaan'],
      posisi: data['posisi'],
      nip: data['nip'],
      fakultas: data['fakultas'],
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
      data['dosenID'] = dosenID;
      data['mentorID'] = mentorID;
      data['perusahaan'] = perusahaan;
      data['posisi'] = posisi;
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