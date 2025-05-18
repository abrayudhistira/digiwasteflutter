import 'package:flutter/material.dart';
import 'package:digiwaste/user/Register.dart';
import 'package:digiwaste/service/auth_service.dart';
import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/Dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Username dan password tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);
    try {
      bool success = await _authService.login(username, password);
      if (success) {
        User? user = await _authService.getCurrentUser();
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Dashboard(user: user)),
          );
        } else {
          _showSnackBar('Data pengguna tidak ditemukan.');
        }
      } else {
        _showSnackBar('Login gagal, periksa kembali username dan password');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF008C44),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the color palette
    const Color black = Color(0xFF000000);
    const Color darkGreen = Color(0xFF01271A);
    const Color seaGreen = Color(0xFF008C44);
    const Color teaGreen = Color(0xFFE0FBC0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [darkGreen, black],
            stops: [0.3, 0.9],
          ),
        ),
        child: Stack(
          children: [
            // Tech pattern background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: TechPatternPainter(color: teaGreen),
                  size: Size.infinite,
                ),
              ),
            ),
            
            // Glowing circles for tech effect
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: seaGreen.withOpacity(0.15),
                      blurRadius: 140,
                      spreadRadius: 70,
                    ),
                  ],
                ),
              ),
            ),
            
            Positioned(
              bottom: -120,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: seaGreen.withOpacity(0.12),
                      blurRadius: 120,
                      spreadRadius: 60,
                    ),
                  ],
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo section
                        _buildLogoSection(seaGreen, teaGreen),
                        const SizedBox(height: 40),
                        
                        // Login Form Card
                        Container(
                          constraints: BoxConstraints(maxWidth: 400),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: seaGreen.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: teaGreen,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Welcome back to DigiWaste',
                                  style: TextStyle(
                                    color: teaGreen.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                
                                // Username field
                                _buildTextField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  icon: Icons.person_outline,
                                  darkGreen: darkGreen,
                                  seaGreen: seaGreen,
                                  teaGreen: teaGreen,
                                ),
                                const SizedBox(height: 20),
                                
                                // Password field
                                _buildPasswordField(
                                  darkGreen: darkGreen,
                                  seaGreen: seaGreen,
                                  teaGreen: teaGreen,
                                ),
                                const SizedBox(height: 10),
                                
                                // Forgot password
                                // Align(
                                //   alignment: Alignment.centerRight,
                                //   child: TextButton(
                                //     onPressed: () {},
                                //     style: TextButton.styleFrom(
                                //       padding: EdgeInsets.zero,
                                //       minimumSize: Size(50, 30),
                                //     ),
                                //     child: Text(
                                //       'Lupa Password?',
                                //       style: TextStyle(
                                //         color: seaGreen,
                                //         fontSize: 13,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(height: 30),
                                
                                // Login button
                                _buildLoginButton(seaGreen, teaGreen),
                                const SizedBox(height: 30),
                                
                                // Register link
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Belum punya akun? ',
                                        style: TextStyle(color: teaGreen.withOpacity(0.7)),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                                          );
                                        },
                                        child: Text(
                                          'Daftar Sekarang',
                                          style: TextStyle(
                                            color: seaGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 15),
                                
                                // Or continue with
                                //_buildSocialLoginSection(darkGreen, seaGreen, teaGreen),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Footer text
                        Text(
                          '© 2025 PKM KC DigiWaste',
                          style: TextStyle(
                            color: teaGreen.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(Color seaGreen, Color teaGreen) {
    return Column(
      children: [
        // App Logo with glow effect
        Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: seaGreen.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: seaGreen.withOpacity(0.25),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: seaGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.eco_rounded,
            color: teaGreen,
            size: 56,
          ),
        ),
        const SizedBox(height: 24),
        // App Name
        Text(
          'DigiWaste',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: teaGreen,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        // Tagline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: seaGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'Smart Waste Management',
            style: TextStyle(
              fontSize: 14,
              color: teaGreen.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color darkGreen,
    required Color seaGreen,
    required Color teaGreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: teaGreen),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 18),
          prefixIcon: Icon(icon, color: seaGreen),
          labelText: label,
          labelStyle: TextStyle(color: teaGreen.withOpacity(0.7)),
          hintStyle: TextStyle(color: teaGreen.withOpacity(0.4)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: seaGreen.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: seaGreen, width: 1.5),
          ),
          filled: true,
          fillColor: darkGreen.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required Color darkGreen,
    required Color seaGreen,
    required Color teaGreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(color: teaGreen),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 18),
          prefixIcon: Icon(Icons.lock_outline, color: seaGreen),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: seaGreen.withOpacity(0.7),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          labelText: 'Password',
          labelStyle: TextStyle(color: teaGreen.withOpacity(0.7)),
          hintStyle: TextStyle(color: teaGreen.withOpacity(0.4)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: seaGreen.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: seaGreen, width: 1.5),
          ),
          filled: true,
          fillColor: darkGreen.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildLoginButton(Color seaGreen, Color teaGreen) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            seaGreen,
            seaGreen.withGreen(180),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: seaGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isLoading ? null : _login,
        child: _isLoading
            ? SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(teaGreen),
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: teaGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: teaGreen,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }

  // Widget _buildSocialLoginSection(Color darkGreen, Color seaGreen, Color teaGreen) {
  //   return Column(
  //     children: [
  //       Row(
  //         children: [
  //           Expanded(child: Divider(color: teaGreen.withOpacity(0.3), thickness: 0.5)),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //             child: Text(
  //               'Atau masuk dengan',
  //               style: TextStyle(
  //                 color: teaGreen.withOpacity(0.6),
  //                 fontSize: 12,
  //               ),
  //             ),
  //           ),
  //           Expanded(child: Divider(color: teaGreen.withOpacity(0.3), thickness: 0.5)),
  //         ],
  //       ),
  //       const SizedBox(height: 20),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           _buildSocialButton(
  //             icon: Icons.g_mobiledata,
  //             label: 'Google',
  //             color: darkGreen,
  //             borderColor: seaGreen,
  //             textColor: teaGreen,
  //           ),
  //           const SizedBox(width: 16),
  //           _buildSocialButton(
  //             icon: Icons.facebook,
  //             label: 'Facebook',
  //             color: darkGreen,
  //             borderColor: seaGreen,
  //             textColor: teaGreen,
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color borderColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: TextButton.icon(
          onPressed: () {},
          icon: Icon(icon, color: textColor, size: 22),
          label: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

// Custom painter for tech pattern background
class TechPatternPainter extends CustomPainter {
  final Color color;
  
  TechPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
      
    // Draw horizontal lines
    for (int i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
    
    // Draw vertical lines
    for (int i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    
    // Draw some circuit-like patterns
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
      
    // Diagonal lines
    for (int i = 0; i < size.width; i += 120) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble() + 60, 60),
        circlePaint,
      );
    }
    
    for (int i = 0; i < size.height; i += 120) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(60, i.toDouble() + 60),
        circlePaint,
      );
    }
    
    // Draw some small circles at grid intersections
    final circleFillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    for (int x = 0; x < size.width; x += 80) {
      for (int y = 0; y < size.height; y += 80) {
        if ((x + y) % 160 == 0) {
          canvas.drawCircle(
            Offset(x.toDouble(), y.toDouble()),
            1.5,
            circleFillPaint,
          );
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}