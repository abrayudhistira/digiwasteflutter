import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/Dashboard.dart';
import 'package:digiwaste/user/Login.dart';
import 'package:digiwaste/service/auth_service.dart';
import 'dart:convert';

// Custom color scheme based on provided hex colors
class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color darkGreen = Color(0xFF01271A);
  static const Color seaGreen = Color(0xFF008C44);
  static const Color teaGreen = Color(0xFFE0FBC0);
}

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
  int _selectedIndex = 4; // Index for Profile in bottom navigation

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
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: AppColors.seaGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    // Jika gagal update atau gagal refresh
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
          ? 'Gagal memuat data terbaru'
          : 'Gagal memperbarui profil'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () async {
                      Navigator.pop(context);
                      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                      if (picked != null) {
                        setState(() => _image = File(picked.path));
                      }
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () async {
                      Navigator.pop(context);
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() => _image = File(picked.path));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.teaGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.darkGreen, size: 30),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Konfirmasi Logout',
            style: TextStyle(
              color: AppColors.darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'BATAL',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.seaGreen,
                foregroundColor: Colors.white,
                elevation: 0, // Remove shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('LOGOUT'),
            ),
          ],
        );
      },
    );
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

    // Preview image if selected
    final displayImage = _image != null ? FileImage(_image!) : avatarImage;
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
        centerTitle: true,
        elevation: 0, // Remove shadow under AppBar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with profile picture
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                // Shadow removed from here
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar & pick image
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.teaGreen, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          backgroundImage: displayImage,
                          onBackgroundImageError: (_, __) {
                            setState(() {});
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.seaGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.user.namaLengkap,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.user.email,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
            
            // Form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Pribadi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Fields
                    _buildTextField(
                      controller: _namaController,
                      label: 'Nama Lengkap',
                      icon: Icons.person,
                      validator: (v) => (v?.trim().isEmpty ?? true)
                        ? 'Nama tidak boleh kosong' : null,
                    ),
                    
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.alternate_email,
                      validator: (v) => (v?.trim().isEmpty ?? true)
                        ? 'Username tidak boleh kosong' : null,
                    ),
                    
                    _buildTextField(
                      controller: _nomorTeleponController,
                      label: 'Nomor Telepon',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v?.trim().isEmpty ?? true)
                        ? 'Nomor telepon tidak boleh kosong' : null,
                    ),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                        final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        return pattern.hasMatch(v) ? null : 'Format email tidak valid';
                      },
                    ),
                    
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: AppColors.darkGreen.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.lock, color: AppColors.seaGreen),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.seaGreen,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.seaGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                        if (v.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Buttons
                    _buildActionButton(
                      label: 'Simpan Perubahan',
                      icon: Icons.save,
                      color: AppColors.seaGreen,
                      isLoading: _isLoading,
                      onPressed: _updateUser,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildActionButton(
                      label: 'Logout',
                      icon: Icons.logout,
                      color: Colors.red.shade700,
                      onPressed: _confirmLogout,
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.darkGreen.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: AppColors.seaGreen),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.seaGreen, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: validator,
        // Hapus highlight/hitam pada selection dan cursor
        cursorColor: AppColors.seaGreen,
        selectionControls: null, // Default controls, tidak ada highlight custom
        selectionHeightStyle: BoxHeightStyle.tight, // Optional: lebih rapi
        selectionWidthStyle: BoxWidthStyle.tight,   // Optional: lebih rapi
      ),
    );
  }

  Widget       _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    bool isLoading = false,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0, // Remove shadow from buttons
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
          ? const SizedBox(
              width: 24, 
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2, 
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}