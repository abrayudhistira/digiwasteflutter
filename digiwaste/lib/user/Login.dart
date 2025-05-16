import 'package:flutter/material.dart';
import 'package:digiwaste/user/Register.dart';
import 'package:digiwaste/service/auth_service.dart';
import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/Dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // void _login() async {
  //   String username = _usernameController.text.trim();
  //   String password = _passwordController.text.trim();

  //   if (username.isEmpty || password.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Username dan password tidak boleh kosong')),
  //     );
  //     return;
  //   }

  //   User? user = await _authService.login(username, password);

  //   if (user != null) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => Dashboard(user: user),
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text('Login gagal, periksa kembali username dan password'),
  //         action: SnackBarAction(
  //           label: 'Coba Lagi',
  //           onPressed: () {
  //             _usernameController.clear();
  //             _passwordController.clear();
  //           },
  //         ),
  //       ),
  //     );
  //   }
  // }

//   void _login() async {
//   String username = _usernameController.text.trim();
//   String password = _passwordController.text.trim();

//   if (username.isEmpty || password.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Username dan password tidak boleh kosong')),
//     );
//     return;
//   }

//   bool ok = await _authService.login(username, password) ?? false;
//   if (ok) {
//     User? user = await _authService.getCurrentUser();
//     if (user != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => Dashboard(user: user)),
//       );
//       return;
//     }
//   }

//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: const Text('Login gagal, periksa kembali username dan password'),
//       action: SnackBarAction(
//         label: 'Coba Lagi',
//         onPressed: () {
//           _usernameController.clear();
//           _passwordController.clear();
//         },
//       ),
//     ),
//   );
// }
void _login() async {
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    _showSnackBar('Username dan password tidak boleh kosong');
    return;
  }

  try {
    bool loginSuccess = await _authService.login(username, password);
    
    if (!loginSuccess) {
      _showErrorSnackBar();
      return;
    }
    
    User? user = await _authService.getCurrentUser();
    
    if (user == null) {
      print('⚠️ User data not found after successful login');
      _showErrorSnackBar();
      return;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Dashboard(user: user)),
    );
    
  } catch (e) {
    print('🚨 Login error: $e');
    _showErrorSnackBar();
  }
}

void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message))
  );
}

void _showErrorSnackBar() {
  _showSnackBar('Login gagal, periksa kembali username dan password');
}

SnackBar _buildErrorSnackBar() {
  return SnackBar(
    content: const Text('Login gagal, periksa kembali username dan password'),
    action: SnackBarAction(
      label: 'Coba Lagi',
      onPressed: () {
        _usernameController.clear();
        _passwordController.clear();
      },
    ),
  );
}

  @override
  void initState() {
    super.initState();
    _authService.getCurrentUser().then((user) {
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Dashboard(user: user)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Center(
          child: Text(
            'Digiwaste',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Text(
                'Login Admin',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login button pressed')),
                );
              },
              child: const Text('Admin Login'),
            ),
            ElevatedButton(
              onPressed: _authService.logout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum punya akun? '),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text(
                    'Silahkan Register',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
