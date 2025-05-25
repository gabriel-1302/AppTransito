import 'package:flutter/material.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main/main_screen.dart';
import 'services/api_service_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ApiServiceAuth apiService = ApiServiceAuth();
  
  // Comprobar si ya está logueado
  bool isLoggedIn = await apiService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Tránsito Inteligente',
      theme: ThemeData.light(),
      home: isLoggedIn ? const MainScreen(role: 'ciudadano') : const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
