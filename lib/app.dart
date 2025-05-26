import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main/main_screen.dart';

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Tránsito Inteligente',
      theme: appTheme,
      routes: appRoutes,
      home: isLoggedIn ? const MainScreen(role: 'ciudadano') : const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}