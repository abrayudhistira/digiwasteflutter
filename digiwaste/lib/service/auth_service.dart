import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../model/User.dart';

class AuthService {
  // Server endpoints
  static const String baseUrl = 'http://10.100.200.209:3000/users';
  static const String registerUrl = '$baseUrl/new';
  
  // Storage keys
  static const String _storageUserKey = 'digiwaste';
  static const String _storageAccessTokenKey = 'digiwaste';
  static const String _storageRefreshTokenKey = 'digiwaste';

  // Encryption configuration
  static var _encryptionKey = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final _storage = const FlutterSecureStorage();

  /// Encrypt password using AES-ECB
  String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey, mode: encrypt.AESMode.ecb));
    return encrypter.encrypt(password).base64;
  }

  /// Decrypt stored password
  String decryptPassword(String encryptedPassword) {
  if (encryptedPassword.isEmpty || encryptedPassword == 'null') {
    return '[password_tidak_tersedia]';
  }
  
  try {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey, mode: encrypt.AESMode.ecb)
    );
    return encrypter.decrypt64(encryptedPassword);
  } catch (e) {
    print('Decryption error: $e');
    return '[password_terenkripsi_invalid]';
  }
}

  /// Login with username and password
//   Future<bool> login(String username, String password) async {
//   try {
//     final response = await http.post(
//       Uri.parse('$baseUrl/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'username': username,
//         'password': encryptPassword(password),
//       }),
//     );

//     // Debug: Cetak response server
//     print('Login Response: ${response.statusCode} ${response.body}');

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
      
//       // Validasi struktur response
//       if (data['user'] == null || data['user'] is! Map<String, dynamic>) {
//         print('⚠️ Invalid user data from server');
//         return false;
//       }
      
//       // Simpan data
//       await _storage.write(key: _storageAccessTokenKey, value: data['digiwaste']);
//       await _storage.write(key: _storageRefreshTokenKey, value: data['digiwaste']);
//       await _storage.write(key: _storageUserKey, value: jsonEncode(data['digiwaste']));
      
//       return true;
//     }
    
//     return false;
//   } catch (e) {
//     print('🚨 Login error: $e');
//     return false;
//   }
// }

// Future<bool> login(String username, String password) async {
//   try {
//     final response = await http.post(
//       Uri.parse('$baseUrl/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'username': username,
//         'password': encryptPassword(password),
//       }),
//     );

//     print('Login Response Status: ${response.statusCode}');
//     print('Login Response Body: ${response.body}'); // Debug penting

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = jsonDecode(response.body);
      
//       // Validasi struktur response
//       if (!data.containsKey('user')) {
//         print('⚠️ User data missing in response');
//         return false;
//       }
      
//       // Simpan data
//       await _storage.write(key: _storageAccessTokenKey, value: data['accessToken'] ?? '');
//       await _storage.write(key: _storageRefreshTokenKey, value: data['refreshToken'] ?? '');
//       // Di AuthService.login
//       await _storage.write(
//         key: _storageUserKey, 
//         value: jsonEncode({
//           ...data['user'],
//           'password': data['user']['password'] // Pastikan field ini ada
//         })
//       );
      
//       // Debug: Cek data yang akan disimpan
//       print('User data to save: ${data['user']}');
      
//       return true;
//     }
    
//     return false;
//   } catch (e) {
//     print('🚨 Login error: $e');
//     return false;
//   }
// }
Future<bool> login(String username, String password) async {
  try {
    final encryptedPass = encryptPassword(password);
    
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': encryptedPass,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userData = Map<String, dynamic>.from(data['user']);
      
      // Inject encrypted password jika tidak ada dari server
      if (userData['password'] == null) {
        userData['password'] = encryptedPass;
      }
      
      await _storage.write(
        key: _storageUserKey,
        value: jsonEncode(userData)
      );
      
      return true;
    }
    return false;
  } catch (e) {
    print('Login error: $e');
    return false;
  }
}
  /// User registration
  Future<User?> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_lengkap': user.namaLengkap,
          'username': user.username,
          'nomor_telepon': user.nomorTelepon,
          'email': user.email,
          'password': encryptPassword(user.password),
          'role': user.role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: _storageAccessTokenKey, value: data['digiwaste']);
        await _storage.write(key: _storageRefreshTokenKey, value: data['digiwaste']);
        await _storage.write(key: _storageUserKey, value: jsonEncode(data['digiwaste']));
        return User.fromJson(data['user']);
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  /// Get current user from secure storage
  Future<User?> getCurrentUser() async {
  final userJson = await _storage.read(key: _storageUserKey);
  
  // Debug: Cetak data mentah yang tersimpan
  print('Raw user data from storage: $userJson');
  
  if (userJson == null || userJson.isEmpty) return null;
  
  try {
    final dynamic decodedJson = jsonDecode(userJson);
    
    // Debug: Cetak tipe data hasil decode
    print('Decoded data type: ${decodedJson.runtimeType}');
    
    if (decodedJson is! Map<String, dynamic>) {
      print('⚠️ Invalid user data format. Expected Map, got ${decodedJson.runtimeType}');
      await _storage.delete(key: _storageUserKey); // Hapus data invalid
      return null;
    }
    
    return User.fromJson(decodedJson);
  } catch (e) {
    print('🚨 Error parsing user data: $e');
    await _storage.delete(key: _storageUserKey); // Hapus data korup
    return null;
  }
}

  /// Update user profile
  Future<bool> updateUser(User user, {File? imageFile}) async {
    try {
      final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/edit/${user.id}'));
      
      // Add text fields
      request.fields
        ..['nama_lengkap'] = user.namaLengkap
        ..['username'] = user.username
        ..['nomor_telepon'] = user.nomorTelepon
        ..['email'] = user.email
        ..['password'] = encryptPassword(user.password)
        ..['role'] = user.role;

      // Add image file if provided
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', imageFile.path));
      }

      // Add authorization header
      final accessToken = await _storage.read(key: _storageAccessTokenKey);
      request.headers['Authorization'] = 'Bearer $accessToken';

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Update error: $e');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: _storageRefreshTokenKey);
      if (refreshToken != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      }
    } finally {
      await _storage.deleteAll();
    }
  }

  /// Refresh access token
  Future<bool> refreshToken() async {
    final refreshToken = await _storage.read(key: _storageRefreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: _storageAccessTokenKey, value: data['digiwaste']);
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  /// Get user by ID
  Future<User?> getUserById(int userId) async {
    try {
      final accessToken = await _storage.read(key: _storageAccessTokenKey);
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }
}