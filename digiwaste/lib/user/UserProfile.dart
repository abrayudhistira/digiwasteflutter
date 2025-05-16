import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/Dashboard.dart';
import 'package:digiwaste/user/Login.dart';
import 'package:digiwaste/service/auth_service.dart';
import 'dart:convert';

class UserProfilePage extends StatefulWidget {
  final User user;
  const UserProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nomorTeleponController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  File? _image;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.user.namaLengkap;
    _usernameController.text = widget.user.username;
    _nomorTeleponController.text = widget.user.nomorTelepon;
    _emailController.text = widget.user.email;
    // Tampilkan password asli
    _passwordController.text = _authService.decryptPassword(widget.user.password);
  }

  @override
  void dispose() {
    // bersihkan controller
    _namaController.dispose();
    _usernameController.dispose();
    _nomorTeleponController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    // Tutup keyboard / lepaskan fokus
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Buat objek User baru
    final updatedUser = User(
      id: widget.user.id,
      foto: widget.user.foto,
      namaLengkap: _namaController.text.trim(),
      username: _usernameController.text.trim(),
      nomorTelepon: _nomorTeleponController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: widget.user.role,
    );

    final success = await _authService.updateUser(updatedUser, imageFile: _image);

    setState(() => _isLoading = false);

    if (success) {
      // Ambil data terbaru
      final refreshedUser = await _authService.getUserById(updatedUser.id);
      if (refreshedUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Dashboard(user: refreshedUser)),
        );
        return;
      }
    }

    // Jika gagal update atau gagal refresh
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success
        ? 'Gagal memuat data terbaru'
        : 'Gagal memperbarui profil')),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  @override
  Widget build(BuildContext context) {
    late ImageProvider avatarImage;
    final foto = widget.user.foto;
    try {
      if (foto != null && foto.isNotEmpty) {
        if (foto.startsWith('data:image')) {
          final parts = foto.split(',');
          if (parts.length > 1 && parts[1].isNotEmpty) {
            final bytes = base64Decode(parts[1]);
            avatarImage = MemoryImage(bytes);
          } else {
            avatarImage = const AssetImage('assets/default_avatar.png');
          }
        } else {
          avatarImage = NetworkImage(foto);
        }
      } else {
        avatarImage = const AssetImage('assets/default_avatar.png');
      }
    } catch (e) {
      debugPrint('Error decoding foto base64: $e');
      avatarImage = const AssetImage('assets/default_avatar.png');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.grey[300],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar & pick image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: avatarImage,
                  onBackgroundImageError: (_, __) {
                    // jika error loading image, pakai default
                    setState(() {});
                  },
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Fields
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => (v?.trim().isEmpty ?? true)
                  ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => (v?.trim().isEmpty ?? true)
                  ? 'Username tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomorTeleponController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                keyboardType: TextInputType.phone,
                validator: (v) => (v?.trim().isEmpty ?? true)
                  ? 'Nomor telepon tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                  final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return pattern.hasMatch(v) ? null : 'Format email tidak valid';
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                  if (v.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Simpan'),
                ),
              ),

              const SizedBox(height: 16),
              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await _authService.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
