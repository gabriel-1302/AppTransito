import 'package:flutter/material.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/main/main_screen.dart';

// Definición de rutas para navegación
final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const AuthScreen(),
  '/main': (context) => const MainScreen(role: 'ciudadano'),
  '/main/policia': (context) => const MainScreen(role: 'policia'),
};
