import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digiwaste/user/Login.dart';
import 'package:digiwaste/user/Dashboard.dart';
import 'package:digiwaste/service/auth_service.dart';
import 'package:digiwaste/model/User.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Inisialisasi Flutter
  final AuthService authService = AuthService();
  final User? user = await authService.getUserFromPreferences();
  await initializeDateFormatting('id', '');
  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final User? user;

  const MyApp({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: user == null ? const LoginScreen() : Dashboard(user: user!)
      // initialRoute: '/login',
      // routes: {
      //   '/' : (context) {
      //     final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      //     return Dashboard(
      //       user: user);
      //   },
      // },
    );
  }
}