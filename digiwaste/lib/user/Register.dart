import 'package:flutter/material.dart';
import 'package:digiwaste/service/auth_service.dart';
import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/Dashboard.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController addressController = TextEditingController(); // Nomor HP
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? selectedRole;
  bool agreedToTerms = false;
  final List<String> roles = ['Pengelola Sampah', 'Pembeli'];

  // Menggunakan AuthService saja
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 1.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'DigiWaste',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registrasi Akun',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildTextFormField(controller: fullNameController, hintText: 'Nama Lengkap'),
              _buildTextFormField(controller: _usernameController, hintText: 'Username'),
              _buildTextFormField(controller: addressController, hintText: 'Nomor HP'),
              _buildTextFormField(controller: _emailController, hintText: 'Email'),
              _buildTextFormField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              _buildTextFormField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                hint: const Text('Role'),
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedRole = value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[150],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null ? 'Pilih role' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: agreedToTerms,
                    onChanged: (value) => setState(() => agreedToTerms = value ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'Saya telah menyetujui syarat & ketentuan',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[150],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Form tidak boleh kosong' : null,
      ),
    );
  }

  void _register() async {
    print('>> _register() tapped');
    if (!_formKey.currentState!.validate()) return;

    // Cek apakah password dan konfirmasi password sama
    if (_passwordController.text.trim() != confirmPasswordController.text.trim()) {
      _showErrorDialog("Password dan Confirm Password tidak sama");
      return;
    }

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();

    // // Buat objek User baru, ID di-set 0 (server akan mengisinya) dan foto null
    User newUser = User(
      id: 0,
      namaLengkap: fullNameController.text,
      username: username,
      nomorTelepon: addressController.text,
      email: email,
      password: password, // Password akan dienkripsi di dalam AuthService.register()
      role: selectedRole!,
      foto: null,
    );

    // bool success = await _authService.register(newUser);

    // if (success) {
    //   // Navigasi ke Dashboard setelah registrasi sukses
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => Dashboard(user: newUser)),
    //   );
    // } else {
    //   _showErrorDialog("Registrasi gagal");
    // }
    User? registeredUser = await _authService.register(newUser);
      if (registeredUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Dashboard(user: registeredUser)),
        );
      } else {
        _showErrorDialog("Registrasi gagal");
      }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Registrasi Gagal"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}