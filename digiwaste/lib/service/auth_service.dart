import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../model/User.dart';

class AuthService {
  // URL untuk operasi login dan pengambilan data user
  final String baseUrl = 'http://192.168.100.39:3000/users';
  // URL untuk registrasi
  final String registerUrl = 'http://192.168.100.39:3000/users/new';
  // URL untuk update profil
  final String updateUrl = 'http://192.168.100.39:3000/users/edit';

  // Secret key untuk AES (harus 16, 24, atau 32 karakter; disini kita gunakan 32 karakter)
  final encrypt.Key _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');

  /// Enkripsi password menggunakan AES dalam mode ECB (tanpa IV)
  String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.ecb));
    final encrypted = encrypter.encrypt(password);
    return encrypted.base64;
  }

  /// Dekripsi password yang terenkripsi
  String decryptPassword(String encryptedPassword) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.ecb));
    return encrypter.decrypt64(encryptedPassword);
  }

  /// Login user dengan username dan password
  Future<User?> login(String username, String password) async {
    try {
      // Mengambil semua user
      final response = await http.get(Uri.parse(baseUrl));
      print('Response Code (login): ${response.statusCode}');
      print('Response Body (login): ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);

        // Enkripsi password input menggunakan mode ECB
        String encryptedPassword = encryptPassword(password);

        for (var user in users) {
          if (user['username'] == username && user['password'] == encryptedPassword) {
            User loggedInUser = User.fromJson(user);
            await _saveUserToPreferences(loggedInUser);
            return loggedInUser;
          }
        }
        print('Login Gagal: Username atau password salah');
        return null;
      } else {
        print('Login Gagal: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  /// Register user: enkripsi password sebelum dikirim, gunakan registerUrl
  Future<bool> register(User user) async {
    try {
      // Enkripsi password menggunakan mode ECB
      user.password = encryptPassword(user.password);

      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Register Gagal: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Register Error: $e');
      return false;
    }
  }

  Future<bool> updateUser(User user, File? imageFile) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$updateUrl/${user.id}'));

      request.fields['nama_lengkap'] = user.namaLengkap;
      request.fields['username'] = user.username;
      request.fields['nomor_telepon'] = user.nomorTelepon;
      request.fields['email'] = user.email;
      request.fields['password'] = encryptPassword(user.password);
      request.fields['role'] = user.role;

      // Debug: Tampilkan data yang akan dikirim
      print("Data yang dikirim untuk update: ${request.fields}");

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));
      }

      var response = await request.send();
      print("Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Update Error: Status Code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Update Error: $e');
      return false;
    }
  }

  /// Ambil data user berdasarkan ID
  Future<User?> getUserById(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Get User Error: $e');
      return null;
    }
  }

  /// Simpan user ke SharedPreferences
  Future<void> _saveUserToPreferences(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toJson()));
  }

  /// Ambil user dari SharedPreferences
  Future<User?> getUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  /// Hapus user dari SharedPreferences (Logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }
}
