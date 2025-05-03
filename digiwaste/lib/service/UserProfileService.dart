import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/User.dart';

class UserProfileService {
  static const String baseUrl = 'http://192.168.100.39:3000/users';

  // Fungsi untuk update user
  Future<User?> updateUser(User user) async {
    final url = '$baseUrl/edit/${user.id}';

    print("=====DEBUG FORM INPUTAN SEBELUM UPDATE =====");
    print("ID User       : ${user.id}");
    print("Nama Lengkap  : ${user.namaLengkap}");
    print("Username      : ${user.username}");
    print("Nomor Telepon : ${user.nomorTelepon}");
    print("Email         : ${user.email}");
    print("Password      : ${user.password}");
    print("Role          : ${user.role}");
    print("Foto (Base64) : ${user.foto?.substring(0, 20) ?? 'Tidak ada'}..."); 
    print("==============================================");

    final data = {
      "foto": user.foto ?? null,
      "nama_lengkap": user.namaLengkap,
      "username": user.username,
      "nomor_telepon": user.nomorTelepon,
      "email": user.email,
      "password": user.password,
      "role": user.role,
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("=====DEBUG RESPONSE DARI SERVER =====");
    print("Status Code   : ${response.statusCode}");
    print("Response Body : ${response.body}");
    print("==========================================");

    if (response.statusCode == 200) {
      print("✅ Update sukses!");

      // 🔄 **Ambil data terbaru setelah update & return**
      return await getUserById(user.id);
    } else {
      print("❌ Update gagal! Periksa kembali data yang dikirim.");
      return null;
    }
  }

  // Fungsi untuk mengambil user berdasarkan ID setelah update
  static Future<User?> getUserById(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));

    // Debug: Tampilkan response dari API
    print("=====DEBUG FETCH USER BY ID =====");
    print("URL            : $baseUrl/$userId");
    print("Status Code    : ${response.statusCode}");
    print("Response Body  : ${response.body}");
    print("======================================");

    if (response.statusCode == 200) {
      Map<String, dynamic> userData = jsonDecode(response.body);
      return User.fromJson(userData);
    } else {
      print("⚠️ Gagal mengambil user dengan ID: $userId");
      return null;
    }
  }
}