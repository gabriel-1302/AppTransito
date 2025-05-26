import 'package:flutter/material.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/main/main_screen.dart';
import '../second_app/screens/second_app_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const AuthScreen(),
  '/main': (context) => const MainScreen(role: 'ciudadano'),
  '/main/policia': (context) => const MainScreen(role: 'policia'),
  '/second-app': (context) => const SecondAppScreen(),
};