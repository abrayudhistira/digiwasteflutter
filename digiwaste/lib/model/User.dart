import 'dart:convert';

class User {
  int id;
  String? foto;
  String namaLengkap;
  String username;
  String nomorTelepon;
  String email;
  String password;
  String role;

  User({
    required this.id,
    this.foto,
    required this.namaLengkap,
    required this.username,
    required this.nomorTelepon,
    required this.email,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_user'] ?? 0,
      foto: _convertFoto(json['foto']),
      namaLengkap: json['nama_lengkap'] ?? '',
      username: json['username'] ?? '',
      nomorTelepon: json['nomor_telepon'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
    );
  }

  static String? _convertFoto(dynamic foto) {
    if (foto == null) {
      return null;
    } else if (foto is String) {
      return foto; // Sudah dalam format String
    } else if (foto is Map && foto.containsKey('data')) {
      // Ambil byte array dari `foto['data']`
      List<int> byteArray = List<int>.from(foto['data']);
      return "data:image/png;base64,${base64Encode(byteArray)}";
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'username': username,
      'nomor_telepon': nomorTelepon,
      'email': email,
      'password': password,
      'role': role,
      'foto': foto,
    };
  }
}