import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/Dashboard.dart';
import 'package:digiwaste/user/Login.dart';
import 'package:digiwaste/service/auth_service.dart';

class UserProfilePage extends StatefulWidget {
  final User user;
  const UserProfilePage({super.key, required this.user});

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
  File? _image;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.user.namaLengkap;
    _usernameController.text = widget.user.username;
    _nomorTeleponController.text = widget.user.nomorTelepon;
    _emailController.text = widget.user.email;
    // Tampilkan password asli dengan mendekripsi password yang tersimpan
    _passwordController.text = _authService.decryptPassword(widget.user.password);
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    // Buat objek User baru dengan data input terbaru
    User updatedUser = User(
      id: widget.user.id,
      namaLengkap: _namaController.text,
      username: _usernameController.text,
      nomorTelepon: _nomorTeleponController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: widget.user.role,
      foto: widget.user.foto, // Gunakan foto lama, atau nanti bisa disesuaikan jika _image dipilih
    );

    bool success = await _authService.updateUser(updatedUser, _image);
    if (success) {
      // Setelah update, ambil data terbaru dari server
      User? refreshedUser = await _authService.getUserById(updatedUser.id);
      if (refreshedUser != null) {
        // Navigasi ke Dashboard dengan data terbaru
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard(user: refreshedUser)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui profil!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui profil!')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DigiWaste'),
        backgroundColor: Colors.grey[300],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Foto Profil dengan kemampuan memilih dari galeri
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (widget.user.foto != null && widget.user.foto!.isNotEmpty
                          ? NetworkImage(widget.user.foto!)
                          : const AssetImage("assets/default_avatar.png") as ImageProvider),
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              // Nama Lengkap
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Lengkap"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nama lengkap tidak boleh kosong";
                  }
                  return null;
                },
              ),
              // Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Username tidak boleh kosong";
                  }
                  return null;
                },
              ),
              // Nomor Telepon
              TextFormField(
                controller: _nomorTeleponController,
                decoration: const InputDecoration(labelText: "Nomor Telepon"),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nomor telepon tidak boleh kosong";
                  }
                  return null;
                },
              ),
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Email tidak boleh kosong";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Format email tidak valid";
                  }
                  return null;
                },
              ),
              // Password dengan toggle visibility
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Password tidak boleh kosong";
                  }
                  if (value.length < 6) {
                    return "Password minimal 6 karakter";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Tombol Simpan untuk update profil
              ElevatedButton(
                onPressed: _updateUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Simpan"),
              ),
              const SizedBox(height: 24),
              // Tombol Logout
              ElevatedButton(
                onPressed: () async {
                  await _authService.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}