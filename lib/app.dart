import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'screens/auth/auth_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Tránsito Inteligente',
      theme: appTheme,
      home: const AuthScreen(),
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
    );
  }
}