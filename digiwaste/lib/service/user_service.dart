import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class UserService {
  static const String baseUrl = 'http://192.168.100.142:3000/users';

  // Metode untuk mengenkripsi password menggunakan SHA-256
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // **REGISTER USER**
  Future<Map<String, dynamic>> registerUser({
    required String namaLengkap,
    required String username,
    required String nomorTelepon,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/new');

    String hashedPassword = hashPassword(password); // Hash password sebelum dikirim

    final Map<String, dynamic> data = {
      "nama_lengkap": namaLengkap,
      "username": username,
      "nomor_telepon": nomorTelepon,
      "email": email,
      "password": hashedPassword,
      "role": role,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["status"] == "success") {
        return {
          "success": true,
          "message": responseData["message"],
          "id_user": responseData["id_user"], 
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "Registrasi gagal!",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Terjadi kesalahan: $e",
      };
    }
  }

  // **LOGIN USER**
  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');

    String hashedPassword = hashPassword(password); // Hash password untuk login

    final Map<String, dynamic> data = {
      "username": username,
      "password": hashedPassword,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["status"] == "success") {
        return {
          "success": true,
          "message": responseData["message"],
          "user": responseData["user"], // Data user bisa digunakan di aplikasi
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "Login gagal!",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Terjadi kesalahan: $e",
      };
    }
  }
}